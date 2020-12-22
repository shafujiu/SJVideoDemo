//
//  ViewController.swift
//  SJVideoDemo
//
//  Created by Shafujiu on 2020/12/15.
//

import UIKit
import SJVideoPlayer
import SnapKit
import SJBaseVideoPlayer

class ViewController: UIViewController {
//    var player = SJVideoPlayer()
    var player = YDSJVideoPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        player.playbackDidFinishBlock = { [weak self] player in
            print("sfj_播放结束")
        }
        
        player.reachabilityChangeBlock = { [weak self] r in

            print("sfj_\(r.networkStatus)", r.networkSpeedStr)
        }
        
        
        let url = "http://hls.cntv.myalicdn.com/asp/hls/450/0303000a/3/default/bca293257d954934afadfaa96d865172/450.m3u8"
        let asset = SJVideoPlayerURLAsset(url: URL(string: url)!)
        player.urlAsset = asset
        
        asset?.attributedTitle = NSAttributedString.sj_UIKitText({ (make) in
            let _ = make.append("这是视频的title").textColor(.white)
        })
        player.view.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        self.view.addSubview(player.view)
        
        
        
       
    }
    

    
    // 全屏处理
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.vc_viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.vc_viewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.vc_viewDidDisappear()
    }
    
    override var shouldAutorotate: Bool {
        false
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}


