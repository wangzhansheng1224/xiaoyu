//
//  ComingCallBackView.h
//  xiaoyu
//
//  Created by 王战胜 on 2017/5/22.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComingCallBackView : UIView
//初始化
- (instancetype)initWithFrame:(CGRect)frame NumberLabel:(NSString *)display NameLabel:(NSString *)displayName;
//隐藏接听画面
- (void)comingCallCancel;
@end
