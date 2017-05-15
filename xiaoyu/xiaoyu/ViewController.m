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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
       
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor=[UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [[WZSXYSDK shareXYSDK]setupXYSDK];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)btnClick{
    [[WZSXYSDK shareXYSDK]call:nil];
}
@end
