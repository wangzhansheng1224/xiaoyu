//
//  WZSXYSDK.h
//  xiaoyu
//
//  Created by 王战胜 on 2017/5/11.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZSXYSDK : UIViewController
//如果是呼叫方进入聊天界面播放铃音
@property (nonatomic, assign) BOOL iscall;
+ (instancetype)shareXYSDK;
//初始化SDK
- (void)setupXYSDK;
//呼叫对方
- (void)call:(NSString *)number;
//挂断电话
- (void)handup;
//接听电话
- (void)answer;
//静音
- (void)mute:(BOOL)enable;
//摄像头转换
- (void)switchCamera:(BOOL)enable;
//语音视频转换
- (void)switchCallModel:(BOOL)enable;
//播放铃音
- (void)playcallsounds;
//停止铃音
- (void)stop;
@end
