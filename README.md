![GSPlayer](https://github.com/wxxsw/GSPlayer/blob/master/ScreenShots/logo.png)

<p align="center">
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift5-f48041.svg?style=flat"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS10+|macOS-blue.svg?style=flat"></a>
<a href="http://cocoadocs.org/docsets/GSPlayer"><img src="https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/wxxsw/GSPlayer/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat"></a>
</p>

## Features

- [x] Fully customizable UI.
- [x] Easy to use API and callbacks.
- [x] Built-in caching mechanism to support playback while downloading (mp4).
- [x] Can preload multiple videos at any time.
- [x] Can be embedded into UITableView and UICollectionView.
- [x] Provide full screen transition.
- [ ] Complete Demo.

## Quick Start

1. Add `VideoPlayerView` to the interface.
```swift
let playerView = VideoPlayerView()
view.addSubview(playerView)

// Or in IB, specify the type of custom View as VideoPlayerView.
```

2. Play Video.
```swift
playerView.play(for: someURL)
```

3. Pause/Resume Video.
```swift
if playerView.state == .playing {
    playerView.pause(reason: .userInteraction)
} else {
    playerView.resume()
}
```

4. Update control UI based on playback status.
```swift
playerView.stateDidChanged = { state in
    switch state {
    case .none:
        print("none")
    case .error(let error):
        print("error - \(error.localizedDescription)")
    case .loading:
        print("loading")
    case .paused(let playing, let buffering):
        print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
    case .playing:
        print("playing")
    }
}
```

## Documents

### Cache

Get the total size of the video cache.
```swift
VideoCacheManager.calculateCachedSize()
```

Clean up all caches.
```swift
VideoCacheManager.cleanAllCache()
```

### Preload

Set the video URL to be preloaded. Preloading will automatically cache a short segment of the beginning of the video and decide whether to start or pause the preload based on the buffering of the currently playing video.
```swift
VideoPreloadManager.shared.set(waiting: [URL])
```

Set the preload size, the default value is 1024 * 1024, unit is byte.
```swift
VideoPlayer.preloadByteCount = 1024 * 1024 // = 1M
```

### Fullscreen

See demo.

### PlayerView

#### Property

An object that manages a player's visual output.
```swift
public let playerLayer: AVPlayerLayer { get }
```

Get current video status.
```swift
public enum State {

    /// None
    case none

    /// From the first load to get the first frame of the video
    case loading

    /// Playing now
    case playing

    /// Pause, will be called repeatedly when the buffer progress changes
    case paused(playing: Double, buffering: Double)

    /// An error occurred and cannot continue playing
    case error(NSError)
}

public var state: State { get }
```

The reason the video was paused.
```swift
public enum PausedReason {

    /// Pause because the player is not visible, stateDidChanged is not called when the buffer progress changes
    case hidden

    /// Pause triggered by user interaction, default behavior
    case userInteraction

    /// Waiting for resource completion buffering
    case waitingKeepUp
}

public var pausedReason: PausedReason { get }
```

Number of replays.
```swift
public var replayCount: Int { get }
```

Played progress, value range 0-1.
```swift
public var playing: Double { get }
```

Played length in seconds.
```swift
public var currentDuration: Double { get }
```

Buffered progress, value range 0-1.
```swift
public var buffering: Double { get }
```

Buffered length in seconds.
```swift
public var currentBufferDuration: Double { get }
```

Total video duration in seconds.
```swift
public var totalDuration: Double { get }
```

The total watch time of this video, in seconds.
```swift
public var watchDuration: Double { get }
```

Whether the video is muted, only for this instance.
```swift
public var isMuted: Bool { get set }
```

Video volume, only for this instance.
```swift
public var volume: Double { get set }
```

#### Callback

Playback status changes, such as from play to pause.
```swift
public var stateDidChanged: ((State) -> Void)?
```

Replay after playing to the end.
```swift
public var replay: (() -> Void)?
```

#### Method

Play a video of the specified url.
```swift
func play(for url: URL)
```

Pause video.
```swift
func pause(reason: PausedReason)
```

Continue playing video.
```swift
func resume()
```

## Installation

GSPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GSPlayer'
```

## Contribution

### Issue

If you find a bug or need a help, you can [create a issue](https://github.com/wxxsw/GSPlayer/issues/new)

### Pull Request

We are happy to accept pull requests :D. But please make sure it's needed by most developers and make it simple to use. If you are not sure, create an issue and we can discuss it before you get to coding.

## License

The MIT License (MIT)
