//
//  MainViewController.h
//  NemoSDKDemo
//
//  Created by 杨旭东 on 2017/1/9.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *displayNameTF;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitting;

- (void)hasIncomingCall:(NSString *)name number:(NSString *)number;

- (void)comingCallCancel;

@end
