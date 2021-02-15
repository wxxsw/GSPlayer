//
//  BasicViewController.swift
//  GSPlayer_Example
//
//  Created by Gesen on 2019/4/21.
//  Copyright © 2019 Gesen. All rights reserved.
//

import UIKit
import CoreMedia
import GSPlayer

class BasicViewController: UIViewController {

    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Basic"
        
        playerView.stateDidChanged = { [weak self] state in
            guard let `self` = self else { return }
            
            switch state {
            case .none:
                self.stateLabel.text = "none"
            case .error(let error):
                self.stateLabel.text = "error - \(error.localizedDescription)"
            case .loading:
                self.stateLabel.text = "loading"
            case .paused(let playing, let buffering):
                self.stateLabel.text = "paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%"
            case .playing:
                self.stateLabel.text = "playing"
            }
            
            switch state {
            case .playing, .paused:
                self.progressSlider.isEnabled = true
            default:
                self.progressSlider.isEnabled = false
            }
        }
        
        playerView.contentMode = .scaleAspectFill
        playerView.play(for: URL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)
        
        playerView.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), using: { [weak self] _ in
            guard let self = self else { return }
            
            self.progressSlider.value = Float(self.playerView.currentDuration / self.playerView.totalDuration)
        })
        
        progressSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSlider(_:))))
    }
    
    @IBAction func tapPlay(_ sender: UIButton) {
        if playerView.state == .playing {
            playerView.pause(reason: .userInteraction)
        } else {
            playerView.resume()
        }
    }
    
    @IBAction func tapMute(_ sender: UIButton) {
        playerView.isMuted.toggle()
    }
    
    @IBAction func tapFullscreen(_ sender: UIButton) {
        let vc = BasicFullscreenViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.transitioner.playerView = playerView
        vc.transitioningDelegate = vc.transitioner
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func tapSlider(_ gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)

        let positionOfSlider: CGPoint = progressSlider.frame.origin
        let widthOfSlider: CGFloat = progressSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(progressSlider.maximumValue) / widthOfSlider)

        progressSlider.setValue(Float(newValue), animated: false)
        sliderValueChanged(progressSlider)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let time = CMTime(seconds: playerView.totalDuration * Double(sender.value), preferredTimescale: 60)
        playerView.seek(to: time)
    }
}
