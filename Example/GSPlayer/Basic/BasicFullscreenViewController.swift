//
//  BasicFullscreenViewController.swift
//  GSPlayer_Example
//
//  Created by Gesen on 2019/4/21.
//  Copyright © 2019 Gesen. All rights reserved.
//

import UIKit
import GSPlayer

class BasicFullscreenViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var fullscreenPlayerView: VideoFullscreenPlayerView!
    
    lazy var transitioner: VideoFullscreenTransitioner = {
        loadViewIfNeeded()
        let transition = VideoFullscreenTransitioner()
        transition.fullscreenControls = [closeButton]
        transition.fullscreenPlayerView = fullscreenPlayerView
        transition.fullscreenVideoGravity = .resizeAspect
        return transition
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func tapClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
