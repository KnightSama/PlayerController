//
//  PlayerViewController.m
//  ComicPark
//
//  Created by KnightSama on 16/7/25.
//  Copyright © 2016年 KnightSama. All rights reserved.
//

#import "PlayerViewController.h"
#import "CoreDevice.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerToolBar.h"
#import "UIView+CoreFrame.h"

#define ToolBarHeight 40

@interface PlayerViewController ()<PlayerToolBarDelegate>
//播放器
@property(nonatomic,strong) AVPlayer *player;
//播放器视图
@property(nonatomic,strong) AVPlayerLayer *playerLayer;
//底层播放控件
@property(nonatomic,strong) PlayerToolBar *toolBar;
//toolBar是否已经隐藏
@property(nonatomic,assign) BOOL isToolHiden;
//是否正在播放
@property(nonatomic,assign) BOOL isPlaying;
//方向监听
@property(nonatomic,strong) CoreDevice *device;
//当前方向
@property(nonatomic,assign) UIDeviceOrientation currentOrientation;
//记录原始中心点
@property(nonatomic,assign) CGPoint scaleCenter;
//定时器
@property(nonatomic,strong) id playerTimer;
//记录当前播放进度
@property(nonatomic,assign) NSTimeInterval currentInterval;
//播放标记
@property(nonatomic,assign) BOOL playMark;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    //控制器旋转监听
    self.device = [[CoreDevice alloc] init];
    self.currentOrientation = UIDeviceOrientationPortrait;
    [self.device registerDeviceOrientation:^(UIDeviceOrientation orientation) {
        if (self.currentOrientation != orientation) {
            [UIView animateWithDuration:0.5 animations:^{
                [self orientationScreen:orientation];
            }];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //初始化工具条
    [self initToolBar];
    //扩展系数
    self.scaleCenter = self.view.center;
    //添加手势监听
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTouchScreen:)];
    [self.view addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userPanScreen:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //移除旋转监听
    [self.device removeDeviceOrientation];
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setIsPlaying:(BOOL)isPlaying{
    _isPlaying = isPlaying;
    self.toolBar.isPlaying = isPlaying;
}

#pragma mark - 初始化

/**
 *  @brief 初始化播放器
 */
- (void)initPlayerWithItem:(AVPlayerItem *)item{
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.playerLayer setFrame:self.view.bounds];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:self.playerLayer];
    //将toolBar放到最前
    [self.view bringSubviewToFront:self.toolBar];
    //添加播放完成的代理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

/**
 *  @brief 初始化底层的toolBar
 */
- (void)initToolBar{
    self.toolBar = [[PlayerToolBar alloc] init];
    self.toolBar.delegate = self;
    self.isToolHiden = NO;
    [self.view addSubview:self.toolBar];
    //布局播放控件
    if (self.isToolHiden) {
        [self.toolBar setFrame:CGRectMake(0, self.view.height, self.view.width, ToolBarHeight)];
    }else{
        [self.toolBar setFrame:CGRectMake(0, self.view.height-ToolBarHeight, self.view.width, ToolBarHeight)];
    }
}

/**
 *  @brief 通过文件名称播放本地视频
 */
- (BOOL)playMediaWithName:(NSString *)name{
    NSString *str = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:str];
    AVPlayerItem* item = [AVPlayerItem playerItemWithURL:url];
    [item addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:item];
    }else{
        [self initPlayerWithItem:item];
    }
    return YES;
}

#pragma mark - 播放控制

- (void)play{
    if (!self.isPlaying) {
        self.isPlaying = YES;
        [self startPlayerTimer];
        [self.player play];
        if (!self.isToolHiden) {
            [self showToolBar:NO];
        }
    }
}

- (void)pause{
    if (self.isPlaying) {
        self.isPlaying = NO;
        [self.player pause];
        [self closePlayerTimer];
        if (self.isToolHiden) {
            [self showToolBar:YES];
        }
    }
}

/**
 *  @brief 播放完成调用
 */
- (void)playDidEnd{
    [self pause];
    //回到初始位置
    [self.player seekToTime:CMTimeMake(0, 1.0)];
    self.toolBar.currentTime =CMTimeMake(0, 1.0);
}

#pragma mark - 对于屏幕旋转的处理

/**
 *  @brief 设置屏幕旋转
 */
- (void)orientationScreen:(UIDeviceOrientation)orientation{
    if (self.currentOrientation == UIDeviceOrientationPortrait) {
        //如果是从竖直状态转过来
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            [self setOrientationLandscapeFrame];
            [self.view setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2)];
            [CoreDevice orientationStatusBar:[CoreDevice orientationFrom:orientation]];
            self.currentOrientation = orientation;
        }
        if (orientation == UIDeviceOrientationLandscapeRight) {
            [self setOrientationLandscapeFrame];
            [self.view setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2)];
            [CoreDevice orientationStatusBar:[CoreDevice orientationFrom:orientation]];
            self.currentOrientation = orientation;
        }
    }else if (UIDeviceOrientationIsLandscape(orientation)){
        //否则是否为反向
        if (self.currentOrientation==UIDeviceOrientationLandscapeLeft) {
            [self.view setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2)];
        }else{
            [self.view setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2)];
        }
        [CoreDevice orientationStatusBar:[CoreDevice orientationFrom:orientation]];
        self.currentOrientation = orientation;
    }else if(orientation == UIDeviceOrientationPortrait){
        //转为竖直方向
        [self.view setTransform:CGAffineTransformIdentity];
        [self setOrientationPortraitFrame];
        [CoreDevice orientationStatusBar:[CoreDevice orientationFrom:orientation]];
        self.currentOrientation = orientation;
    }
}

/**
 *  @brief 设置横屏大小
 */
- (void)setOrientationLandscapeFrame{
    //设置视图大小
    [self.view setFrame:CGRectMake(0, 0, self.view.superview.height, self.view.superview.width)];
    //移到中心点
    self.view.center = self.view.superview.center;
    [self reloadPlayerFrame];
}

/**
 *  @brief 设置竖屏大小
 */
- (void)setOrientationPortraitFrame{
    //设置视图大小
    [self.view setFrame:CGRectMake(0, 0, self.view.superview.width, 200)];
    //移到中心点
    self.view.center = self.scaleCenter;
    [self reloadPlayerFrame];
}

/**
 *  @brief 设置播放视图与控制条的大小
 */
- (void)reloadPlayerFrame{
    //设置播放视图的大小
    [self.playerLayer setFrame:self.view.bounds];
    //设置控制栏的大小
    if (self.isToolHiden) {
        [self.toolBar setFrame:CGRectMake(0, self.view.height, self.view.width, ToolBarHeight)];
    }else{
        [self.toolBar setFrame:CGRectMake(0, self.view.height-ToolBarHeight, self.view.width, ToolBarHeight)];
    }
}

#pragma mark - 播放进度控制

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    [self.toolBar setTotalTime:self.player.currentItem.duration];
}

/**
 *  @brief 开始进度定时器
 */
- (void)startPlayerTimer{
    __weak typeof(self) weakSelf = self;
    self.playerTimer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.toolBar.currentTime = weakSelf.player.currentTime;
    }];
}

/**
 *  @brief 关闭进度计时器
 */
- (void)closePlayerTimer{
    if (self.playerTimer) {
        [self.player removeTimeObserver:self.playerTimer];
    }
}

/**
 *  @brief 手动控制拖动
 */
- (void)userChangeProcess:(CGFloat)value{
    value = value * CMTimeGetSeconds(self.player.currentItem.duration)/(self.view.width);
    self.currentInterval = self.currentInterval + value;
    if (self.currentInterval>CMTimeGetSeconds(self.player.currentItem.duration)) {
        self.currentInterval = CMTimeGetSeconds(self.player.currentItem.duration);
    }
    if (self.currentInterval<0) {
        self.currentInterval = 0;
    }
    //计算要跳转的CMTime
    CMTime target = CMTimeMake(self.currentInterval, 1.0);
    [self.player seekToTime:target];
    self.toolBar.currentTime = target;
}

#pragma mark - 设置工具条的隐藏

/**
 *  @brief 隐藏/显示 toolBar
 */
- (void)showToolBar:(BOOL)isShow{
    if (isShow&&self.isToolHiden) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.toolBar setTransform:CGAffineTransformIdentity];
        } completion:^(BOOL finished) {
            self.isToolHiden = NO;
        }];
        
    }else if(!isShow&&!self.isToolHiden){
        [UIView animateWithDuration:0.5 delay:2 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.toolBar setTransform:CGAffineTransformIdentity];
            [self.toolBar setTransform:CGAffineTransformMakeTranslation(0, self.toolBar.height)];
        } completion:^(BOOL finished) {
            self.isToolHiden = YES;
        }];
    }
}

#pragma mark - 工具条的代理

- (void)clickPlayerButton:(BOOL)needPlay{
    if (needPlay) {
        [self play];
    }else{
        [self pause];
    }
}

#pragma mark - 手势控制

/**
 *  @brief 用户点击了屏幕
 */
- (void)userTouchScreen:(UITapGestureRecognizer *)gesture{
    if (self.isPlaying) {
        [self pause];
    }else{
        [self play];
    }
}

/**
 *  @brief 用户在屏幕上拖动
 */
- (void)userPanScreen:(UIPanGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{//拖动开始
            if (self.isPlaying) {
                [self pause];
                self.currentInterval = CMTimeGetSeconds(self.player.currentTime);
                self.playMark = YES;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{//拖动改变
            CGPoint point = [gesture translationInView:self.view];
            [gesture setTranslation:CGPointZero inView:self.view];
            [self userChangeProcess:point.x];
            break;
        }
        case UIGestureRecognizerStateEnded:{//拖动结束开始
            if (self.playMark) {
                [self play];
                self.playMark = NO;
            }
            break;
        }
        default:
            break;
    }
}

@end
