//
//  ComingCallBackView.m
//  xiaoyu
//
//  Created by 王战胜 on 2017/5/22.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "ComingCallBackView.h"
#import "WZSXYSDK.h"

@implementation ComingCallBackView

- (instancetype)initWithFrame:(CGRect)frame NumberLabel:(NSString *)number NameLabel:(NSString *)displayName
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        numLabel.text = number;
        numLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:numLabel];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 200, 20)];
        nameLabel.text = displayName;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:nameLabel];
        
        UIButton *rejectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 50, 100, 50)];
        [rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        [rejectBtn addTarget:self action:@selector(rejectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rejectBtn];
        
        UIButton *acceptBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 50, 100, 50)];
        [acceptBtn addTarget:self action:@selector(acceptBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
        [self addSubview:acceptBtn];

    }
    return self;
}

- (void)rejectBtnClick{
    [[WZSXYSDK shareXYSDK] stop];
    [[WZSXYSDK shareXYSDK] handup];
    self.hidden = YES;
}

- (void)acceptBtnClick{
    [[WZSXYSDK shareXYSDK] stop];
    [[WZSXYSDK shareXYSDK] answer];
    self.hidden = YES;
}

- (void)comingCallCancel{
    if (self.hidden == NO) {
        self.hidden = YES;
        [[WZSXYSDK shareXYSDK] stop];
    }
}
@end
