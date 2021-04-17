//
//  GSPlayerControlUIView.swift
//  Spotlighter
//
//  Created by Abdullah Ibrahim on 28.02.2021.
//

import UIKit
import CoreMedia
import GSPlayer

@IBDesignable
class GSPlayerControlUIView: UIView {
    
    // MARK: IBOutlet
    @IBOutlet weak var play_Button: UIButton!
    @IBOutlet weak var duration_Slider: UISlider!
    @IBOutlet weak var currentDuration_Label: UILabel!
    @IBOutlet weak var totalDuration_Label: UILabel!
    
    // MARK: Variables
    private var videoPlayer: VideoPlayerView!
    
    // MARK: Listeners
    var onStateDidChanged: ((VideoPlayerView.State) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.commonInit()
    }
    
    func commonInit() {
        guard let view = Bundle(for: GSPlayerControlUIView.self).loadNibNamed("GSPlayerControlUIView", owner: self, options: nil)?.first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.isUserInteractionEnabled = false
        
        self.addSubview(view)
    }
}

// MARK: Functions
extension GSPlayerControlUIView {
    
    func populate(with videoPlayer: VideoPlayerView) {
        self.videoPlayer = videoPlayer
        self.isUserInteractionEnabled = true
        
        setPeriodicTimer()
        setOnClicked_VideoPlayer()
        setStateDidChangedListener()
        
        duration_Slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSlider(_:))))
    }
    
    private func setStateDidChangedListener()  {
        videoPlayer.stateDidChanged = { [weak self] state in
            guard let self = self else { return }
            
            if case .playing = state {
                self.setOnStartPlaying()
            }
                
            switch state {
            case .playing, .paused: self.duration_Slider.isEnabled = true
            default: self.duration_Slider.isEnabled = false
            }
                
            self.play_Button.setImage(state == .playing ? UIImage(named: "pause_48px") : UIImage(named: "play_48px"), for: .normal)
                
            if let listener = self.onStateDidChanged { listener(state) }
        }
        
        videoPlayer.replay = { [weak self] in
            if self != nil
            {
                self!.currentDuration_Label.text = "00:00"
                self!.duration_Slider.setValue(0, animated: false)
            }
        }
    }
    
    private func setOnStartPlaying() {
        let totalDuration = videoPlayer.totalDuration
        
        duration_Slider.maximumValue = Float(totalDuration)
        totalDuration_Label.text = getTimeString(seconds: Int(totalDuration))
    }
    
    private func setPeriodicTimer() {
        videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), using: { [weak self] _ in
            if self != nil
            {
                let currentDuration = self!.videoPlayer.currentDuration
                self!.currentDuration_Label.text = self!.getTimeString(seconds: Int(currentDuration))
                self!.duration_Slider.setValue(Float(currentDuration), animated: true)
            }
        })
    }
    
    private func getTimeString(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: onClicked
extension GSPlayerControlUIView {
    
    @IBAction func onClicked_Play(_ sender: Any) {
        if (videoPlayer.state == .playing) {
            videoPlayer.pause(reason: .userInteraction)
        } else {
            videoPlayer.resume()
        }
    }
    
    @IBAction func onClicked_Backward(_ sender: Any) {
        videoPlayer.seek(to: CMTime(seconds: Double(max(videoPlayer.currentDuration - 10, 0)), preferredTimescale: 60))
    }
    
    @IBAction func onClicked_Forward(_ sender: Any) {
        videoPlayer.seek(to: CMTime(seconds: Double(min(videoPlayer.currentDuration + 10, videoPlayer.totalDuration)), preferredTimescale: 60))
    }
    
    private func setOnClicked_VideoPlayer() {
        videoPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicked_Video(_:))))
    }
    
    @IBAction func onClicked_Video(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.alpha = self.alpha == 0 ? 1 : 0
        }
    }
    
    @IBAction func tapSlider(_ gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self)
        
        let positionOfSlider: CGPoint = duration_Slider.frame.origin
        let widthOfSlider: CGFloat = duration_Slider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(duration_Slider.maximumValue) / widthOfSlider)
        
        duration_Slider.setValue(Float(newValue), animated: false)
        onValueChanged_DurationSlider(duration_Slider)
    }
    
    @IBAction func onValueChanged_DurationSlider(_ sender: UISlider) {
        videoPlayer.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: 60))
    }
}
