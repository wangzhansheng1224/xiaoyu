//
//  TabbarController.h
//  NemoSDKDemo
//
//  Created by 杨旭东 on 2016/12/5.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabbarController : UITabBarController <NemoSDKDelegate>

- (void)setNewOrientation:(BOOL)transform;

@property (nonatomic, assign) NemoCallState callState;

@property (nonatomic, copy) NSString *reason;

@end
