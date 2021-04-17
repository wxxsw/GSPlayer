//
//  VideoFullscreenPlayerView.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//
#if !os(macOS)
import UIKit

public class VideoFullscreenPlayerView: UIView {

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let animation = layer.animation(forKey: "bounds.size") {
            CATransaction.begin()
            CATransaction.setAnimationDuration(animation.duration)
            CATransaction.setAnimationTimingFunction(animation.timingFunction)
            layer.sublayers?.forEach({ $0.frame = bounds })
            CATransaction.commit()
        } else {
            layer.sublayers?.forEach({ $0.frame = bounds })
        }
    }

}
#endif
