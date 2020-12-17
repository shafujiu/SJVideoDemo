//
//  SJCustomControlLayerViewController.swift
//  SJVideoDemo
//
//  Created by Shafujiu on 2020/12/15.
//

import UIKit
import SJVideoPlayer

class SJCustomControlLayerViewController: SJEdgeControlLayerAdapters, SJControlLayer {

    
    /// 是否竖屏时隐藏返回按钮
    var hiddenBackButtonWhenOrientationIsPortrait: Bool = false
    weak var delegate: SJEdgeControlLayerDelegate?
    
    private lazy var draggingProgressPopView: YDVideoDraggingProgressPopView = {
        let view = YDVideoDraggingProgressPopView()
        self.updateForDraggingProgressPopView(view)
        return view
    }()
    
    private lazy var draggingObserver: SJDraggingObservation = {
        let obser = SJDraggingObservation()
        return obser
    }()
    
    private var _restarted: Bool = false
    private var videoPlayer: SJBaseVideoPlayer!
    
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
    /// 当controlView被添加到播放器时, 该方法将会被调用
    ///
    func installedControlView(to videoPlayer: SJBaseVideoPlayer!) {
        self.videoPlayer = videoPlayer
        // 将返回 交给video
        self.delegate = videoPlayer as? SJEdgeControlLayerDelegate
//        sj_view_makeDisappear(topContainerView, false)
        
    }
    ///
    /// 当播放器尝试自动隐藏控制层之前 将会调用这个方法
    ///
    func controlLayer(ofVideoPlayerCanAutomaticallyDisappear videoPlayer: SJBaseVideoPlayer!) -> Bool {
        true
    }
    
    ///
    /// 当调用播放器的controlLayerNeedAppear时, 播放器将会回调该方法
    ///
    func controlLayerNeedAppear(_ videoPlayer: SJBaseVideoPlayer!) {
        if videoPlayer.isLockedScreen {return}
        updateAppearStateForContainerViews()
        _reloadAdaptersIfNeeded()
        
//        [self _updateAppearStateForResidentBackButtonIfNeeded];
//        [self _updateAppearStateForContainerViews];
//        [self _reloadAdaptersIfNeeded];
//        [self _updateContentForBottomCurrentTimeItemIfNeeded];
//        [self _updateContentForBottomProgressSliderItemIfNeeded];
//        if (@available(iOS 11.0, *)) {
//            [self _reloadCustomStatusBarIfNeeded];
//        }
        
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
        
    }
    
    func videoPlayerPlaybackStatusDidChange(_ videoPlayer: SJBaseVideoPlayer!) {
        
    }
    
    @available(iOS 14.0, *)
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, pictureInPictureStatusDidChange status: SJPictureInPictureStatus) {
        
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, currentTimeDidChange currentTime: TimeInterval) {
//        [self _updateContentForBottomCurrentTimeItemIfNeeded];
//        [self _updateContentForBottomProgressIndicatorIfNeeded];
//        [self _updateContentForBottomProgressSliderItemIfNeeded];
        updateCurrentTimeForDraggingProgressPopViewIfNeeded()
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, durationDidChange duration: TimeInterval) {
        
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, playbackTypeDidChange playbackType: SJPlaybackType) {
        
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, willRotateView isFull: Bool) {
        
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, didEndRotation isFull: Bool) {
        
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, willFitOnScreen isFitOnScreen: Bool) {
        
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, gestureRecognizerShouldTrigger type: SJPlayerGestureType, location: CGPoint) -> Bool {
        true
    }
    
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, panGestureTriggeredInTheHorizontalDirection state: SJPanGestureRecognizerState, progressTime: TimeInterval) {
        
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, longPressGestureStateDidChange state: SJLongPressGestureRecognizerState) {
        
    }
    /// 这是一个只有在播放器锁屏状态下, 才会回调的方法
    /// 当播放器锁屏后, 用户每次点击都会回调这个方法
    func tappedPlayer(onTheLockedState videoPlayer: SJBaseVideoPlayer!) {
        
    }
    
    
    func lockedVideoPlayer(_ videoPlayer: SJBaseVideoPlayer!) {
        
    }
    
    func unlockedVideoPlayer(_ videoPlayer: SJBaseVideoPlayer!) {
        
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, reachabilityChanged status: SJNetworkStatus) {
    
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
        
        sj_view_makeAppear(self.controlView(), true)
        
        updateAppearStateForContainerViews()
        _reloadAdaptersIfNeeded()
        
//        [self _showOrHiddenLoadingView];
//        [self _updateAppearStateForContainerViews];
//        [self _reloadAdaptersIfNeeded];
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
    
}
// MARK: -
extension SJCustomControlLayerViewController {
    
}

// MARK: - setupSubViews
extension SJCustomControlLayerViewController {
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
        progressItem.insets = SJEdgeInsetsMake(8, 8)
        progressItem.fill = true
        bottomAdapter.add(progressItem)
        
        // 当前时间
        let currentTimeItem = SJEdgeControlButtonItem.placeholder(withSize: 8, tag: SJEdgeControlLayerBottomItem_CurrentTime)
        bottomAdapter.add(currentTimeItem)
        // 时间分隔符
//        SJEdgeControlButtonItem *separatorItem = [[SJEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
//            make.append(@"/ ").font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
//        }] target:nil action:NULL tag:SJEdgeControlLayerBottomItem_Separator];
//        [self.bottomAdapter addItem:separatorItem];
//
//        // 全部时长
//        SJEdgeControlButtonItem *durationTimeItem = [SJEdgeControlButtonItem placeholderWithSize:8 tag:SJEdgeControlLayerBottomItem_DurationTime];
//        [self.bottomAdapter addItem:durationTimeItem];
        // 全屏按钮
        let fullItem = SJEdgeControlButtonItem.placeholder(with: SJButtonItemPlaceholderType_49x49, tag: SJEdgeControlLayerBottomItem_FullBtn)
        fullItem.resetAppearIntervalWhenPerformingItemAction = false
        fullItem.addTarget(self, action: #selector(_fullItemWasTapped))
        bottomAdapter.add(fullItem)

        self.bottomAdapter.reload()
    }
    
    private func _addItemsToLeftAdapter() {
        
    }
    
    private func _addItemsToRightAdapter() {
        
    }
    
    private func _addItemsToCenterAdapter() {
        
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
}

// MARK: - appear state
extension SJCustomControlLayerViewController {
    
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
//            sj_view_makeAppear(bottomProgressIndicator, true);
            return
        }
        
        /// 是否显示
        if ( videoPlayer.isControlLayerAppeared ) {
            sj_view_makeAppear(bottomContainerView, true)
//            sj_view_makeDisappear(bottomProgressIndicator, true);
        } else {
            sj_view_makeDisappear(bottomContainerView, true)
//            sj_view_makeAppear(_bottomProgressIndicator, YES);
        }
        
    }
    
    private func updateAppearStateForRightContainerView() {
        
    }
    
    private func updateAppearStateForCenterContainerView() {
        
    }
    
    private func updateAppearStateForCustomStatusBar() {
        
    }
    
    private func updateCurrentTimeForDraggingProgressPopViewIfNeeded() {
        if !sj_view_isDisappeared(draggingProgressPopView) {
            draggingProgressPopView.currentTime = videoPlayer.currentTime
        }
    }
}

// MARK: - update items
extension SJCustomControlLayerViewController {
    private func _reloadAdaptersIfNeeded() {
        _reloadTopAdapterIfNeeded()
        _reloadLeftAdapterIfNeeded()
        _reloadBottomAdapterIfNeeded()
        _reloadRightAdapterIfNeeded()
        _reloadCenterAdapterIfNeeded()
    }
    
    private func _reloadTopAdapterIfNeeded() {
        if sj_view_isDisappeared(topContainerView) { return}
        let sources = SJVideoPlayerSettings.common()
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
        
        // title item
        //        {
        //            SJEdgeControlButtonItem *titleItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Title];
        //            if ( titleItem != nil ) {
        //                if ( self.isHiddenTitleItemWhenOrientationIsPortrait && isSmallscreen ) {
        //                    titleItem.hidden = YES;
        //                }
        //                else {
        //                    if ( titleItem.customView != self.titleView )
        //                        titleItem.customView = self.titleView;
        //                    SJVideoPlayerURLAsset *asset = _videoPlayer.URLAsset.original ?: _videoPlayer.URLAsset;
        //                    NSAttributedString *_Nullable attributedTitle = asset.attributedTitle;
        //                    self.titleView.attributedText = attributedTitle;
        //                    titleItem.hidden = (attributedTitle.length == 0);
        //                }
        //
        //                if ( titleItem.hidden == NO ) {
        //                    // margin
        //                    NSInteger atIndex = [_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title];
        //                    CGFloat left  = [_topAdapter isHiddenWithRange:NSMakeRange(0, atIndex)] ? 16 : 0;
        //                    CGFloat right = [_topAdapter isHiddenWithRange:NSMakeRange(atIndex, _topAdapter.numberOfItems)] ? 16 : 0;
        //                    titleItem.insets = SJEdgeInsetsMake(left, right);
        //                }
        //            }
        //        }
        
        topAdapter.reload()
    }
    
    private func _reloadLeftAdapterIfNeeded() {
        
    }
    
    private func _reloadBottomAdapterIfNeeded() {
        if sj_view_isDisappeared(bottomContainerView) {return}
        
        let sources = SJVideoPlayerSettings.common()
        
        // play item
        if let playItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Play), playItem.isHidden == false {
            playItem.image = videoPlayer.isPaused ? sources.playBtnImage : sources.pauseBtnImage
        }
        
        //        // progress item
        //        {
        //            SJEdgeControlButtonItem *progressItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
        //            if ( progressItem != nil && progressItem.hidden == NO ) {
        //                SJProgressSlider *slider = progressItem.customView;
        //                slider.traceImageView.backgroundColor = sources.progress_traceColor;
        //                slider.trackImageView.backgroundColor = sources.progress_trackColor;
        //                slider.bufferProgressColor = sources.progress_bufferColor;
        //                slider.trackHeight = sources.progress_traceHeight;
        //                slider.loadingColor = sources.loadingLineColor;
        //
        //                if ( sources.progress_thumbImage ) {
        //                    slider.thumbImageView.image = sources.progress_thumbImage;
        //                }
        //                else if ( sources.progress_thumbSize ) {
        //                    [slider setThumbCornerRadius:sources.progress_thumbSize * 0.5 size:CGSizeMake(sources.progress_thumbSize, sources.progress_thumbSize) thumbBackgroundColor:sources.progress_thumbColor];
        //                }
        //            }
        //        }
        //
        // full item
        
        if let fullItem = bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_FullBtn), fullItem.isHidden == false {
            let isFullscreen = videoPlayer.isFullScreen
            let isFitOnScreen = videoPlayer.isFitOnScreen
            
            fullItem.image = (isFullscreen || isFitOnScreen) ? sources.shrinkscreenImage : sources.fullBtnImage
        }
        
        //
        //        // live text
        //        {
        //            SJEdgeControlButtonItem *liveItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_LIVEText];
        //            if ( liveItem != nil && liveItem.hidden == NO ) {
        //                liveItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        //                    make.append(sources.liveText);
        //                    make.font(sources.titleFont);
        //                    make.textColor(sources.titleColor);
        //                    make.shadow(^(NSShadow * _Nonnull make) {
        //                        make.shadowOffset = CGSizeMake(0, 0.5);
        //                        make.shadowColor = UIColor.blackColor;
        //                    });
        //                }];
        //            }
        //        }
        
        bottomAdapter.reload()
        
        
    }
    
    private func _reloadRightAdapterIfNeeded() {
        
    }
    
    private func _reloadCenterAdapterIfNeeded() {
        
    }
    
    // MARK: - progress
    private func updateForDraggingProgressPopView(_ view: YDVideoDraggingProgressPopView) {
        
        view.duration = videoPlayer.duration
        view.currentTime = videoPlayer.currentTime
        view.dragProgressTime = videoPlayer.currentTime
        print("videoPlayer.currentTime", videoPlayer.currentTime)
    }
    
    private func _updateForDraggingProgressPopView() {
        updateForDraggingProgressPopView(draggingProgressPopView)
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

// MARK: -
extension SJCustomControlLayerViewController {
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
}
// MARK: - SJProgressSliderDelegate
extension SJCustomControlLayerViewController: SJProgressSliderDelegate {
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
        print("value = ", value)
        if slider.isDragging {self._didMove(progressTime: TimeInterval(value))}
    }
    
    func sliderDidEndDragging(_ slider: SJProgressSlider) {
        _endDragging()
    }
}
