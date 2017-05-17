//
//  WZSXYSDK.m
//  xiaoyu
//
//  Created by 王战胜 on 2017/5/11.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "WZSXYSDK.h"
#import "UIView+PPCategory.h"
#import <NemoSDK.h>
#import "VideoManager.h"
#import "ConnectedCallController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD+FX.h"
#define XYSDK_EXTID @"4b6f9e3bb0ff4b25fbe73ef979132dcdeeda6aa8"

@interface WZSXYSDK ()<NemoSDKDelegate>
@property (nonatomic, strong) NemoSDK *nemo;
@property (nonatomic, strong) UIView *comingCallBackView;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation WZSXYSDK
static WZSXYSDK *xysdk;
+ (instancetype)shareXYSDK{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xysdk = [[WZSXYSDK alloc]init];
    });
    return xysdk;
}

- (void)setupXYSDK{
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    indicator.size = CGSizeMake(80, 80);
//    indicator.center = CGPointMake(self.view.width / 2, self.view.height / 2);
//    indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
//    indicator.clipsToBounds = YES;
//    indicator.layer.cornerRadius = 6;
//    [indicator startAnimating];
//    [[self getCurrentVC].view addSubview:indicator];
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"SDK初始化.."];
    
    _nemo =  [NemoSDK shareNemoSessionExtID:XYSDK_EXTID privateServer:nil];
    [_nemo registerExtUserWithExtUserID:@"wang@hdkj" displayName:@"王" completion:^(NSString *result) {
        
        NSLog(@"%@",result);
        if ([result hasPrefix:@"+86"]) {
//            [indicator removeFromSuperview];
            [hud hide:YES];
        }
        
    }];
    _nemo.delegate = self;
    
}

- (void)nemoSDKDidCall:(NSString *)number
          stateChanged:(NemoCallState)callState
                reason:(NSString *)reason{
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //获取视频控制器
    UIViewController *con = delegate.controller;
    
    switch (callState) {
        case NemoCallState_Connecting: case NemoCallState_Connected :{
            if (![con isMemberOfClass:[ConnectedCallController class]]) {
                ConnectedCallController *vc = [[ConnectedCallController alloc]init];
                [[self getCurrentVC] presentViewController:vc animated:YES completion:nil];
            }
        }
            break;
            
        case NemoCallState_DisConnected:{
            
            delegate.controller = nil;
            
            if ([con isMemberOfClass:[ConnectedCallController class]]) {
                [_player stop];
                [_hud hide:YES];
                [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
            }
            
            if ([reason isEqualToString:@"CANCEL"]) {
                [self comingCallCancel];
                [MBProgressHUD show:@"已取消通话" icon:nil view:nil];
            }else if ([reason isEqualToString:@"BUSY"]){
                [MBProgressHUD show:@"对方忙线中" icon:nil view:nil];
            }else if ([reason isEqualToString:@"STATUS_OK"]){
                [MBProgressHUD show:@"通话已结束" icon:nil view:nil];
            }else if ([reason isEqualToString:@"PEER_NOT_FOUND"]){
                [MBProgressHUD show:@"无人应答" icon:nil view:nil];
            }
            
        }
            break;
    }
    
}


- (void)nemoSDKDidReceiveCall:(NSString *)number displayName:(NSString *)displayName{
    
    [self playcallsounds];
    _comingCallBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    _comingCallBackView.center = self.view.center;
    _comingCallBackView.backgroundColor = [UIColor greenColor];
    
    UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    numLabel.text = number;
    numLabel.textAlignment = NSTextAlignmentCenter;
    [_comingCallBackView addSubview:numLabel];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 200, 20)];
    nameLabel.text = displayName;
    nameLabel.textAlignment = NSTextAlignmentCenter;

    [_comingCallBackView addSubview:nameLabel];
    
    UIButton *rejectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 50, 100, 50)];
    [rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
    [rejectBtn addTarget:self action:@selector(rejectBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_comingCallBackView addSubview:rejectBtn];
    
    UIButton *acceptBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 50, 100, 50)];
    [acceptBtn addTarget:self action:@selector(acceptBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
    [_comingCallBackView addSubview:acceptBtn];
    
    [[self getCurrentVC].view addSubview:_comingCallBackView];
    
    self.comingCallBackView.hidden = NO;
}

- (void)nemoSDKDidVideoChanged:(NSArray<NemoLayout *> *)videos{
    [[VideoManager sharedInstance] videosInSessionChanges:videos];
    [_player stop];
    [_hud hide:YES];
}

- (void)nemoSDKDidShareImageStateChanged:(NemoContentState)state{
    [[VideoManager sharedInstance] shareImageStateChanged:state];
}

- (void)nemoSDKDidDualStreamStateChanged:(NemoDualState)state{
    [[VideoManager sharedInstance] dualStreamStateChanged:state];
}

- (void)rejectBtnClick{
    [_player stop];
    [_nemo hangup];
    self.comingCallBackView.hidden = YES;
}

- (void)acceptBtnClick{
    [_player stop];
    [_nemo answer];
    self.comingCallBackView.hidden = YES;
}

- (void)comingCallCancel{
    if (self.comingCallBackView.hidden == NO) {
        self.comingCallBackView.hidden = YES;
        [_player stop];
    }
}

- (void)call:(NSString *)number{
    _hud = [MBProgressHUD showMessage:@"正在呼叫"];
    [_nemo makeCall:number password:nil];
    _iscall = YES;
   
}

- (void)handup{
    [_nemo hangup];
}

//静音
- (void)mute:(BOOL)enable{
    [_nemo enableAudioOfMic:enable];
}

- (void)switchCamera:(BOOL)enable{
    [_nemo switchCamera:enable ? NemoDeviceType_BackCamera : NemoDeviceType_FrontCamera];
}

- (void)switchCallModel:(BOOL)enable{
    [_nemo enableVideo:!enable];
    [[VideoManager sharedInstance] audioMode:enable];
}



- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (void)playcallsounds{
    
    //声音路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ringtone" ofType:@"wav"];
       //第一个参数  文件路径的URL
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    
    //音量的高低 0-1
    _player.volume = 1;
    
    //无限循环
    _player.numberOfLoops = -1;
    
    //准备播放 去加载数据 歌曲
    [_player prepareToPlay];
    
    //正式播放
    [_player play];
}


@end
