//
//  ViewController.swift
//  GSPlayer
//
//  Created by Ge Sen on 04/06/2016.
//  Copyright (c) 2016 Ge Sen. All rights reserved.
//

import UIKit
import GSPlayer

class ViewController: UIViewController {

    @IBOutlet weak var playerView: GSPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.setVideoURL(NSURL(string: "http://baobab.wdjcdn.com/14559682994064.mp4")!)
        playerView.play()
    }

}

