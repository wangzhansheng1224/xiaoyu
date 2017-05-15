//
//  ConnectedCallController.m
//  xiaoyu
//
//  Created by 王战胜 on 2017/5/11.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "ConnectedCallController.h"
#import "VideoManager.h"
#import "AppDelegate.h"
#import "WZSXYSDK.h"

@interface ConnectedCallController ()
@property (strong, nonatomic) NSMutableArray *buttons;
@end

@implementation ConnectedCallController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller = self;
    
    [[VideoManager sharedInstance] localView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller = nil;
    
    [[VideoManager sharedInstance] clear];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self showOrHideButtons];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _buttons = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<4; i++) {
        UIButton *button = [[UIButton alloc]init];
        button.tag = 1000+i;
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [_buttons addObject:button];
    }
    
    // Do any additional setup after loading the view.
}

- (void)btnClick:(UIButton *)sender{
    if (sender.tag == 1000) {
        [[WZSXYSDK shareXYSDK] handup];
    }else if (sender.tag == 1001){
        [[WZSXYSDK shareXYSDK] mute:sender.selected];
        sender.selected = !sender.selected;
    }else if (sender.tag == 1002){
        sender.selected = !sender.selected;
        [[WZSXYSDK shareXYSDK] switchCamera:sender.selected];
    }else if (sender.tag == 1003){
        sender.selected = !sender.selected;
        [[WZSXYSDK shareXYSDK] switchCallModel:sender.selected];
    }
}

static BOOL showAnimation = YES;
- (void)showOrHideButtons{
    if (showAnimation) {
        showAnimation = NO;
        [_buttons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = (UIButton *)obj;
            btn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
            btn.frame = CGRectMake(20+100*(btn.tag-1000), 20, 80, 40);
            
            if (btn.tag == 1000) {
                [btn setTitle:@"挂断" forState:UIControlStateNormal];
            }else if (btn.tag == 1001) {
                [btn setTitle:@"静音" forState:UIControlStateNormal];
                [btn setTitle:@"有声" forState:UIControlStateSelected];
            }else if (btn.tag == 1002) {
                [btn setTitle:@"后置" forState:UIControlStateNormal];
                [btn setTitle:@"前置" forState:UIControlStateSelected];
            }else if (btn.tag == 1003) {
                [btn setTitle:@"语音" forState:UIControlStateNormal];
                [btn setTitle:@"视频" forState:UIControlStateSelected];
            }
            
            [UIView animateWithDuration:1.0f animations:^{
                btn.alpha = 1;
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1.0f animations:^{
                    btn.alpha = 0;
                } completion:^(BOOL finished) {
                    showAnimation = YES;
                }];
            });
        }];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self showOrHideButtons];
}

@end
