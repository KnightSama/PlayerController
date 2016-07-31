//
//  CoreDevice.m
//  CoreSDK
//
//  Created by KnightSama on 16/3/10.
//  Copyright © 2016年 KnightSama. All rights reserved.
//

#import "CoreDevice.h"

@interface CoreDevice ()
//设备方向改变回调
@property(nonatomic,strong) DeviceOrientationHandel orientationHandel;
@end

@implementation CoreDevice

/**
 *  @brief 注册设备方向监听
 */
- (void)registerDeviceOrientation:(DeviceOrientationHandel)handel{
    //开始设备方向监听
    self.orientationHandel = handel;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/**
 *  @brief 设备方向改变的方法
 */
- (void)deviceOrientationChanged:(NSNotification *)noti{
    if (self.orientationHandel) {
        UIDeviceOrientation orientaion = [[UIDevice currentDevice] orientation];
        self.orientationHandel(orientaion);
    }
}

/**
 *  @brief 移除设备方向监听
 */
- (void)removeDeviceOrientation{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

/**
 *  @brief 强制屏幕旋转
 */
+ (void)orientationScreen:(UIInterfaceOrientation)orientation{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

/**
 *  @brief 旋转状态栏
 */
+ (void)orientationStatusBar:(UIInterfaceOrientation)orientation{
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
}

/**
 *  @brief 由 UIDeviceOrientation 转换为 UIInterfaceOrientation
 */
+ (UIInterfaceOrientation)orientationFrom:(UIDeviceOrientation)orientation{
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationLandscapeLeft;
            break;
        default:
            return UIInterfaceOrientationUnknown;
            break;
    }
}

@end
