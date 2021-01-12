//
//  SJCustomControlLayerViewController.swift
//  SJVideoDemo
//
//  Created by Shafujiu on 2020/12/15.
//

import UIKit
import SJVideoPlayer
//import SJBaseVideoPlayer


struct YDCustomVideoSettings {
    
    static let `default` = YDCustomVideoSettings()
    /// 轨迹颜色, 走过的痕迹
    var bottomIndicator_traceColor: UIColor {
        progress_traceColor
    }
    /// 轨迹颜色, 走过的痕迹
    var progress_traceColor: UIColor {
        #colorLiteral(red: 1, green: 0.6666666667, blue: 0.0862745098, alpha: 1)
    }
    // 轨道颜色
    var bottomIndicator_trackColor: UIColor {
        progress_trackColor
    }
    // 轨道颜色
    var progress_trackColor: UIColor {
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.39)
    }
    
    /// 缓冲颜色
    var progress_bufferColor: UIColor? {
        SJVideoPlayerSettings.common().progress_bufferColor
    }
    
    /// 缓冲高度
    var progress_traceHeight: CGFloat {
        1.5
    }
    
    // 网络不稳定文案
    var unstableNetworkPrompt: String {
        SJVideoPlayerSettings.common().unstableNetworkPrompt ?? "网络不稳定, 请检查网络"
    }
    // 非wifi 文案
    var cellularNetworkPrompt: String {
        SJVideoPlayerSettings.common().cellularNetworkPrompt ?? "当前非WiFi环境, 请注意流量消耗"
    }
    
    /// 返回图标
    var backBtnImage: UIImage? {
        SJVideoPlayerSettings.common().backBtnImage
    }
    
    /// 播放图标
    var playBtnImage: UIImage? {
        UIImage(named: "icon_v_play")
    }
    
    /// 暂停图标
    var pauseBtnImage: UIImage? {
        UIImage(named: "icon_v_stop")
    }
    /// 菊花圈圈的线颜色
    /// - 默认是白色
    var loadingLineColor: UIColor {
        .white
    }
    
    /// 拇指
    var progress_thumbImage: UIImage? = nil
    var progress_thumbSize: CGFloat {
        8
    }
    var progress_thumbColor: UIColor {
        progress_traceColor
    }
    // 全屏 -> 缩小
    var shrinkscreenImage: UIImage? {
        nil
    }
    // 全屏
    var fullBtnImage: UIImage? {
        UIImage(named: "icon_full_screen")
    }
    @available(iOS 14.0, *)
    var pictureInPictureItemStopImage: UIImage? {
        SJVideoPlayerSettings.common().pictureInPictureItemStopImage
    }
    @available(iOS 14.0, *)
    var pictureInPictureItemStartImage: UIImage? {
        SJVideoPlayerSettings.common().pictureInPictureItemStartImage
    }
    // 时间label
    var timeFont: UIFont {
        UIFont.systemFont(ofSize: 9, weight: .heavy)
    }
    
    var timeColor: UIColor {
        .white
    }
    
    // 拖拽弹窗
    var fastImage: UIImage? {
        UIImage(named: "icon_fast")
    }
    
    var forwardImage: UIImage? {
        UIImage(named: "icon_forward")
    }
    
    //
    var replayBtnFont: UIFont {
        SJVideoPlayerSettings.common().replayBtnFont ?? UIFont.systemFont(ofSize: 10)
    }
    
    var replayBtnTitleColor: UIColor {
        SJVideoPlayerSettings.common().replayBtnTitleColor ?? UIColor.white
    }
    
    var replayBtnImage: UIImage? {
        SJVideoPlayerSettings.common().replayBtnImage
    }
    
    var replayBtnTitle: String {
        SJVideoPlayerSettings.common().replayBtnTitle ?? ""
    }
}

class YDEdgeControlLayerViewController: SJEdgeControlLayerAdapters, SJControlLayer {
    
    /// 是否竖屏时隐藏返回按钮
    private var hiddenBackButtonWhenOrientationIsPortrait: Bool = false
    
    /// 是否竖屏时隐藏标题
    var isHiddenTitleItemWhenOrientationIsPortrait: Bool = false
    /// 是否禁止网络状态变化提示
    var disabledPromptWhenNetworkStatusChanges: Bool = false
    /// 是否隐藏底部进度条
    var hiddenBottomProgressIndicator: Bool = false
    /// 底部进度条高度. default value is 1.0
    var bottomProgressIndicatorHeight: CGFloat = 1.0
    weak var delegate: SJEdgeControlLayerDelegate?
    
    private lazy var lockStateTappedTimerControl: SJTimerControl = {
        let control = SJTimerControl()
        control.exeBlock = { [weak self] cont in
            if let view = self?.leftContainerView {
                
                sj_view_makeDisappear(view, true)
            }
            cont.clear()
        }
        return control
    }()
    
    private lazy var bottomProgressIndicator: SJProgressSlider = {
        let view = SJProgressSlider()
        view.pan.isEnabled = false
        view.trackHeight = bottomProgressIndicatorHeight
        let setting = YDCustomVideoSettings.default
        let traceColor = setting.bottomIndicator_traceColor
        let trackColor = setting.bottomIndicator_trackColor
        view.traceImageView.backgroundColor = traceColor
        view.trackImageView.backgroundColor = trackColor

        return view
    }()
    
    private lazy var draggingProgressPopView: YDVideoDraggingProgressPopView = {
        let view = YDVideoDraggingProgressPopView()
        self.updateForDraggingProgressPopView(view)
        return view
    }()
    
    private lazy var draggingObserver: SJDraggingObservation = {
        let obser = SJDraggingObservation()
        return obser
    }()
    
    private lazy var loadingView: YDVideoLoadingView = {
        let view = YDVideoLoadingView()
        setLoadingView(view)
        return view
    }()
    
    private lazy var titleView: SJScrollingTextMarqueeView = {
        let view = SJScrollingTextMarqueeView()
        return view
    }()
    
    private var reachabilityObserver: SJReachabilityObserver!
    
    @available(iOS 14.0, *)
    private lazy var pictureInPictureItem: SJEdgeControlButtonItem = {
        let item = SJEdgeControlButtonItem(tag: SJEdgeControlLayerTopItem_PictureInPicture)
        item.addTarget(self, action: #selector(pictureInPictureItemWasTapped))
        return item
    }()
    
    
    private var _restarted: Bool = false
    private weak var videoPlayer: SJBaseVideoPlayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - SJControlLayer
    func controlView() -> UIView! {
        self
    }
    ///
    /// 控制层入场
    ///     当播放器将要切换到此控制层时, 该方法将会被调用
    ///     可以在这里做入场的操作
    ///
    func restartControlLayer() {
        _restarted = true
        
        sj_view_makeAppear(self.controlView(), true)
        
        updateAppearStateForContainerViews()
        _reloadAdaptersIfNeeded()
        _showOrHiddenLoadingView()
//        [self _showOrHiddenLoadingView];
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
        self.videoPlayer = videoPlayer
        // 将返回 交给video
        self.delegate = videoPlayer as? SJEdgeControlLayerDelegate
        _showOrRemoveBottomProgressIndicator()
        
        sj_view_makeDisappear(topContainerView, false)
        sj_view_makeDisappear(leftContainerView, false)
        sj_view_makeDisappear(bottomContainerView, false)
        sj_view_makeDisappear(rightContainerView, false)
        sj_view_makeDisappear(centerContainerView, false)
        
        _reloadSizeForBottomTimeLabel()
        _updateContentForBottomCurrentTimeItemIfNeeded()
        _updateContentForBottomDurationItemIfNeeded()
        
        reachabilityObserver = videoPlayer.reachability.getObserver()
        reachabilityObserver.networkSpeedDidChangeExeBlock = { [weak self] r in
            self?._updateNetworkSpeedStrForLoadingView()
        }
    }
    ///
    /// 当播放器尝试自动隐藏控制层之前 将会调用这个方法
    ///
    func controlLayer(ofVideoPlayerCanAutomaticallyDisappear videoPlayer: SJBaseVideoPlayer!) -> Bool {
        let  progressItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Progress)
        let slider = progressItem?.customView as? SJProgressSlider
        return !(slider?.isDragging ?? false)
    }
    
    ///
    /// 当调用播放器的controlLayerNeedAppear时, 播放器将会回调该方法
    ///
    func controlLayerNeedAppear(_ videoPlayer: SJBaseVideoPlayer!) {
        if videoPlayer.isLockedScreen {return}
        updateAppearStateForContainerViews()
        _reloadAdaptersIfNeeded()
        
        //        [self _updateAppearStateForResidentBackButtonIfNeeded];
        _updateContentForBottomCurrentTimeItemIfNeeded()
        _updateContentForBottomProgressSliderItemIfNeeded()
        
        if #available(iOS 11.0, *) {
            _reloadCustomStatusBarIfNeeded()
        }
    }
    ///
    /// 当调用播放器的controlLayerNeedDisappear时, 播放器将会回调该方法
    ///
    func controlLayerNeedDisappear(_ videoPlayer: SJBaseVideoPlayer!) {
        if videoPlayer.isLockedScreen {return}
        
//        [self _updateAppearStateForResidentBackButtonIfNeeded];
        updateAppearStateForContainerViews()
    }
    
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, prepareToPlay asset: SJVideoPlayerURLAsset!) {
        
        _reloadSizeForBottomTimeLabel()
        _updateContentForBottomDurationItemIfNeeded()
        _updateContentForBottomCurrentTimeItemIfNeeded()
        _updateContentForBottomProgressSliderItemIfNeeded()
        _updateContentForBottomProgressIndicatorIfNeeded()
//        [self _updateAppearStateForResidentBackButtonIfNeeded];
        _reloadAdaptersIfNeeded()
        _showOrHiddenLoadingView()
    }
    
    func videoPlayerPlaybackStatusDidChange(_ videoPlayer: SJBaseVideoPlayer!) {
        _reloadAdaptersIfNeeded()
        _showOrHiddenLoadingView()
        
        if videoPlayer.isPlaybackFinished {
            _updateContentForBottomCurrentTimeItemIfNeeded()
        }
    }
    
    @available(iOS 14.0, *)
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, pictureInPictureStatusDidChange status: SJPictureInPictureStatus) {
        _updateContentForPictureInPictureItem()
        topAdapter.reload()
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, currentTimeDidChange currentTime: TimeInterval) {
        _updateContentForBottomCurrentTimeItemIfNeeded()
        _updateContentForBottomProgressIndicatorIfNeeded()
        _updateContentForBottomProgressSliderItemIfNeeded()
        updateCurrentTimeForDraggingProgressPopViewIfNeeded()
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, durationDidChange duration: TimeInterval) {
        _reloadSizeForBottomTimeLabel()
        _updateContentForBottomDurationItemIfNeeded()
        _updateContentForBottomProgressIndicatorIfNeeded()
        _updateContentForBottomProgressSliderItemIfNeeded()
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, playableDurationDidChange duration: TimeInterval) {
        _updateContentForBottomProgressSliderItemIfNeeded()
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, playbackTypeDidChange playbackType: SJPlaybackType) {
        let currentTimeItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_CurrentTime)
        
        let separatorItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Separator)
        let durationTimeItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_DurationTime)
        let progressItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Progress)
        let liveItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_LIVEText)
        switch ( playbackType ) {
            case SJPlaybackTypeLIVE:
                
                currentTimeItem?.isHidden = true
                separatorItem?.isHidden = true
                durationTimeItem?.isHidden = true
                progressItem?.isHidden = true
                liveItem?.isHidden = false
           
            case SJPlaybackTypeUnknown, SJPlaybackTypeVOD, SJPlaybackTypeFILE:
            
                currentTimeItem?.isHidden = false
                separatorItem?.isHidden = false
                durationTimeItem?.isHidden = false
                progressItem?.isHidden = false
                liveItem?.isHidden = true
                bottomAdapter.removeItem(forTag: SJEdgeControlLayerBottomItem_LIVEText)
            
        default:
            break
        }
        bottomAdapter.reload()
        _showOrRemoveBottomProgressIndicator()
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, willRotateView isFull: Bool) {
        updateAppearStateForContainerViews()
        _reloadAdaptersIfNeeded()
        
        if !sj_view_isDisappeared(bottomProgressIndicator) {
            sj_view_makeDisappear(bottomProgressIndicator, false)
        }
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, didEndRotation isFull: Bool) {
        if !videoPlayer.isControlLayerAppeared {
            sj_view_makeAppear(bottomProgressIndicator, true)
        }
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, willFitOnScreen isFitOnScreen: Bool) {
        
        updateAppearStateForContainerViews()
        _reloadAdaptersIfNeeded()
        
        if !sj_view_isDisappeared(bottomProgressIndicator) {
            sj_view_makeDisappear(bottomProgressIndicator, false)
        }
    }
    /// 是否可以触发播放器的手势
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, gestureRecognizerShouldTrigger type: SJPlayerGestureType, location: CGPoint) -> Bool {
        
        var adapterT: SJEdgeControlButtonItemAdapter? = nil
        func _locationInTheView(_ container: UIView)->Bool {
            container.frame.contains(location) && !sj_view_isDisappeared(container)
        }
        
        if _locationInTheView(topContainerView) {
            adapterT = topAdapter
        } else if _locationInTheView(bottomContainerView) {
            adapterT = bottomAdapter
        }
        else if _locationInTheView(leftContainerView) {
            adapterT = leftAdapter
        }
        else if _locationInTheView(rightContainerView) {
            adapterT = rightAdapter
        }
        else if _locationInTheView(centerContainerView) {
            adapterT = centerAdapter
        }
        guard let adapter = adapterT else {
            return true
        }
        
        let point = controlView()?.convert(location, to: adapter.view) ?? .zero
        if !adapter.view.frame.contains(point) {return true}
        
        let item = adapter.item(at: point)
        if let _ = item?.action {
            return false
        } else {
            return true
        }
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, panGestureTriggeredInTheHorizontalDirection state: SJPanGestureRecognizerState, progressTime: TimeInterval) {
        switch ( state ) {
            case SJPanGestureRecognizerStateBegan:
                _willBeginDragging()
            case SJPanGestureRecognizerStateChanged:
                _didMove(progressTime: progressTime)
            case SJPanGestureRecognizerStateEnded:
               _endDragging()
        default:
            break
        }
    }
    // 长按快进 未实现
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, longPressGestureStateDidChange state: SJLongPressGestureRecognizerState) {
        
    }
    /// 这是一个只有在播放器锁屏状态下, 才会回调的方法
    /// 当播放器锁屏后, 用户每次点击都会回调这个方法
    func tappedPlayer(onTheLockedState videoPlayer: SJBaseVideoPlayer!) {
        if sj_view_isDisappeared(leftContainerView)  {
            sj_view_makeAppear(leftContainerView, true)
            lockStateTappedTimerControl.start()
        } else {
            sj_view_makeDisappear(leftContainerView, true)
            lockStateTappedTimerControl.clear()
        }
    }
    
    func lockedVideoPlayer(_ videoPlayer: SJBaseVideoPlayer!) {
        updateAppearStateForContainerViews()
        _reloadAdaptersIfNeeded()
        lockStateTappedTimerControl.start()
    }
    
    func unlockedVideoPlayer(_ videoPlayer: SJBaseVideoPlayer!) {
        lockStateTappedTimerControl.clear()
        videoPlayer.controlLayerNeedAppear()
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, reachabilityChanged status: SJNetworkStatus) {
        if #available(iOS 11.0, *) {
            _reloadCustomStatusBarIfNeeded()
        }
        if disabledPromptWhenNetworkStatusChanges {return}
        if videoPlayer.assetURL?.isFileURL ?? false {return} // return when is local video.
        switch  status  {
        
        case .notReachable:
            let attr = NSAttributedString.sj_UIKitText { (make) in
                let _ = make.append(YDCustomVideoSettings.default.unstableNetworkPrompt).textColor(.white)
            }
            videoPlayer.prompt.show(attr, duration: 3)
            
        case .reachableViaWWAN:
            let attr = NSAttributedString.sj_UIKitText { (make) in
                let _ = make.append(YDCustomVideoSettings.default.cellularNetworkPrompt).textColor(.white)
            }
            videoPlayer.prompt.show(attr, duration: 3)
            
        case .reachableViaWiFi:
            break
        @unknown default:
            break
        }
    }
    
    var restarted: Bool {
        _restarted
    }
    
}
// MARK: -

extension YDEdgeControlLayerViewController {
    private func setLoadingView(_ view: SJLoadingViewProtocol) {
        let loadV = view as! UIView
        controlView()?.addSubview(loadV)
        loadV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}

// MARK: - setupSubViews
extension YDEdgeControlLayerViewController {
    private func setupSubViews() {
        addItemsToTopAdapter()
        _addItemsToLeftAdapter()
        addItemsToBottomAdapter()
        _addItemsToRightAdapter()
        _addItemsToCenterAdapter()
        
        topContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Top;
        self.leftContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Left;
        self.bottomContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Bottom;
        self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
        self.centerContainerView.sjv_disappearDirection = SJViewDisappearAnimation_None;
        sj_view_initializes([topContainerView, leftContainerView, bottomContainerView, rightContainerView])
        
        NotificationCenter.default.addObserver(self, selector: #selector(_resetControlLayerAppearIntervalForItemIfNeeded(note:)), name: NSNotification.Name.SJEdgeControlButtonItemPerformedAction, object: nil)
    }
    
    private func addItemsToTopAdapter() {
        let backItem = SJEdgeControlButtonItem.placeholder(with: SJButtonItemPlaceholderType_49x49, tag: SJEdgeControlLayerTopItem_Back)
        backItem.resetAppearIntervalWhenPerformingItemAction = false
        backItem.addTarget(self, action: #selector(_backItemWasTapped))
        topAdapter.add(backItem)
        
        let titleItem = SJEdgeControlButtonItem.placeholder(with: SJButtonItemPlaceholderType_49xFill, tag: SJEdgeControlLayerTopItem_Title)
        topAdapter.add(titleItem)
        topAdapter.reload()
    }
    
    private func addItemsToBottomAdapter() {
        // 播放按钮
        let playerItem = SJEdgeControlButtonItem.placeholder(with: SJButtonItemPlaceholderType_49x49, tag: SJEdgeControlLayerBottomItem_Play)
        playerItem.addTarget(self, action: #selector(playItemAct))
        bottomAdapter.add(playerItem)
        
        // 播放进度条
        let slider = SJProgressSlider()
        slider.trackHeight = 3;
        slider.delegate = self
        slider.tap.isEnabled = true
        slider.enableBufferProgress = true
        
        slider.tappedExeBlock = { [weak self] (slider, location) in
            guard let strongSelf = self  else {return}
            if let canseek = strongSelf.videoPlayer.canSeekToTime, canseek(strongSelf.videoPlayer) == false {
                return
            }
            if strongSelf.videoPlayer.assetStatus != SJAssetStatus.readyToPlay {
                return
            }
            strongSelf.videoPlayer.seek(toTime: TimeInterval(location), completionHandler: nil)
        }
        let progressItem = SJEdgeControlButtonItem(customView: slider, tag: SJEdgeControlLayerBottomItem_Progress)
//        progressItem.insets = SJEdgeInsetsMake(8, 8)
        progressItem.insets = SJEdgeInsets(front: -4, rear: 8)
        
        progressItem.fill = true
        bottomAdapter.add(progressItem)
        
        // 当前时间
        let currentTimeItem = SJEdgeControlButtonItem.placeholder(withSize: 8, tag: SJEdgeControlLayerBottomItem_CurrentTime)
        bottomAdapter.add(currentTimeItem)
        // 时间分隔符
        let attr = NSAttributedString.sj_UIKitText({ (make) in
            _ = make.append("/").font(UIFont.systemFont(ofSize: 9, weight: .heavy)).textColor(UIColor.white).alignment(.center)
        })
        let separatorItem = SJEdgeControlButtonItem(title: attr, target: nil, action: nil, tag: SJEdgeControlLayerBottomItem_Separator)
        bottomAdapter.add(separatorItem)
        // 全部时长
        let durationTimeItem = SJEdgeControlButtonItem.placeholder(withSize: 8, tag: SJEdgeControlLayerBottomItem_DurationTime)
        bottomAdapter.add(durationTimeItem)
        // 全屏按钮
        let fullItem = SJEdgeControlButtonItem.placeholder(with: SJButtonItemPlaceholderType_49xAutoresizing, tag: SJEdgeControlLayerBottomItem_FullBtn)
        fullItem.resetAppearIntervalWhenPerformingItemAction = false
        fullItem.addTarget(self, action: #selector(_fullItemWasTapped))
        bottomAdapter.add(fullItem)

        self.bottomAdapter.reload()
    }
    
    private func _addItemsToLeftAdapter() {
        let lockItem = SJEdgeControlButtonItem.placeholder(with: SJButtonItemPlaceholderType_49x49, tag: SJEdgeControlLayerLeftItem_Lock)
        lockItem.addTarget(self, action: #selector(_lockItemWasTapped))
        
        leftAdapter.add(lockItem)
        leftAdapter.reload()
    }
    
    private func _addItemsToRightAdapter() {
        
    }
    
    private func _addItemsToCenterAdapter() {
        let replayLabel = UILabel()
        replayLabel.numberOfLines = 0
        let replayItem = SJEdgeControlButtonItem.frameLayout(withCustomView: replayLabel, tag: SJEdgeControlLayerCenterItem_Replay)
        replayItem.addTarget(self, action: #selector(_replayItemWasTapped))
        centerAdapter.add(replayItem)
        centerAdapter.reload()
    }
    
    // MARK: - item actions
    @objc private func _backItemWasTapped() {
        delegate?.backItemWasTapped(for: self)
    }
    
    @objc private func playItemAct() {
        videoPlayer.isPaused ? videoPlayer.play() : videoPlayer.pauseForUser()
    }
    
    @objc private func _fullItemWasTapped() {
        videoPlayer.useFitOnScreenAndDisableRotation ? videoPlayer.isFitOnScreen = !videoPlayer.isFitOnScreen : videoPlayer.rotate()
    }
    
    @objc private func _lockItemWasTapped() {
        videoPlayer.isLockedScreen = !videoPlayer.isLockedScreen
    }
    
    @objc private func _replayItemWasTapped() {
        videoPlayer.replay()
    }
    
    @available(iOS 14.0, *)
    @objc private func pictureInPictureItemWasTapped() {
        switch videoPlayer.playbackController.pictureInPictureStatus {
        case .starting, .running:
            videoPlayer.playbackController.stopPictureInPicture()
        case .unknown, .stopping, .stopped:
            videoPlayer.playbackController.startPictureInPicture()
        @unknown default:
            break
        }
    }

}

// MARK: - appear state
extension YDEdgeControlLayerViewController {
    
    private func updateAppearStateForContainerViews() {
        updateAppearStateForTopContainerView()
        updateAppearStateForLeftContainerView()
        updateAppearStateForBottomContainerView()
        updateAppearStateForRightContainerView()
        updateAppearStateForCenterContainerView()
    }
    
    private func updateAppearStateForTopContainerView() {
        if ( 0 == topAdapter.numberOfItems ) {
            sj_view_makeDisappear(topContainerView, true)
            return
        }
        /// 锁屏状态下, 使隐藏
        if ( videoPlayer.isLockedScreen ) {
            sj_view_makeDisappear(topContainerView, true)
            return
        }
        /// 是否显示
        if ( videoPlayer.isControlLayerAppeared ) {
            sj_view_makeAppear(topContainerView, true)
        } else {
            sj_view_makeDisappear(topContainerView, true)
        }
    }
    
    private func updateAppearStateForLeftContainerView() {
        
    }
    
    private func updateAppearStateForBottomContainerView() {
        if 0 == bottomAdapter.numberOfItems {
            sj_view_makeDisappear(bottomContainerView, true)
            return
        }
        
        /// 锁屏状态下, 使隐藏
        if ( videoPlayer.isLockedScreen ) {
            sj_view_makeDisappear(bottomContainerView, true)
            sj_view_makeAppear(bottomProgressIndicator, true);
            return
        }
        
        /// 是否显示
        if ( videoPlayer.isControlLayerAppeared ) {
            sj_view_makeAppear(bottomContainerView, true)
            sj_view_makeDisappear(bottomProgressIndicator, true);
        } else {
            sj_view_makeDisappear(bottomContainerView, true)
            sj_view_makeAppear(bottomProgressIndicator, true)
        }
        
    }
    
    private func updateAppearStateForRightContainerView() {
        
    }
    
    private func updateAppearStateForCenterContainerView() {
        
    }
    
    private func updateAppearStateForCustomStatusBar() {
        
    }
}

// MARK: - update items
extension YDEdgeControlLayerViewController {
    private func _reloadAdaptersIfNeeded() {
        _reloadTopAdapterIfNeeded()
        _reloadLeftAdapterIfNeeded()
        _reloadBottomAdapterIfNeeded()
        _reloadRightAdapterIfNeeded()
        _reloadCenterAdapterIfNeeded()
    }
    
    private func _reloadTopAdapterIfNeeded() {
        if sj_view_isDisappeared(topContainerView) { return}
        let sources = YDCustomVideoSettings.default
        let isFullscreen = videoPlayer.isFullScreen
        let isFitOnScreen = videoPlayer.isFitOnScreen
        let isPlayOnScrollView = videoPlayer.isPlayOnScrollView
        var isSmallscreen = true
        
        if !isFullscreen, !isFitOnScreen {
            isSmallscreen = true
        }else {
            isSmallscreen = false
        }
        
        // back item
        if let backItem = topAdapter.item(forTag: SJEdgeControlLayerTopItem_Back) {
            if isFullscreen || isFitOnScreen {
                backItem.isHidden = false
            } else if hiddenBackButtonWhenOrientationIsPortrait {
                backItem.isHidden = true
            } else {
                backItem.isHidden = isPlayOnScrollView
            }
            
            if backItem.isHidden == false {
                backItem.image = sources.backBtnImage
            }
        }
               
        if let titleItem = topAdapter.item(forTag: SJEdgeControlLayerTopItem_Title){
            if isHiddenTitleItemWhenOrientationIsPortrait, isSmallscreen {
                titleItem.isHidden = true
            } else {
                titleItem.customView = titleView
                let asset = videoPlayer.urlAsset?.original ?? videoPlayer.urlAsset
                let attributeTitle = asset?.attributedTitle
                titleView.attributedText = attributeTitle
                titleItem.isHidden = (attributeTitle?.length == 0)
            }
            
            if !titleItem.isHidden {
                let atIndex = topAdapter.indexOfItem(forTag: SJEdgeControlLayerTopItem_Title)
                let left = topAdapter.isHidden(with: NSRange(location: 0, length: atIndex)) ? 16 : 0
                let right = topAdapter.isHidden(with: NSRange(location: atIndex, length: topAdapter.numberOfItems)) ? 16 : 0
                
                titleItem.insets = SJEdgeInsets(front: CGFloat(left), rear: CGFloat(right))
            }
        }
        
        topAdapter.reload()
    }
    
    private func _reloadLeftAdapterIfNeeded() {
        
    }
    
    private func _reloadBottomAdapterIfNeeded() {
        if sj_view_isDisappeared(bottomContainerView) {return}
        
        let sources = YDCustomVideoSettings.default
        // play item
        if let playItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Play), playItem.isHidden == false {
            playItem.image = videoPlayer.isPaused ? sources.playBtnImage : sources.pauseBtnImage
        }
        
        if let progressItem = self.bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Progress),
           progressItem.isHidden == false,
           let slider = progressItem.customView as?  SJProgressSlider{
                slider.traceImageView.backgroundColor = sources.progress_traceColor
                slider.trackImageView.backgroundColor = sources.progress_trackColor
                slider.bufferProgressColor = sources.progress_bufferColor
            slider.trackHeight = CGFloat(sources.progress_traceHeight)
            slider.loadingColor = sources.loadingLineColor
            if let progress_thumbImage = sources.progress_thumbImage {
                slider.thumbImageView.image = progress_thumbImage
            } else if sources.progress_thumbSize > 0 {
                let psize = CGFloat(sources.progress_thumbSize)
                slider.setThumbCornerRadius(psize * 0.5, size: CGSize(width: psize, height: psize), thumbBackgroundColor: sources.progress_thumbColor)
            }
        }
        // full item
        if let fullItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_FullBtn), fullItem.isHidden == false {
            let isFullscreen = videoPlayer.isFullScreen
            let isFitOnScreen = videoPlayer.isFitOnScreen
            fullItem.image = (isFullscreen || isFitOnScreen) ? sources.shrinkscreenImage : sources.fullBtnImage
            if (isFullscreen || isFitOnScreen) {
                fullItem.insets = SJEdgeInsets(front: 0, rear: 20)
            } else {
                fullItem.insets = SJEdgeInsets(front: 0, rear: 0)
            }
        }
        
        bottomAdapter.reload()
    }
    
    private func _reloadRightAdapterIfNeeded() {
        
    }
    
    private func _reloadCenterAdapterIfNeeded() {
        if sj_view_isDisappeared(centerContainerView) { return}
        if let replayItem = centerAdapter.item(forTag: SJEdgeControlLayerCenterItem_Replay) {
            replayItem.isHidden = !videoPlayer.isPlaybackFinished
            if replayItem.isHidden == false, replayItem.title == nil {
                let sources = YDCustomVideoSettings.default
                let textLbl = replayItem.customView as? UILabel
                textLbl?.attributedText = NSAttributedString.sj_UIKitText({ (make) in
                    _ = make.alignment(.center).lineSpacing(6)
                    _ = make.font(sources.replayBtnFont)
                    _ = make.textColor(sources.replayBtnTitleColor)
                    
                    if let replayBtnImage = sources.replayBtnImage {
                        _ = make.appendImage{ make in
                            make.image = replayBtnImage
                        }
                    }
                    if sources.replayBtnTitle.count != 0 {
                        if ( sources.replayBtnImage != nil ) {let _ = make.append("\n")}
                        let _ = make.append(sources.replayBtnTitle)
                    }
                })
                let size = textLbl?.attributedText?.sj_textSize() ?? .zero
                textLbl?.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            }
        }
        centerAdapter.reload()
    }
    
    private func _updateContentForBottomCurrentTimeItemIfNeeded() {
        if sj_view_isDisappeared(bottomContainerView) {
            return
        }
        let currentTimeStr = videoPlayer.string(forSeconds: Int(videoPlayer.currentTime))
     
        if let currentTimeItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_CurrentTime), currentTimeItem.isHidden == false {
            currentTimeItem.title = _textForTimeString(timeStr: currentTimeStr)
            bottomAdapter.updateContentForItem(withTag: SJEdgeControlLayerBottomItem_CurrentTime)
        }
    }
    
    private func _updateContentForBottomDurationItemIfNeeded() {
        if let durationTimeItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_DurationTime), durationTimeItem.isHidden == false {
            durationTimeItem.title = _textForTimeString(timeStr: videoPlayer.string(forSeconds: Int(videoPlayer.duration)))
            bottomAdapter.updateContentForItem(withTag: SJEdgeControlLayerBottomItem_CurrentTime)
        }
    }
    
    private func _reloadSizeForBottomTimeLabel() {
        // 00:00
        // 00:00:00
        let ms = "00:00"
        let hms = "00:00:00"
        let durationTimeStr = videoPlayer.string(forSeconds: Int(videoPlayer.duration))
            
        let format = (durationTimeStr.count == ms.count) ? ms : hms
        
        let formatSize = _textForTimeString(timeStr: format).sj_textSize()
        
        guard let currentTimeItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_CurrentTime),
              let durationTimeItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_DurationTime) else {
            return
        }
    
        currentTimeItem.size = formatSize.width
        durationTimeItem.size = formatSize.width
        bottomAdapter.reload()
    }
    
    private func _updateContentForBottomProgressSliderItemIfNeeded() {
        if !sj_view_isDisappeared(bottomContainerView) {
            let progressItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Progress)
            guard let slider = progressItem?.customView as? SJProgressSlider else {
                return
            }
            slider.maxValue = CGFloat(videoPlayer.duration)
            if !slider.isDragging {slider.value = CGFloat(videoPlayer.currentTime)}
            slider.bufferProgress = CGFloat(videoPlayer.playableDuration) / slider.maxValue
        }
    }

    private func _updateContentForBottomProgressIndicatorIfNeeded() {
        if !sj_view_isDisappeared(bottomProgressIndicator) {
            bottomProgressIndicator.value = CGFloat(videoPlayer.currentTime)
            bottomProgressIndicator.maxValue = CGFloat(videoPlayer.duration)
        }
    }
    
    private func updateCurrentTimeForDraggingProgressPopViewIfNeeded() {
        if !sj_view_isDisappeared(draggingProgressPopView) {
            draggingProgressPopView.currentTime = videoPlayer.currentTime
        }
    }
    
    private func _updateNetworkSpeedStrForLoadingView() {
        if !loadingView.isAnimating {return}
        if loadingView.showNetworkSpeed && !(videoPlayer.assetURL?.isFileURL ?? false) {
            loadingView.networkSpeedStr = NSAttributedString.sj_UIKitText({ (make) in
                _ = make.append(self.videoPlayer.reachability.networkSpeedStr).font(UIFont.systemFont(ofSize: 14, weight: .regular)).textColor(.white).alignment(.center)
                
            })
        }else {
            loadingView.networkSpeedStr = nil
        }
    }
    // FIXME: - _reloadCustomStatusBarIfNeeded
    @available(iOS 11.0, *)
    private func _reloadCustomStatusBarIfNeeded() {
        
    }
    
    @available(iOS 14.0, *)
    private func _updateContentForPictureInPictureItem() {
        let sources = YDCustomVideoSettings.default
        switch videoPlayer.playbackController.pictureInPictureStatus {
        case .running:
                self.pictureInPictureItem.image = sources.pictureInPictureItemStopImage;
                break;
        case .unknown, .starting, .stopping, .stopped:

                self.pictureInPictureItem.image = sources.pictureInPictureItemStartImage;
                
        @unknown default:
            break
        }
    }
    
    // MARK: - progress
    private func updateForDraggingProgressPopView(_ view: YDVideoDraggingProgressPopView) {
        
        view.duration = videoPlayer.duration
        view.currentTime = videoPlayer.currentTime
        view.dragProgressTime = videoPlayer.currentTime
    }
    
    private func _updateForDraggingProgressPopView() {
        updateForDraggingProgressPopView(draggingProgressPopView)
    }
    
    private func _showOrHiddenLoadingView() {
        if videoPlayer == nil || videoPlayer.urlAsset == nil {
            loadingView.stop()
            return
        }
        if videoPlayer.isPaused {
            loadingView.stop()
        } else if videoPlayer.assetStatus == .preparing {
            loadingView.start()
        } else if videoPlayer.assetStatus == .failed {
            loadingView.stop()
        } else if videoPlayer.assetStatus == .readyToPlay {
            videoPlayer.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ? loadingView.start() : loadingView.stop()
        }
        
    }
    
    private func _willBeginDragging() {
        let popV = draggingProgressPopView
        controlView()?.addSubview(popV)
        _updateForDraggingProgressPopView()
        popV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        sj_view_initializes(popV)
        sj_view_makeAppear(popV, false)
        draggingObserver.willBeginDraggingExeBlock?(draggingProgressPopView.dragProgressTime)
    }
    
    private func _didMove(progressTime: TimeInterval) {
        print("progressTime = ", progressTime)
        draggingProgressPopView.dragProgressTime = progressTime
        
        // 是否生成预览图 没实现
        draggingObserver.didMoveExeBlock?(draggingProgressPopView.dragProgressTime)
    }
    
    private func _endDragging() {
        let time1 = draggingProgressPopView.dragProgressTime
        draggingObserver.willEndDraggingExeBlock?(time1)
        videoPlayer.seek(toTime: time1, completionHandler: nil)
        sj_view_makeDisappear(draggingProgressPopView, true) {
            if sj_view_isDisappeared(self.draggingProgressPopView) {
                self.draggingProgressPopView.removeFromSuperview()
            }
        }
        
        draggingObserver.didEndDraggingExeBlock?(time1)
    }
}


// MARK: - SJProgressSliderDelegate
extension YDEdgeControlLayerViewController: SJProgressSliderDelegate {
    func sliderWillBeginDragging(_ slider: SJProgressSlider) {
        
        if videoPlayer.assetStatus != SJAssetStatus.readyToPlay {
            slider.cancelDragging()
            return
        } else if let canSeekToTime = videoPlayer.canSeekToTime, !canSeekToTime(videoPlayer) {
            slider.cancelDragging()
            return
        }
        _willBeginDragging()
    }
    
    func slider(_ slider: SJProgressSlider, valueDidChange value: CGFloat) {
        if slider.isDragging {self._didMove(progressTime: TimeInterval(value))}
    }
    
    func sliderDidEndDragging(_ slider: SJProgressSlider) {
        _endDragging()
    }
}

// MARK: -
extension YDEdgeControlLayerViewController {
    
    private func _textForTimeString(timeStr: String) ->NSAttributedString {
        let source = YDCustomVideoSettings.default
        return NSAttributedString.sj_UIKitText { (make) in
           _ =  make.append(timeStr).font(source.timeFont).textColor(source.timeColor).alignment(.center)
        }
    }

    /// 此处为重置控制层的隐藏间隔.(如果点击到当前控制层上的item, 则重置控制层的隐藏间隔)
    @objc private func _resetControlLayerAppearIntervalForItemIfNeeded(note: Notification) {
        let item = note.object as! SJEdgeControlButtonItem
        if ( item.resetAppearIntervalWhenPerformingItemAction ) {
            if ( topAdapter.contains(item) ||
                leftAdapter.contains(item) ||
                bottomAdapter.contains(item) ||
                rightAdapter.contains(item)) {
                videoPlayer.controlLayerNeedAppear()
            }
        }
    }
    
    private func _showOrRemoveBottomProgressIndicator() {
        if hiddenBottomProgressIndicator || videoPlayer.playbackType == SJPlaybackTypeLIVE  {
            bottomProgressIndicator.removeFromSuperview()
        } else {
            controlView()?.addSubview(bottomProgressIndicator)
            bottomProgressIndicator.snp.makeConstraints { (make) in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(bottomProgressIndicatorHeight)
            }
        }
    }
}


class YDVideoDraggingProgressPopView: UIView, SJDraggingProgressPopViewProtocol {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return view
    }()
    
    private lazy var directionImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var dragProgressTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.0862745098, alpha: 1)
        lbl.textAlignment = .right
        return lbl
    }()
    
    private lazy var separatorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .white
        lbl.text = "/"
        return lbl
    }()
    
    private lazy var durationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .white
        lbl.textAlignment = .left
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
        addSubview(contentView)
        contentView.addSubview(directionImageView)
        contentView.addSubview(dragProgressTimeLabel)
        contentView.addSubview(separatorLabel)
        contentView.addSubview(durationLabel)
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(120)
            make.height.equalTo(54)
        }
        
        directionImageView.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.centerX.equalToSuperview()
        }
        
        separatorLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(directionImageView.snp.bottom).offset(2)
        }
        
        dragProgressTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(separatorLabel.snp.left)
            make.centerY.equalTo(separatorLabel)
        }
        
        durationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(separatorLabel.snp.right)
            make.centerY.equalTo(separatorLabel)
        }
    }
    
    
    
    
    // MARK: - SJDraggingProgressPopViewProtocol

    var style: SJDraggingProgressPopViewStyle = SJDraggingProgressPopViewStyleNormal
    
    var dragProgressTime: TimeInterval = 0 {
        didSet {
            let sources = YDCustomVideoSettings.default
            if dragProgressTime > oldValue {
                directionImageView.image = sources.fastImage
            } else if dragProgressTime < oldValue {
                directionImageView.image = sources.forwardImage
            }
            let str = NSString.init(currentTime: dragProgressTime, duration: duration)
             
            dragProgressTimeLabel.text = str as String
            print("didset = ", str)
        }
    }
    
    var currentTime: TimeInterval = 0
    
    var duration: TimeInterval = 0 {
        didSet {
            durationLabel.text = NSString.init(currentTime: duration, duration: duration) as String
        }
    }
    
    var isPreviewImageHidden: Bool {
        return style != SJDraggingProgressPopViewStyleFullscreen
    }
    
    var previewImage: UIImage? = nil
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
