//
//  PlayerViewController.h
//  ComicPark
//
//  Created by KnightSama on 16/7/25.
//  Copyright © 2016年 KnightSama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController

/**
 *  @brief 通过文件名称播放本地视频
 */
- (BOOL)playMediaWithName:(NSString *)name;

@end
