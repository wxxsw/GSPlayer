//
//  VideoRequestLoader.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//

import AVFoundation

protocol VideoRequestLoaderDelegate: AnyObject {
    
    func loader(_ loader: VideoRequestLoader, didFinish error: Error?)
    
}

class VideoRequestLoader {

    weak var delegate: VideoRequestLoaderDelegate?

    let request: AVAssetResourceLoadingRequest

    private let downloader: VideoDownloader
    private var infoFilled = false
    private let queue = DispatchQueue(label: "gsplayer.loader.\(UUID().uuidString)")
    private var finished = false   // 标记避免 finish 后继续 respond

    init(request: AVAssetResourceLoadingRequest, downloader: VideoDownloader) {
        self.request = request
        self.downloader = downloader
        self.downloader.delegate = self
        self.fulfillContentInfomation()
    }

    func start() {
        guard
            let dataRequest = request.dataRequest else {
            return
        }
        
        var offset = Int(dataRequest.requestedOffset)
        let length = Int(dataRequest.requestedLength)

        if dataRequest.currentOffset != 0 {
            offset = Int(dataRequest.currentOffset)
        }
        
        if dataRequest.requestsAllDataToEndOfResource {
            downloader.downloadToEnd(from: offset)
        } else {
            downloader.download(from: offset, length: length)
        }
    }

    func cancel() {
        finished = true
        downloader.cancel()
    }

    func finish() {
        queue.async {
            guard !self.finished else { return }
            self.finished = true
            if !self.request.isCancelled {
                self.request.finishLoading(with: NSError(
                    domain: "me.gesen.player.loader",
                    code: NSURLErrorCancelled,
                    userInfo: [NSLocalizedDescriptionKey: "Video load request is canceled"]
                ))
            }
        }
    }

}

extension VideoRequestLoader: VideoDownloaderDelegate {
    
    func downloader(_ downloader: VideoDownloader, didReceive response: URLResponse) {
        fulfillContentInfomation()
    }
    
    func downloader(_ downloader: VideoDownloader, didReceive data: Data) {
        guard !finished,
              let req = request.dataRequest,
              !request.isCancelled,
              !data.isEmpty else { return }

        // 严格按 requestedOffset / currentOffset / requestedLength 切片
        queue.async { [weak self] in
            guard let self = self,
                  let req = self.request.dataRequest,
                  !self.request.isCancelled,
                  !self.finished else { return }

            let requestedOffset = req.currentOffset == 0
            ? req.requestedOffset
            : req.currentOffset
            let requestedLength = Int64(req.requestedLength)

            // 这里假设 data 是从 fileOffset 开始的一段连续片段，若不是，请根据你 Downloader 的语义传入正确的 fileOffset
            // 如果无法准确定位 data 对应的全局 offset，建议把 Downloader 按照 request 的 offset 精确拉取，避免“盲喂”
            let fileOffset: Int64 = requestedOffset   // 关键：与上游保持一致
            let start = Int(requestedOffset - fileOffset)
            guard start >= 0, start < data.count else { return }

            var remain = min(Int(requestedLength), data.count - start)
            let chunkSize = 64 * 1024 // 64KB 小包，避免深层拷贝/重入

            while remain > 0 && !self.request.isCancelled && !self.finished {
                let len = min(chunkSize, remain)
                let end = start + (Int(req.currentOffset - requestedOffset)) + len
                let begin = end - len
                guard begin >= 0, end <= data.count else { break }

                let chunk = data.subdata(in: begin..<end)
                if !chunk.isEmpty {
                    req.respond(with: chunk)
                }
                remain -= len
            }
        }
    }

    func downloader(_ downloader: VideoDownloader, didFinished error: Error?) {
        queue.async { [weak self] in
            guard let self = self, !self.finished else { return }
            self.finished = true

            guard (error as NSError?)?.code != NSURLErrorCancelled else { return }

            if let error {
                self.request.finishLoading(with: error)
            } else {
                self.request.finishLoading()
            }
            self.delegate?.loader(self, didFinish: error)
        }
    }

}

private extension VideoRequestLoader {

    func fulfillContentInfomation() {
        queue.async {
            guard !self.infoFilled,
                  let info = self.downloader.info,
                  let cir = self.request.contentInformationRequest else { return }

            cir.contentType = info.contentType
            cir.contentLength = Int64(info.contentLength)
            cir.isByteRangeAccessSupported = info.isByteRangeAccessSupported
            self.infoFilled = true
        }
    }

}
