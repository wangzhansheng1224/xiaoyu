//
//  MainViewController.m
//  NemoSDKDemo
//
//  Created by 杨旭东 on 2017/1/9.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "MainViewController.h"
#define XYSDK_EXTID @"4b6f9e3bb0ff4b25fbe73ef979132dcdeeda6aa8"

@interface MainViewController ()

- (IBAction)registerAction:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UITextField *numberTF;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIButton *makeCallBtn;

- (IBAction)makeCall:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *comingCallBackView;

@property (weak, nonatomic) IBOutlet UILabel *comingCallName;

@property (weak, nonatomic) IBOutlet UILabel *comingCallNumber;

- (IBAction)rejectComingCall:(UIButton *)sender;

- (IBAction)acceptComingCall:(UIButton *)sender;




@property (nonatomic, strong) NemoSDK *nemo;


@end

@implementation MainViewController

#pragma mark ui

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _comingCallBackView.layer.borderWidth = .5f;
    _comingCallBackView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:.6].CGColor;
    
    _nemo = [NemoSDK shareNemoSessionExtID:XYSDK_EXTID privateServer:nil];//@"172.17.100.26"
    
    TabbarController *tab = (TabbarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    _nemo.delegate = tab;
    
    self.title = @"CallCenter";
    
    
    #pragma mark 调用rest api签名示例
    NSDictionary *dic = @{@"title":@"test",@"confNo":@"915620695968",@"startTime":@"1484977600000",@"endTime":@"1484987600000",@"autoRecording":@NO,@"autoPublishRecording":@YES};
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *baseUrl = @"https://www.ainemo.com/api/rest/external/v1/liveVideo2/enterprise/your enterpriseID/xiaoyunumber/860640/live?enterpriseId=your enterpriseID";
    
    //若http请求时，body为nil，则对应的entity传空字符串的二进制数据
    NSString *sign = [NemoSDK signUrl:baseUrl methodType:@"post" entity:(void *)jsondata.bytes token:@"your token"];

    NSString *url = [NSString stringWithFormat:@"%@&signature=%@",baseUrl,sign];
    //send http request
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller = self;
}

- (IBAction)registerAction:(UIBarButtonItem *)sender {
    _waitting.hidden = NO;
    [_waitting startAnimating];
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"register and login" message:@"If input is nil,a temp user will be created" preferredStyle:UIAlertControllerStyleAlert];
//    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"extUserID";
//    }];
//    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"displayName";
//    }];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSString *extUserID = [alert.textFields.firstObject text];
//        NSString *displayName = [alert.textFields.lastObject text];
//        [_nemo registerExtUserWithExtUserID:[extUserID isEqualToString:@""] ? nil : extUserID displayName:[displayName isEqualToString:@""] ? nil : displayName completion:^(NSString *result) {
//            [_waitting stopAnimating];
//            if ([[result substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"+86"]) {
//                _displayNameTF.text = result;
//                [_waitting stopAnimating];
//                
//                _makeCallBtn.hidden = NO;
//                sender.enabled = NO;
//            }else{
//                _displayNameTF.text = result;
//                [_waitting stopAnimating];
//            }
//        }];
//    }];
//    [alert addAction:action];
//    [self presentViewController:alert animated:YES completion:nil];
    
    [_nemo registerExtUserWithExtUserID:@"wangzs" displayName:@"王战胜" completion:^(NSString *result) {
        if ([[result substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"+86"]) {
            [_waitting stopAnimating];
            _displayNameTF.text = result;
            [_waitting stopAnimating];
            
            
            _makeCallBtn.hidden = NO;
            sender.enabled = NO;
        }else{
            _displayNameTF.text = result;
            _makeCallBtn.hidden = YES;
        }
    }];
}

- (IBAction)makeCall:(UIButton *)sender {
    [_nemo makeCall:_numberTF.text password:_passwordTF.text];
}

- (IBAction)rejectComingCall:(UIButton *)sender {
    [_nemo hangup];
    self.comingCallBackView.hidden = YES;
}

- (IBAction)acceptComingCall:(UIButton *)sender {
    [_nemo answer];
    self.comingCallBackView.hidden = YES;
}

- (void)comingCallCancel{
    if (self.comingCallBackView.hidden == NO) {
        self.comingCallBackView.hidden = YES;
    }
}





#pragma mark ...

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)hasIncomingCall:(NSString *)name number:(NSString *)number{
    self.comingCallName.text = name;
    self.comingCallNumber.text = number;
    self.comingCallBackView.hidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ConnectedCallController *con = (ConnectedCallController *)segue.destinationViewController;
    con.nemo = _nemo;
}

@end
