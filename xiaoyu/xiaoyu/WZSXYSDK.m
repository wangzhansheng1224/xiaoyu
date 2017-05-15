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
#import "ViewController.h"
#define XYSDK_EXTID @"4b6f9e3bb0ff4b25fbe73ef979132dcdeeda6aa8"

@interface WZSXYSDK ()<NemoSDKDelegate>
@property (nonatomic, strong) NemoSDK *nemo;
@property (nonatomic, assign) NemoCallState callState;
@property (nonatomic, copy) NSString *reason;
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
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.size = CGSizeMake(80, 80);
    indicator.center = CGPointMake(self.view.width / 2, self.view.height / 2);
    indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
    indicator.clipsToBounds = YES;
    indicator.layer.cornerRadius = 6;
    [indicator startAnimating];
    [[self getCurrentVC].view addSubview:indicator];
    
    _nemo =  [NemoSDK shareNemoSessionExtID:XYSDK_EXTID privateServer:nil];
    [_nemo registerExtUserWithExtUserID:@"wangzs@hdkj" displayName:@"王战胜" completion:^(NSString *result) {
        
        NSLog(@"%@",result);
        if ([result hasPrefix:@"+86"]) {
            [indicator removeFromSuperview];
        }
        
    }];
    _nemo.delegate = self;

}

- (void)nemoSDKDidCall:(NSString *)number
          stateChanged:(NemoCallState)callState
                reason:(NSString *)reason{
    self.callState = callState;
    self.reason = reason;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *con = delegate.controller;
    
    switch (callState) {
        case NemoCallState_Connecting: case NemoCallState_Connected :{
            if ([con isMemberOfClass:[ViewController class]]) {
                [self setNewOrientation:YES];
                ConnectedCallController *vc = [[ConnectedCallController alloc]init];
                [con presentViewController:vc animated:YES completion:nil];
                //                [con performSegueWithIdentifier:@"ConnectedCall" sender:nil];
            }
        }
            break;
            
        case NemoCallState_DisConnected:{
            if ([con isMemberOfClass:[ConnectedCallController class]]) {
                if ([reason isEqualToString:@"STATUS_OK"]) {
                    [con dismissViewControllerAnimated:YES completion:nil];
                    [self setNewOrientation:NO];
                }else{
                    [con dismissViewControllerAnimated:YES completion:nil];
                    [self setNewOrientation:NO];
                }
            }
            
            if ([reason isEqualToString:@"CANCEL"] && [con isMemberOfClass:[ViewController class]]) {
//                ViewController *main = (ViewController *)con;
//                [main comingCallCancel];
            }
            
            NSLog(@"%@",reason);
        }
            break;
    }
    
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (void)setNewOrientation:(BOOL)transform
{
    UIDeviceOrientation curOrientation = [UIDevice currentDevice].orientation;
    UIDeviceOrientation toOrientation = UIDeviceOrientationPortrait;
    
    if  (transform)
    {
        if (UIDeviceOrientationIsLandscape(curOrientation))
        {
            toOrientation = curOrientation;
        }
        else
        {
            toOrientation = UIDeviceOrientationLandscapeLeft;
        }
    }
    
    if(curOrientation == toOrientation)
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationFaceUp] forKey:@"orientation"];
    }
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:toOrientation] forKey:@"orientation"];
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


- (void)call:(NSString *)number{
    [_nemo makeCall:@"10098369336" password:nil];
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

@end
