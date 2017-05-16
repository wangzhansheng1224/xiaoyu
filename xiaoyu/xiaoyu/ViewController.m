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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageV.image = [UIImage imageNamed:@"BG"];
    [self.view addSubview:imageV];
       
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor=[UIColor redColor];
    btn.center = self.view.center;
    [btn setTitle:@"呼叫" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [[WZSXYSDK shareXYSDK]setupXYSDK];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)btnClick{
    [[WZSXYSDK shareXYSDK]call:nil];
}
@end
