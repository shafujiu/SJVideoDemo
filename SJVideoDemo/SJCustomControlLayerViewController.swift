//
//  SJCustomControlLayerViewController.swift
//  SJVideoDemo
//
//  Created by Shafujiu on 2020/12/15.
//

import UIKit
import SJVideoPlayer

class SJCustomControlLayerViewController: UIViewController {

    private var _restarted: Bool = false
    private var player: SJBaseVideoPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension SJCustomControlLayerViewController: SJControlLayer {
    
    
    func controlView() -> UIView! {
        view
    }
    
    var restarted: Bool {
        _restarted
    }
    ///
    /// 控制层入场
    ///     当播放器将要切换到此控制层时, 该方法将会被调用
    ///     可以在这里做入场的操作
    ///
    func restartControlLayer() {
        _restarted = true
        if self.player.isFullScreen {self.player.needHiddenStatusBar()}
        sj_view_makeAppear(self.controlView(), true)
    }
    
    ///
    /// 退出控制层
    ///     当播放器将要切换到其他控制层时, 该方法将会被调用
    ///     可以在这里处理退出控制层的操作
    ///
    func exitControlLayer() {
        _restarted = false
        
        sj_view_makeDisappear(self.controlView(), true) {
            if !self._restarted {
                self.controlView()?.removeFromSuperview()
            }
        }
    }
    ///
    /// 当controlView被添加到播放器时, 该方法将会被调用
    ///
    func installedControlView(to videoPlayer: SJBaseVideoPlayer!) {
        player = videoPlayer
    }
    
    ///
    /// 当调用播放器的controlLayerNeedAppear时, 播放器将会回调该方法
    ///
    func controlLayerNeedAppear(_ videoPlayer: SJBaseVideoPlayer!) {
        
    }
    ///
    /// 当调用播放器的controlLayerNeedDisappear时, 播放器将会回调该方法
    ///
    func controlLayerNeedDisappear(_ videoPlayer: SJBaseVideoPlayer!) {
        
    }
}
