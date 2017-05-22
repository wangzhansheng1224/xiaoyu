//
//  WZSXYSDK.m
//  xiaoyu
//
//  Created by 王战胜 on 2017/5/11.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "WZSXYSDK.h"
#import <NemoSDK.h>
#import "VideoManager.h"
#import "ConnectedCallController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD+FX.h"
#import "ComingCallBackView.h"
#define XYSDK_EXTID @"4b6f9e3bb0ff4b25fbe73ef979132dcdeeda6aa8"

@interface WZSXYSDK ()<NemoSDKDelegate>
@property (nonatomic, strong) NemoSDK *nemo;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ComingCallBackView *comingView;
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

    MBProgressHUD *hud = [MBProgressHUD showMessage:@"SDK初始化.."];
    
    _nemo =  [NemoSDK shareNemoSessionExtID:XYSDK_EXTID privateServer:nil];
    
    [_nemo registerExtUserWithExtUserID:@"wang@hdkj" displayName:@"王" completion:^(NSString *result) {
        
        NSLog(@"%@",result);
        
        if ([result hasPrefix:@"+86"]) {
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
            //如果不是视频聊天界面,创建界面并跳转
            if (![con isMemberOfClass:[ConnectedCallController class]]) {
                ConnectedCallController *vc = [[ConnectedCallController alloc]init];
                [[self getCurrentVC] presentViewController:vc animated:YES completion:nil];
            }
        }
            break;
            
        case NemoCallState_DisConnected:{
            
            delegate.controller = nil;
            
            //如果当前界面是视频聊天界面,跳回上一个界面
            if ([con isMemberOfClass:[ConnectedCallController class]]) {
                //对方拒绝接听和当对方未接听自己提前挂断时,铃音和提示停止
                [_player stop];
                [_hud hide:YES];
                [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
            }
            
            //提示聊天断开原因
            if ([reason isEqualToString:@"CANCEL"]) {
                //对方提前挂断,隐藏接听画面
                [_comingView comingCallCancel];
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
    
    //播放声音
    [self playcallsounds];
    
    //弹出接听画面
    _comingView = [[ComingCallBackView alloc]initWithFrame:CGRectMake(0, 0, 200, 100) NumberLabel:number NameLabel:displayName];
    _comingView.center = self.view.center;
    _comingView.backgroundColor = [UIColor greenColor];
    [[self getCurrentVC].view addSubview:_comingView];
    
}

- (void)nemoSDKDidVideoChanged:(NSArray<NemoLayout *> *)videos{
    [[VideoManager sharedInstance] videosInSessionChanges:videos];
    //对方聊天画面传过来时,铃音和提示画面停止
    [_player stop];
    [_hud hide:YES];
}

- (void)nemoSDKDidShareImageStateChanged:(NemoContentState)state{
    [[VideoManager sharedInstance] shareImageStateChanged:state];
}

- (void)nemoSDKDidDualStreamStateChanged:(NemoDualState)state{
    [[VideoManager sharedInstance] dualStreamStateChanged:state];
}

- (void)call:(NSString *)number{
    _hud = [MBProgressHUD showMessage:@"正在呼叫"];
    [_nemo makeCall:number password:nil];
    _iscall = YES;
}

- (void)handup{
    [_nemo hangup];
}

- (void)answer{
    [_nemo answer];
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

- (void)stop{
    [_player stop];
}
@end
