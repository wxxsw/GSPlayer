//
//  TableViewController.swift
//  GSPlayer
//
//  Created by Gesen on 16/4/7.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import GSPlayer

class TableViewController: UITableViewController {
    
    let data = ["http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
                "http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                "http://baobab.wdjcdn.com/14525705791193.mp4",
                "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                "http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                "http://baobab.wdjcdn.com/1455782903700jy.mp4",
                "http://baobab.wdjcdn.com/14564977406580.mp4",
                "http://baobab.wdjcdn.com/1456316686552The.mp4",
                "http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                "http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                "http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                "http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                "http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                "http://baobab.wdjcdn.com/1456734464766B(13).mp4",
                "http://baobab.wdjcdn.com/1456653443902B.mp4",
                "http://baobab.wdjcdn.com/1456231710844S(24).mp4"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        GSPlayerTableObserver.sharedInstance.observeTableView(tableView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        GSPlayerTableObserver.sharedInstance.unobserveTableView(tableView)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        let videoURL = NSURL(string: data[indexPath.row])!
        
        cell.playerView.setVideoURL(videoURL,
                                    inTableView: tableView,
                                    atIndexPath: indexPath)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        cell.playerView.play()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.width * 9 / 16
    }

}
