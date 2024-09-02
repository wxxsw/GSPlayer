//
//  URL+Extensions.swift
//  GSPlayer
//
//  Created by Graeme Harrison on 2024/8/30.
//  Copyright © 2024 Graeme Harrison. All rights reserved.
//

import AVFoundation

extension URL {
    private static let videoExtension = "mp4"
    private static let prefix = AVPlayerItem.loaderPrefix
    
    func forceMP4() -> URL? {
        guard pathExtension != Self.videoExtension else { return self }
        
        return deletingPathExtension().appendingPathExtension(Self.videoExtension)
    }
    
    func addPrefix() -> URL? {
        (Self.prefix + absoluteString).url
    }
    
    func removePrefix() -> URL? {
        guard absoluteString.hasPrefix(Self.prefix) else { return nil }
        
        return absoluteString.replacingOccurrences(of: Self.prefix, with: "").url
    }
}
