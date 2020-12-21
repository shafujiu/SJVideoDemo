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
    var player = SJVideoPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        player = SJVideoPlayer()
        
        
        addCustomControlLayerToSwitcher()
        
//        let bottomAdapter = player.defaultEdgeControlLayer.bottomAdapter
        
//        let progressItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Progress)!
//        progressItem.insets = SJEdgeInsets(front: -4, rear: 8)
        // 进度条
//        let slider = progressItem.customView as? SJProgressSlider
//        slider?.setThumbCornerRadius(4, size: CGSize(width: 8, height: 8), thumbBackgroundColor: #colorLiteral(red: 0.9672872424, green: 0.6626139879, blue: 0.09413511306, alpha: 1))
        
//        SJEdgeControlButtonItem
//        let fullitem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_FullBtn)
//        fullitem?.placeholderType
        
//        player.defaultEdgeControlLayer.loadingView = YDVideoLoadingView()
        
//        player.defaultEdgeControlLayer.fastForwardView = YDVideoFastForwardView()
        
        
        
//        player.defaultEdgeControlLayer.draggingProgressPopView = YDVideoDraggingProgressPopView()
        
//        SJVideoPlayer.update { commonSettings in
//            commonSettings.pauseBtnImage = UIImage(named: "icon_v_stop")
//            commonSettings.playBtnImage = UIImage(named: "icon_v_play")
//
//            commonSettings.fullBtnImage = UIImage(named: "icon_full_screen")
//            commonSettings.shrinkscreenImage = nil
//            commonSettings.forwardImage = UIImage(named: "icon_forward")
//            commonSettings.fastImage = UIImage(named: "icon_fast")
//
//            commonSettings.progress_trackColor = #colorLiteral(red: 0.29461658, green: 0.2946640551, blue: 0.2946062088, alpha: 1)
//            commonSettings.progress_traceHeight = 2
//            commonSettings.progress_traceColor = #colorLiteral(red: 0.9672872424, green: 0.6626139879, blue: 0.09413511306, alpha: 1)
//        }
        
       
        
        //
        
        
        
        
//        bottomAdapter.removeItem(forTag: SJEdgeControlLayerBottomItem_Progress)
//        bottomAdapter.insert(progressItem, at: 1)
//        bottomAdapter.reload()
        
//        let playItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Play)
        
        let controller = SJIJKMediaPlaybackController()
        controller.options = IJKFFOptions.byDefault()
        player.playbackController = controller
        let url = "http://hls.cntv.myalicdn.com/asp/hls/450/0303000a/3/default/bca293257d954934afadfaa96d865172/450.m3u8"
        let asset = SJVideoPlayerURLAsset(url: URL(string: url)!)
        player.urlAsset = asset
        player.view.backgroundColor = .orange
        asset?.attributedTitle = NSAttributedString.sj_UIKitText({ (make) in
            let _ = make.append("这是视频的title").textColor(.white)
        })
        player.view.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        self.view.addSubview(player.view)
        
    }

    // 自定义控制层
    private func addCustomControlLayerToSwitcher() {
        player.switcher.addControlLayer(forIdentifier: SJControlLayer_Edge) { (identifer) -> SJControlLayer in
            SJCustomControlLayerViewController()
        }
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

class YDVideoLoadingView: UIView, SJLoadingViewProtocol {
    private lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .whiteLarge
        return view
    }()
    
    private lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .white
        lbl.text = "加载中"
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubViews() {
        
//        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        backgroundColor = .clear
        layer.cornerRadius = 4
        addSubview(activityView)
        addSubview(titleLbl)
        activityView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-52)
            make.width.height.equalTo(40)
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.top.equalTo(activityView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    
    // MARK: - SJLoadingViewProtocol
    var isAnimating: Bool {
        activityView.isAnimating
    }
    
    var showNetworkSpeed: Bool = true
    
    var networkSpeedStr: NSAttributedString? = nil
    
    func start() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        } completion: { (_) in
            self.activityView.startAnimating()
        }

    }
    
    func stop() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (_) in
            self.activityView.stopAnimating()
        }
    }
}



