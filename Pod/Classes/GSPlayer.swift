//
//  GSPlayer.swift
//  GSPlayer
//  https://github.com/wxxsw/GSPlayer
//
//  Copyright (c) 2016 Ge Sen
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import AVFoundation

class GSPlayer: AVPlayer {
    
    // MARK: - Shared Instance
    
    static let player = GSPlayer()
    
    // MARK: - Instance Properties
    
    // MARK: Internal
    
    var URL: NSURL?
    
    lazy var layer = AVPlayerLayer(player: GSPlayer.player)
    
    // MARK: Private
    
    // MARK: - Class Methods
    
    // MARK: Control
    
    class func play(URL: NSURL) {
        player.layer.removeFromSuperlayer()
        player.replaceCurrentItemWithURL(URL)
        player.play()
    }
    
    class func pause() {
        player.pause()
    }
    
    class func reset() {
        player.layer.removeFromSuperlayer()
        player.replaceCurrentItemWithURL(nil)
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    // MARK: - Private Methods
    
    private func isCurrentURL(URL: NSURL?) -> Bool {
        return (self.URL != nil) && (self.URL == URL)
    }
    
    private func replaceCurrentItemWithURL(URL: NSURL?) {
        if let URL = URL {
            replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: URL))
        } else {
            replaceCurrentItemWithPlayerItem(nil)
        }
        self.URL = URL
    }

}

// MARK: - PlayerView

extension GSPlayer {
    
    class func reusePlayerToView(view: UIView, withURL URL: NSURL) {
        if player.isCurrentURL(URL) {
            insertPlayerToView(view)
        } else {
            removePlayerFromView(view)
        }
    }
    
    class func insertPlayerToView(view: UIView) {
        view.layer.addSublayer(player.layer)
    }
    
    class func layoutPlayerToFrame(frame: CGRect, withURL URL: NSURL?) {
        if player.isCurrentURL(URL) {
            GSPlayer.player.layer.frame = frame
        }
    }
    
    class func removePlayerFromView(view: UIView) {
        for sublayer in view.layer.sublayers ?? [] {
            if sublayer == player.layer {
                reset()
                break
            }
        }
    }
    
}
