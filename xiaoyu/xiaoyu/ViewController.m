//
//  ViewController.m
//  xiaoyu
//
//  Created by 王战胜 on 2017/5/11.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "ViewController.h"
#import "WZSXYSDK.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (nonatomic, strong) UITextField *tf;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageV.image = [UIImage imageNamed:@"BG"];
    [self.view addSubview:imageV];
    
    _tf = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    _tf.backgroundColor = [UIColor yellowColor];
    _tf.center = CGPointMake(self.view.center.x, self.view.center.y-150);
    _tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    _tf.text = @"10037415220";
    [self.view addSubview:_tf];
    
       
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.backgroundColor=[UIColor redColor];
    btn.center = self.view.center;
    [btn setTitle:@"呼叫" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [[WZSXYSDK shareXYSDK]setupXYSDK];
}

- (void)btnClick{
    [[WZSXYSDK shareXYSDK]call:_tf.text];
}
@end
