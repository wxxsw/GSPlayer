![GSPlayer](https://github.com/wxxsw/GSPlayer/blob/master/ScreenShots/logo.png)

<p align="center">
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift5-f48041.svg?style=flat"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS10+-blue.svg?style=flat"></a>
<a href="http://cocoadocs.org/docsets/GSPlayer"><img src="https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/wxxsw/GSPlayer/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat"></a>
</p>

## Features

- [x] Fully customizable UI.
- [x] Easy to use API and callbacks.
- [x] Built-in caching mechanism to support playback while downloading.
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
playerView.play(for: URL(string: "video url...")!)
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
