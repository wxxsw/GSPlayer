//
//  FeedCell.swift
//  GSPlayer_Example
//
//  Created by Gesen on 2020/5/17.
//  Copyright © 2020 Gesen. All rights reserved.
//

import GSPlayer

class FeedCell: UITableViewCell {

    @IBOutlet weak var playerView: VideoPlayerView!
    
    private var url: URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerView.isHidden = true
    }
    
    func set(url: URL) {
        self.url = url
    }
    
    func play() {
        playerView.play(for: url)
        playerView.isHidden = false
    }
    
    func pause() {
        playerView.pause(reason: .hidden)
    }
}
