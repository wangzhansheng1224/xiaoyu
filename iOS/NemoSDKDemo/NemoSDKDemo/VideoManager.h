//
//  VideoManager.h
//  NemoSDKDemo
//
//  Created by 杨旭东 on 2016/12/22.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <NemoBaseView.h>

@interface VideoManager : NSObject

+ (VideoManager *)sharedInstance;

- (void)localView:(UIView *)superView;

- (void)audioMode:(BOOL)audio;

- (void)videosInSessionChanges:(NSArray *)videosInfo;

- (void)shareImageStateChanged:(NemoContentState)state;

- (void)dualStreamStateChanged:(NemoDualState)state;

- (void)clear;

@end
