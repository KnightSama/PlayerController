//
//  PlayerToolBar.m
//  ComicPark
//
//  Created by KnightSama on 16/7/22.
//  Copyright © 2016年 KnightSama. All rights reserved.
//

#import "PlayerToolBar.h"
#import "UIView+CoreFrame.h"

@interface PlayerToolBar ()
//播放按钮
@property(nonatomic,strong) UIButton *playBtn;
//播放控制条
@property(nonatomic,strong) UIProgressView *progress;
//播放进度展示框
@property(nonatomic,strong) UILabel *textLabel;
@end

@implementation PlayerToolBar

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0.500 alpha:0.500];
        //初始化播放键
        self.playBtn = [[UIButton alloc] init];
        [self.playBtn addTarget:self action:@selector(clickPlayerBtn) forControlEvents:UIControlEventTouchUpInside];
        self.isPlaying = NO;
        [self addSubview:self.playBtn];
        //播放进度展示框
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.text = @"--:--/--:--";
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.textLabel];
        //初始化播放条
        self.progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        self.progress.backgroundColor = [UIColor whiteColor];
        self.progress.progressTintColor = [UIColor colorWithRed:1.000 green:0.435 blue:0.812 alpha:1.000];
        [self addSubview:self.progress];
    }
    return self;
}

- (void)layoutSubviews{
    //布局按钮视图
    [self.playBtn setFrame:CGRectMake(5, 5, self.height-10, self.height-10)];
    [self.playBtn setContentMode:UIViewContentModeScaleAspectFill];
    [self.playBtn setBackgroundImage:[self imageWithPlayStatus] forState:UIControlStateNormal];
    //布局展示框
    [self.textLabel setFrame:CGRectMake(self.width-5-100, 5, 100, self.playBtn.height)];
    //布局播放条视图
    [self.progress setFrame:CGRectMake(self.playBtn.right+10, self.height/2.0-1, self.width-self.playBtn.right-self.textLabel.width-15, self.playBtn.height)];
}

#pragma mark - 播放按钮相关的方法

/**
 *  @brief 设置播放按钮状态
 */
- (void)setIsPlaying:(BOOL)isPlaying{
    _isPlaying = isPlaying;
    [self.playBtn setBackgroundImage:[self imageWithPlayStatus] forState:UIControlStateNormal];
}

/**
 *  @brief 点击了播放按钮
 */
- (void)clickPlayerBtn{
    self.isPlaying = self.isPlaying?NO:YES;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(clickPlayerButton:)]) {
        [self.delegate clickPlayerButton:self.isPlaying];
    }
    [self.playBtn setBackgroundImage:[self imageWithPlayStatus] forState:UIControlStateNormal];
}

/**
 *  @brief 通过播放状态获得按钮图片
 */
- (UIImage *)imageWithPlayStatus{
    if (self.isPlaying) {
        return [UIImage imageNamed:@"Player_Pause.png"];
    }else{
        return [UIImage imageNamed:@"Player_start.png"];
    }
}

#pragma mark - 播放进度相关的方法

- (void)setTotalTime:(CMTime)totalTime{
    _totalTime = totalTime;
    self.textLabel.text = [NSString stringWithFormat:@"00:00/%@",[self timeStringFrom:totalTime]];
    
}

- (void)setCurrentTime:(CMTime)currentTime{
    self.textLabel.text = [NSString stringWithFormat:@"%@/%@",[self timeStringFrom:currentTime],[self timeStringFrom:_totalTime]];
    //播放比例
    CGFloat progress = CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(_totalTime);
    self.progress.progress = progress;
}

/**
 *  @brief CMTime转换为时间字符串
 */
- (NSString *)timeStringFrom:(CMTime)time{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:CMTimeGetSeconds(time)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"mm:ss";
    return [formatter stringFromDate:date];
}

@end
