//
//  WZSXYSDK.h
//  xiaoyu
//
//  Created by 王战胜 on 2017/5/11.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZSXYSDK : UIViewController
+ (instancetype)shareXYSDK;
- (void)setupXYSDK;
- (void)call:(NSString *)number;
- (void)handup;
- (void)mute:(BOOL)enable;
- (void)switchCamera:(BOOL)enable;
- (void)switchCallModel:(BOOL)enable;
@end
