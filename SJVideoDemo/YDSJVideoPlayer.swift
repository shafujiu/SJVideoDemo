//
//  YDSJVideoPlayer.swift
//  SJVideoDemo
//
//  Created by Shafujiu on 2020/12/15.
//

import UIKit
import SJVideoPlayer

class YDSJVideoPlayer: SJVideoPlayer {
    
    typealias YDSJVideoPlayerReachabilityChangeBlock = (_ r: SJReachabilityProtocol)->()
    typealias YDSJVideoPlayerPlaybackDidFinishBlock = (_ r: SJBaseVideoPlayer)->()
    var reachabilityChangeBlock: YDSJVideoPlayerReachabilityChangeBlock? {
        didSet {
            reachabilityObserver.networkStatusDidChangeExeBlock = reachabilityChangeBlock
        }
    }
    
    var playbackDidFinishBlock: YDSJVideoPlayerPlaybackDidFinishBlock? {
        didSet {
            playbackObserver.playbackDidFinishExeBlock = playbackDidFinishBlock
        }
    }
    
    
    override init() {
        super.init()
        setupConfig()
    }
    
    private func setupConfig() {
        addCustomControlLayerToSwitcher()
        setIJKMediaPlaybackController()
        
//        reachabilityObserver.networkStatusDidChangeExeBlock = reachabilityChangeBlock
            
//            { [weak self] r in
//            print("sfj_\(r.networkStatus)", r.networkSpeedStr)
//        }
//        playbackObserver.playbackDidFinishExeBlock = { [weak self] player in
//            print("sfj_播放结束")
//        }
    }
    
    
    
    // 自定义控制层
    private func addCustomControlLayerToSwitcher() {
        self.switcher.addControlLayer(forIdentifier: SJControlLayer_Edge) { (identifer) -> SJControlLayer in
            YDEdgeControlLayerViewController()
        }
    }
    
    private func setIJKMediaPlaybackController() {
        let controller = SJIJKMediaPlaybackController()
        controller.options = IJKFFOptions.byDefault()
        self.playbackController = controller
    }
    
    
}
