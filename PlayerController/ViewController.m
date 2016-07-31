//
//  ViewController.m
//  PlayerController
//
//  Created by KnightSama on 16/7/29.
//  Copyright © 2016年 KnightSama. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "UIView+CoreFrame.h"

@interface ViewController ()
@property(nonatomic,strong) PlayerViewController *playerVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加播放器
    self.playerVC = [[PlayerViewController alloc] init];
    [self addChildViewController:self.playerVC];
    [self.view addSubview:self.playerVC.view];
    [self.playerVC.view setFrame:CGRectMake(0, 0, self.view.width, 200)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.playerVC playMediaWithName:@"TEST_AV001.mp4"];
}

- (BOOL)shouldAutorotate{
    return NO;
}

@end
