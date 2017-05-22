//
//  ConnectedCallController.h
//  NemoSDK
//
//  Created by 杨旭东 on 16/10/14.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComingCallView;

@interface ConnectedCallController : UIViewController

@property (nonatomic, copy) NSString *number;

- (IBAction)hangupAction:(UIButton *)sender;

- (IBAction)muteAction:(UIButton *)sender;

- (IBAction)switchCameraAction:(UIButton *)sender;

- (IBAction)switchCallModel:(UIButton *)sender;

@property (nonatomic, strong) NemoSDK *nemo;

@end
