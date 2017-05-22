//
//  TabbarController.m
//  NemoSDKDemo
//
//  Created by 杨旭东 on 2016/12/5.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import "TabbarController.h"

@implementation TabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.callState = -1;
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






#pragma mark -- NemoSDK delegate

- (void)nemoSDKDidCall:(NSString *)number stateChanged:(NemoCallState)callState reason:(NSString *)reason{
    self.callState = callState;
    self.reason = reason;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *con = delegate.controller;
    
    switch (callState) {
        case NemoCallState_Connecting: case NemoCallState_Connected :{
            if ([con isMemberOfClass:[MainViewController class]]) {
                [self setNewOrientation:YES];
                [con performSegueWithIdentifier:@"ConnectedCall" sender:nil];
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
            
            if ([reason isEqualToString:@"CANCEL"] && [con isMemberOfClass:[MainViewController class]]) {
                MainViewController *main = (MainViewController *)con;
                [main comingCallCancel];
            }
            
            NSLog(@"%@",reason);
        }
            break;
    }
}

- (void)nemoSDKDidVideoChanged:(NSArray<NemoLayout *> *)videos{
    [[VideoManager sharedInstance] videosInSessionChanges:videos];
}

- (void)nemoSDKDidReceiveCall:(NSString *)number displayName:(NSString *)displayName{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *con = delegate.controller;
    if ([con isMemberOfClass:[MainViewController class]]) {
        MainViewController *main = (MainViewController *)con;
        [main hasIncomingCall:number number:displayName];
    }
}

- (void)nemoSDKDidShareImageStateChanged:(NemoContentState)state{
    [[VideoManager sharedInstance] shareImageStateChanged:state];
}

- (void)nemoSDKDidDualStreamStateChanged:(NemoDualState)state{
    [[VideoManager sharedInstance] dualStreamStateChanged:state];
}


@end
