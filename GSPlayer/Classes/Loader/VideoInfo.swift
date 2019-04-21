//
//  VideoInfo.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//

import Foundation

struct VideoInfo: Codable {
    
    var contentLength: Int
    var contentType: String
    var isByteRangeAccessSupported: Bool
    
    init(contentLength: Int, contentType: String, isByteRangeAccessSupported: Bool) {
        self.contentLength = contentLength
        self.contentType = contentType
        self.isByteRangeAccessSupported = isByteRangeAccessSupported
    }
    
}
