//
//  AVAssetResourceLoadingRequest+Extensions.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/21.
//  Copyright © 2019 Gesen. All rights reserved.
//

import AVFoundation

extension AVAssetResourceLoadingRequest {
    
    var url: URL? {
        request.url?.deconstructed
    }
    
}
