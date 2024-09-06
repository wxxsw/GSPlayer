//
//  URL+Extensions.swift
//  GSPlayer
//
//  Created by Graeme Harrison on 2024/8/30.
//  Copyright © 2024 Graeme Harrison. All rights reserved.
//

import AVFoundation

extension URL {
    
    /// `AVAssetResourceLoaderDelegate` doesn't get called for URLs starting with `http` or `https`; adding this temporary prefix to the URL works.
    private static let loaderPrefix = "loader-"
    
    /// `AVAssetResourceLoaderDelegate` doesn't get called for URLs with no extension; adding this temporary one works.
    private static let tempExtension = "mp4"
    
    /// This extra prefix is so that we know to remove the added temporary extension when it's time to play the URL, if applicable.
    private static let noExtensionPrefix = "noext-"
    
    var constructed: URL? {
        if pathExtension.isEmpty {
            let urlString = Self.loaderPrefix + Self.noExtensionPrefix + absoluteString
            return urlString.url?.appendingPathExtension(Self.tempExtension)
        } else {
            let urlString = Self.loaderPrefix + absoluteString
            return urlString.url
        }
    }
    
    var deconstructed: URL? {
        var urlString = absoluteString
        
        guard urlString.hasPrefix(Self.loaderPrefix) else { return nil }
        
        urlString = urlString.replacingOccurrences(of: Self.loaderPrefix, with: "")
        
        if urlString.hasPrefix(Self.noExtensionPrefix) {
            urlString = urlString.replacingOccurrences(of: Self.noExtensionPrefix, with: "")
            return urlString.url?.deletingPathExtension()
        }
        
        return urlString.url
    }
    
}
