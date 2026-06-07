//
//  VideoDownloader.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//

import Foundation

public protocol VideoDownloaderDelegate: AnyObject {
    
    func downloader(_ downloader: VideoDownloader, didReceive response: URLResponse)
    func downloader(_ downloader: VideoDownloader, didReceive data: Data)
    func downloader(_ downloader: VideoDownloader, didFinished error: Error?)
    
}

public class VideoDownloader {
    
    public weak var delegate: VideoDownloaderDelegate?
    
    public let url: URL
    
    var info: VideoInfo? { return cacheHandler.configuration.info }
    
    private let cacheHandler: VideoCacheHandler
    private var downloaderHandler: VideoDownloaderHandler?
    
    public init(url: URL, cacheHandler: VideoCacheHandler) {
        self.url = url
        self.cacheHandler = cacheHandler
    }
    
    public func downloadToEnd(from offset: Int) {
        download(from: offset, length: (info?.contentLength ?? offset) - offset)
    }
    
    public func download(from offset: Int, length: Int) {
        let actions = cacheHandler.actions(for: NSRange(location: offset, length: length))

        downloaderHandler = VideoDownloaderHandler(url: url, actions: actions, cacheHandler: cacheHandler)
        downloaderHandler?.delegate = self
        downloaderHandler?.start()
    }
    
    public func resume() {
        downloaderHandler?.resume()
    }
    
    public func suspend() {
        downloaderHandler?.suspend()
    }
    
    public func cancel() {
        downloaderHandler?.cancel()
        downloaderHandler = nil
    }
    
}

extension VideoDownloader: VideoDownloaderHandlerDelegate {
    
    func handler(_ handler: VideoDownloaderHandler, didReceive response: URLResponse) {
        
        if info == nil, let httpResponse = response as? HTTPURLResponse {
            
            let contentLength = httpResponse.contentLength
            
            let contentType = httpResponse
                .value(forHeaderKey: "Content-Type") ?? ""
            
            let isByteRangeAccessSupported = httpResponse
                .value(forHeaderKey: "Accept-Ranges")?
                .contains("bytes") ?? false
            
            if contentLength > 0 {
                cacheHandler.set(info: VideoInfo(
                    contentLength: contentLength,
                    contentType: contentType,
                    isByteRangeAccessSupported: isByteRangeAccessSupported
                ))
            }
        }
        
        delegate?.downloader(self, didReceive: response)
    }
    
    func handler(_ handler: VideoDownloaderHandler, didReceive data: Data, isLocal: Bool) {
        delegate?.downloader(self, didReceive: data)
    }
    
    func handler(_ handler: VideoDownloaderHandler, didFinish error: Error?) {
        delegate?.downloader(self, didFinished: error)
    }
    
}

private extension HTTPURLResponse {
    
    var contentLength: Int {
        if let contentRangeLength = value(forHeaderKey: "Content-Range")?
            .split(separator: "/")
            .last
            .flatMap({ String($0).int }),
           contentRangeLength > 0 {
            return contentRangeLength
        }
        
        if let contentLength = value(forHeaderKey: "Content-Length")?.int,
           contentLength > 0 {
            return contentLength
        }
        
        return expectedContentLength > 0 ? Int(expectedContentLength) : 0
    }
    
    func value(forHeaderKey key: String) -> String? {
        return allHeaderFields
            .first { $0.key.description.caseInsensitiveCompare(key) == .orderedSame }?
            .value as? String
    }
    
}
