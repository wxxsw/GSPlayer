//
//  AVPlayer+Extensions.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/21.
//  Copyright © 2019 Gesen. All rights reserved.
//

import AVFoundation
#if !os(macOS)
import UIKit
#else
import AppKit
#endif

public extension AVPlayer {
    
    var bufferProgress: Double {
        return currentItem?.bufferProgress ?? -1
    }
    
    var currentBufferDuration: Double {
        return currentItem?.currentBufferDuration ?? -1
    }
    
    var currentDuration: Double {
        return currentItem?.currentDuration ?? -1
    }
    
    #if !os(macOS)
    var currentImage: UIImage? {
        guard
            let playerItem = currentItem,
            let cgImage = try? AVAssetImageGenerator(asset: playerItem.asset).copyCGImage(at: currentTime(), actualTime: nil)
            else { return nil }

        return UIImage(cgImage: cgImage)
    }
    #else
    var currentImage: NSImage? {
        guard
            let playerItem = currentItem,
            let cgImage = try? AVAssetImageGenerator(asset: playerItem.asset).copyCGImage(at: currentTime(), actualTime: nil)
        else {
            return nil
        }
        let width: CGFloat = CGFloat(cgImage.width)
        let height: CGFloat = CGFloat(cgImage.height)
        return NSImage(cgImage: cgImage, size: NSMakeSize(width, height))
    }
    #endif
    
    var playProgress: Double {
        return currentItem?.playProgress ?? -1
    }
    
    var totalDuration: Double {
        return currentItem?.totalDuration ?? -1
    }
    
    convenience init(asset: AVURLAsset) {
        self.init(playerItem: AVPlayerItem(asset: asset))
    }
    
}
