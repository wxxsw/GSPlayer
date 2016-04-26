//
//  TableViewCell.swift
//  GSPlayer
//
//  Created by Gesen on 16/4/7.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import GSPlayer

class TableViewCell: UITableViewCell {

    @IBOutlet weak var playerView: GSPlayerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
