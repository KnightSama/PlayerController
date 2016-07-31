//
//  CoreDevice.h
//  CoreSDK
//
//  Created by KnightSama on 16/3/10.
//  Copyright © 2016年 KnightSama. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief 设备方向改变回调
 */
typedef void(^DeviceOrientationHandel)(UIDeviceOrientation orientation);


@interface CoreDevice : NSObject

#pragma mark - 设备方向

/**
 *  @brief 注册设备方向监听
 */
- (void)registerDeviceOrientation:(DeviceOrientationHandel)handel;

/**
 *  @brief 移除设备方向监听
 */
- (void)removeDeviceOrientation;

/**
 *  @brief 强制屏幕旋转
 */
+ (void)orientationScreen:(UIInterfaceOrientation)orientation;

/**
 *  @brief 旋转状态栏
 */
+ (void)orientationStatusBar:(UIInterfaceOrientation)orientation;

/**
 *  @brief 由 UIDeviceOrientation 转换为 UIInterfaceOrientation
 */
+ (UIInterfaceOrientation)orientationFrom:(UIDeviceOrientation)orientation;

@end
