//
//  PlayerToolBar.h
//  ComicPark
//
//  Created by KnightSama on 16/7/22.
//  Copyright © 2016年 KnightSama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>
@protocol PlayerToolBarDelegate <NSObject>
/**
 *  @brief 点击了播放按钮
 */
- (void)clickPlayerButton:(BOOL)needPlay;

@end

@interface PlayerToolBar : UIView

/**
 *  @brief 代理
 */
@property(nonatomic,weak) id<PlayerToolBarDelegate> delegate;

/**
 *  @brief 是否正在播放
 */
@property(nonatomic,assign) BOOL isPlaying;

/**
 *  @brief 设置播放总时间
 */
@property(nonatomic,assign) CMTime totalTime;

/**
 *  @brief 设置当前播放时间
 */
@property(nonatomic,assign) CMTime currentTime;
@end
