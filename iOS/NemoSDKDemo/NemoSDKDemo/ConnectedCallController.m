//
//  ConnectedCallController.m
//  NemoSDK
//
//  Created by 杨旭东 on 16/10/14.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import "ConnectedCallController.h"
#import "VideoManager.h"

@interface ConnectedCallController ()

@property (nonatomic, strong) NSMutableArray *streamsIDArr;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@property (weak, nonatomic) IBOutlet UIButton *switchCameraBtn;

@end

@implementation ConnectedCallController{
    CGPoint _origin;
}

#pragma mark life cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller = self;
    
    [[VideoManager sharedInstance] localView:self.view];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self showOrHideButtons];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[VideoManager sharedInstance] clear];
}



#pragma mark Action

- (IBAction)hangupAction:(UIButton *)sender {
    [_nemo hangup];
}

- (IBAction)muteAction:(UIButton *)sender {
    [_nemo enableAudioOfMic:sender.selected];
    sender.selected = !sender.selected;
}

- (IBAction)switchCameraAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_nemo switchCamera:sender.selected ? NemoDeviceType_BackCamera : NemoDeviceType_FrontCamera];
}

- (IBAction)switchCallModel:(UIButton *)sender {
    sender.selected = !sender.selected;

    [_nemo enableVideo:!sender.selected];
    [[VideoManager sharedInstance] audioMode:sender.selected];
}



#pragma mark help Method

static BOOL showAnimation = YES;
- (void)showOrHideButtons{
    if (showAnimation) {
        showAnimation = NO;
        [_buttons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = (UIButton *)obj;
            btn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
            
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












