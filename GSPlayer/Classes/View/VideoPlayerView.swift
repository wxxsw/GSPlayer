//
//  VideoPlayerView.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//
#if !os(macOS)
import UIKit
import AVFoundation

open class VideoPlayerView: UIView {
    
    public enum State {
        
        /// None
        case none
        
        /// From the first load to get the first frame of the video
        case loading
        
        /// Playing now
        case playing
        
        /// Pause, will be called repeatedly when the buffer progress changes
        case paused(playProgress: Double, bufferProgress: Double)
        
        /// An error occurred and cannot continue playing
        case error(NSError)
    }
    
    public enum PausedReason: Int {
        
        /// Pause because the player is not visible, stateDidChanged is not called when the buffer progress changes
        case hidden
        
        /// Pause triggered by user interaction, default behavior
        case userInteraction
        
        /// Waiting for resource completion buffering
        case waitingKeepUp
    }
    
    /// An object that manages a player's visual output.
    public let playerLayer = AVPlayerLayer()
    
    /// An object that provides the interface to control the player’s transport behavior.
    public var player: AVPlayer? {
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    /// URL currently playing.
    public private(set) var playerURL: URL?
    
    /// Get current video status.
    public private(set) var state: State = .none {
        didSet { stateDidChanged(state: state, previous: oldValue) }
    }
    
    /// The reason the video was paused.
    public private(set) var pausedReason: PausedReason = .waitingKeepUp
    
    /// Number of replays.
    public private(set) var replayCount: Int = 0
    
    /// Whether the video will be automatically replayed until the end of the video playback.
    open var isAutoReplay: Bool = true
    
    /// Play to the end time.
    open var playToEndTime: (() -> Void)?
    
    /// Playback status changes, such as from play to pause.
    open var stateDidChanged: ((State) -> Void)?
    
    /// Replay after playing to the end.
    open var replay: (() -> Void)?
    
    /// Whether the video is muted, only for this instance.
    open var isMuted: Bool {
        get { return player?.isMuted ?? false }
        set { player?.isMuted = newValue }
    }

    /// Video speed rate
    open var speedRate: Float = 1.0

    /// Video volume, only for this instance.
    open var volume: Double {
        get { return player?.volume.double ?? 0 }
        set { player?.volume = newValue.float }
    }
    
    /// Played progress, value range 0-1.
    public var playProgress: Double {
        return isLoaded ? player?.playProgress ?? 0 : 0
    }
    
    /// Played length in seconds.
    public var currentDuration: Double {
        return isLoaded ? player?.currentDuration ?? 0 : 0
    }
    
    /// Buffered progress, value range 0-1.
    public var bufferProgress: Double {
        return isLoaded ? player?.bufferProgress ?? 0 : 0
    }
    
    /// Buffered length in seconds.
    public var currentBufferDuration: Double {
        return isLoaded ? player?.currentBufferDuration ?? 0 : 0
    }
    
    /// Total video duration in seconds.
    public var totalDuration: Double {
        return isLoaded ? player?.totalDuration ?? 0 : 0
    }
    
    /// The total watch time of this video, in seconds.
    public var watchDuration: Double {
        return isLoaded ? currentDuration + totalDuration * Double(replayCount) : 0
    }
    
    private var isLoaded = false
    private var isReplay = false
    
    private var playerBufferingObservation: NSKeyValueObservation?
    private var playerItemKeepUpObservation: NSKeyValueObservation?
    private var playerItemStatusObservation: NSKeyValueObservation?
    private var playerLayerReadyForDisplayObservation: NSKeyValueObservation?
    private var playerTimeControlStatusObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    
    open override var contentMode: UIView.ContentMode {
        didSet {
            switch contentMode {
            case .scaleAspectFill:  playerLayer.videoGravity = .resizeAspectFill
            case .scaleAspectFit:   playerLayer.videoGravity = .resizeAspect
            default:                playerLayer.videoGravity = .resize
            }
        }
    }
    
    public init() {
        super.init(frame: .zero)
        configureInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard playerLayer.superlayer == layer else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = bounds
        CATransaction.commit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@objc extension VideoPlayerView {
    
    /// Play a video of the specified url.
    ///
    /// - Parameter url: Can be a local or remote URL
    open func play(for url: URL) {
        guard playerURL != url else {
            pausedReason = .waitingKeepUp
            player?.playImmediately(atRate: speedRate)
            return
        }
        
        observe(player: nil)
        observe(playerItem: nil)
        
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
        
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        
        let playerItem = AVPlayerItem(loader: url)
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        self.player = player
        self.playerURL = url
        self.pausedReason = .waitingKeepUp
        self.replayCount = 0
        self.isReplay = false
        self.isLoaded = false
        
        if playerItem.isEnoughToPlay || url.isFileURL {
            state = .none
            isLoaded = playerItem.status == .readyToPlay
            player.playImmediately(atRate: speedRate)
        } else {
            state = .loading
        }
        
        player.replaceCurrentItem(with: playerItem)
        
        observe(player: player)
        observe(playerItem: playerItem)
    }
    
    /// Replay video.
    ///
    /// - Parameter resetCount: Reset replayCount
    open func replay(resetCount: Bool = false) {
        replayCount = resetCount ? 0 : replayCount + 1
        player?.seek(to: .zero)
        resume()
    }
    
    /// Continue playing video.
    open func resume() {
        pausedReason = .waitingKeepUp
        player?.playImmediately(atRate: speedRate)
    }
    
    /// Pause video.
    open func pause() {
        player?.pause()
    }
    
    /// Moves the playback cursor and invokes the specified block when the seek operation has either been completed or been interrupted.
    open func seek(to time: CMTime, completion: ((Bool) -> Void)? = nil) {
        player?.seek(to: time) { completion?($0) }
    }
    
    /// Moves the playback cursor within a specified time bound and invokes the specified block when the seek operation has either been completed or been interrupted.
    open func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completion: @escaping (Bool) -> Void) {
        player?.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completion)
    }
    
    /// Requests invocation of a block when specified times are traversed during normal playback.
    @discardableResult
    @nonobjc open func addBoundaryTimeObserver(forTimes times: [CMTime], queue: DispatchQueue? = nil, using: @escaping () -> Void) -> Any? {
        return player?.addBoundaryTimeObserver(forTimes: times.map { NSValue(time: $0) }, queue: queue, using: using)
    }
    
    /// Requests invocation of a block during playback to report changing time.
    @discardableResult
    open func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue? = nil, using: @escaping (CMTime) -> Void) -> Any? {
        return player?.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: using)
    }
    
    /// Cancels a previously registered periodic or boundary time observer.
    open func removeTimeObserver(_ observer: Any) {
        player?.removeTimeObserver(observer)
    }

    public func destroy() {
        player = nil
        NotificationCenter.default.removeObserver(self)
        removeFromSuperview()
    }

    open func playAudioTrack(index: Int) {
        guard
            let asset = player?.currentItem?.asset,
            let group = asset.mediaSelectionGroup(
                forMediaCharacteristic: AVMediaCharacteristic.audible
            ),
            group.options.count > index
        else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.player?.currentItem?.select(group.options[index], in: group)
        }
    }
}

public extension VideoPlayerView {
    
    /// Pause video.
    ///
    /// - Parameter reason: Reason for pause
    func pause(reason: PausedReason) {
        pausedReason = reason
        pause()
    }
}

private extension VideoPlayerView {
    
    func configureInit() {
        
        isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        layer.addSublayer(playerLayer)
    }
    
    func stateDidChanged(state: State, previous: State) {
        
        guard state != previous else {
            return
        }
        
        switch state {
        case .playing, .paused: isHidden = false
        default:                isHidden = true
        }
        
        stateDidChanged?(state)
    }
    
    func observe(player: AVPlayer?) {
        
        guard let player = player else {
            playerLayerReadyForDisplayObservation = nil
            playerTimeControlStatusObservation = nil
            return
        }
        
        playerLayerReadyForDisplayObservation = playerLayer.observe(\.isReadyForDisplay) { [unowned self, unowned player] playerLayer, _ in
            if playerLayer.isReadyForDisplay, player.rate > 0 {
                self.isLoaded = true
                self.state = .playing
            }
        }
        
        playerTimeControlStatusObservation = player.observe(\.timeControlStatus) { [unowned self] player, _ in
            switch player.timeControlStatus {
            case .paused:
                guard !self.isReplay else { break }
                self.state = .paused(playProgress: self.playProgress, bufferProgress: self.bufferProgress)
                if self.pausedReason == .waitingKeepUp { player.playImmediately(atRate: speedRate) }
            case .waitingToPlayAtSpecifiedRate:
                break
            case .playing:
                if self.playerLayer.isReadyForDisplay, player.rate > 0 {
                    self.isLoaded = true
                    if self.playProgress == 0, self.isReplay { self.isReplay = false; break }
                    self.state = .playing
                }
            @unknown default:
                break
            }
        }
    }
    
    func observe(playerItem: AVPlayerItem?) {
        
        guard let playerItem = playerItem else {
            playerBufferingObservation = nil
            playerItemStatusObservation = nil
            playerItemKeepUpObservation = nil
            return
        }
        
        playerBufferingObservation = playerItem.observe(\.loadedTimeRanges) { [unowned self] item, _ in
            if case .paused = self.state, self.pausedReason != .hidden {
                self.state = .paused(playProgress: self.playProgress, bufferProgress: self.bufferProgress)
            }
            
            if self.bufferProgress >= 0.99 || (self.currentBufferDuration - self.currentDuration) > 3 {
                VideoPreloadManager.shared.start()
            } else {
                VideoPreloadManager.shared.pause()
            }
        }
        
        playerItemStatusObservation = playerItem.observe(\.status) { [unowned self] item, _ in
            if item.status == .failed, let error = item.error as NSError? {
                self.state = .error(error)
            }
        }
        
        playerItemKeepUpObservation = playerItem.observe(\.isPlaybackLikelyToKeepUp) { [unowned self] item, _ in
            if item.isPlaybackLikelyToKeepUp {
                if self.player?.rate == 0, self.pausedReason == .waitingKeepUp {
                    self.player?.playImmediately(atRate: speedRate)
                }
            }
        }
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        guard (notification.object as? AVPlayerItem) == player?.currentItem else {
            return
        }
        
        playToEndTime?()
        
        guard isAutoReplay, pausedReason == .waitingKeepUp else {
            return
        }
        
        isReplay = true
        
        replay?()
        replayCount += 1
        
        player?.seek(to: CMTime.zero)
        player?.playImmediately(atRate: speedRate)
    }
    
}

extension VideoPlayerView.State: Equatable {
    
    public static func == (lhs: VideoPlayerView.State, rhs: VideoPlayerView.State) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.loading, .loading):
            return true
        case (.playing, .playing):
            return true
        case let (.paused(p1, b1), .paused(p2, b2)):
            return (p1 == p2) && (b1 == b2)
        case let (.error(e1), .error(e2)):
            return e1 == e2
        default:
            return false
        }
    }
    
}
#endif
