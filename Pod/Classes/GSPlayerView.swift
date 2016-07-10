//
//  GSPlayerView.swift
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

import UIKit

public class GSPlayerView: UIView {
    
    // MARK: Public
    
    public func setVideoURL(URL: NSURL) {
        self.URL = URL
    }
    
    public func setVideoURL(URL: NSURL,
                            inTableView tableView: UITableView,
                            atIndexPath indexPath: NSIndexPath) {
        self.URL = URL
        self.tableView = tableView
        self.indexPath = indexPath
        
        GSPlayer.reusePlayerToView(self, withURL: URL)
    }

    public func play() {
    
        guard let URL = URL else {
            print("GSPlayer ERROR: Not set videoURL!")
            return
        }
        
        GSPlayer.play(URL)
        GSPlayer.insertPlayerToView(self)
    }
    
    public func pause() {
        GSPlayer.pause()
    }
    
    public func reset() {
        GSPlayer.reset()
    }
    
    // MARK: Override
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        GSPlayer.layoutPlayerToFrame(bounds, withURL: URL)
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        GSPlayer.removePlayerFromView(self)
    }
    
    // MARK: Private
    
    var URL: NSURL?

    weak var tableView: UITableView?
         var indexPath: NSIndexPath?

}
