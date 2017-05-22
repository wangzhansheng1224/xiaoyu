//
//  NemoSDKDemoUITests.m
//  NemoSDKDemoUITests
//
//  Created by 杨旭东 on 2016/10/18.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NemoSDKDemoUITests : XCTestCase

@end

@implementation NemoSDKDemoUITests{
    XCUIApplication *app;
}

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    app = [[XCUIApplication alloc] init];
    [app launch];
    
    self.continueAfterFailure = YES;
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMakeCall {
    // Use recording to get started writing UI tests.
    
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIElement *navigation = app.navigationBars[@"Public"];
    if (navigation.exists) {
        [self addUIInterruptionMonitorWithDescription:@"sys alertview" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
            XCUIElement *allowBtn = interruptingElement.buttons[@"Allow"];
            if (allowBtn.exists) {
                [allowBtn tap];
            }
            
            XCUIElement *confirmBtn = interruptingElement.buttons[@"好"];
            if (confirmBtn.exists) {
                [confirmBtn tap];
            }
            return YES;
        }];
        
        //异步验证注册登录是否成功
        XCTestExpectation *loginExpectation = [self expectationWithDescription:@"register and login"];
        XCUIElement *displayNameTF = app.textFields[@"displayName"];
        [navigation.buttons[@"login"] tap];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *displayName = (NSString *)displayNameTF.value;
            if (![displayName hasPrefix:@"+86-"]) {
                XCTFail("error displayName:%@",displayName);
            }
            [loginExpectation fulfill];
        });
        
        [self waitForExpectationsWithTimeout:8.0f handler:nil];
        
        //输入小鱼号
        XCUIElement *textField = app.textFields[@"number"];
        [textField tap];
        [textField typeText:@"219076"];
        
        //呼叫
        [app.buttons[@"Call"] tap];
        [app pressForDuration:1.0];
        
        [self functionTest];
    }else{
        XCTFail("app launch failed");
    }
}

- (void)functionTest{
    XCUIElement *element = [[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element;
    
    XCTestExpectation *connectExpectation = [self expectationWithDescription:@"disConnected expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [element tap];
        XCUIElement *video = [self foundVideo:[app childrenMatchingType:XCUIElementTypeWindow]];
        if (video.exists) {
            [connectExpectation fulfill];
        }else{
            XCTFail("can not make call correct");
        }
    });
    [self waitForExpectationsWithTimeout:6.0 handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail("time out");
        }
    }];
    
    
    
    [element pressForDuration:1.0];
    [element pressForDuration:1.0];
    
    //静音
    [element pressForDuration:10.0];
    [element tap];
    XCUIElement *silenceBtn = app.buttons[@"silence"];
    if (silenceBtn.exists) {
        [silenceBtn tap];
    }else{
        [self notFoundBtn:@"silence"];
    }
    
    //关闭静音
    [element pressForDuration:10.0];
    [element tap];
    XCUIElement *voiceBtn = app.buttons[@"voice"];
    if (voiceBtn.exists) {
        [voiceBtn tap];
    }else{
        [self notFoundBtn:@"voice"];
    }
    
    //切换到后置摄像头
    [element pressForDuration:10.0];
    [element tap];
    XCUIElement *backCameraBtn = app.buttons[@"backCamera"];
    if (backCameraBtn.exists) {
        [backCameraBtn tap];
    }else{
        [self notFoundBtn:@"backCamera"];
    }
    
    //切换到前置摄像头
    [element pressForDuration:10.0];
    [element tap];
    XCUIElement *frontCameraBtn = app.buttons[@"frontCamera"];
    if (frontCameraBtn.exists) {
        [frontCameraBtn tap];
    }else{
        [self notFoundBtn:@"frontCamera"];
    }
    
    //音频模式
    [element pressForDuration:10.0];
    [element tap];
    XCUIElement *audioBtn = app.buttons[@"audio"];
    if (audioBtn.exists) {
        [audioBtn tap];
    }else{
        [self notFoundBtn:@"audio"];
    }
    
    //视频模式
    [element pressForDuration:10.0];
    [element tap];
    XCUIElement *videoBtn = app.buttons[@"video"];
    if (videoBtn.exists) {
        [videoBtn tap];
    }else{
        [self notFoundBtn:@"video"];
    }
    
    //切换大屏
    for (int i = 0; i < 6; i++) {
        XCUIElement *video = [self foundVideo:[app childrenMatchingType:XCUIElementTypeWindow]];
        if (video.exists) {
            [video tap];
        }else{
            XCTFail("can not find video view");
        }
        
        sleep(1);
    }
    
    //挂断
    [element pressForDuration:5];
    [element tap];
    XCUIElement *hangupBtn = app.buttons[@"hangup"];
    if (hangupBtn.exists) {
        [hangupBtn tap];
    }else{
        [self notFoundBtn:@"hangup"];
    }
    
    XCTestExpectation *disConnectedExpectation = [self expectationWithDescription:@"disConnected expextation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCUIElement *navigation = app.navigationBars[@"Public"];
        if (navigation.exists) {
            [disConnectedExpectation fulfill];
        }else{
            XCTFail("hangup failed");
        }
    });
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail("hangup timeout");
        }
    }];
}

- (void)notFoundBtn:(NSString *)msg{
    XCTFail("not found button named %@",msg);
}

- (XCUIElement *)foundVideo:(XCUIElementQuery *)appQuery{
    static int count = 0;
    count = count + 1;
    for (int i = 0; i < appQuery.count; i++) {
        XCUIElement *element = [appQuery elementBoundByIndex:i];
        CGSize size = element.frame.size;
        CGSize videoSize = CGSizeMake(120, 80);
        if (CGSizeEqualToSize(size, videoSize)) {
            count = 0;
            return element;
        }
    }
    
    if (count > 10) {
        return nil;
    }else return [self foundVideo:[appQuery childrenMatchingType:XCUIElementTypeOther]];
}





- (void)testAcceptCall{
    XCUIElement *navigation = app.navigationBars[@"Public"];
    if (navigation.exists) {
        [self addUIInterruptionMonitorWithDescription:@"sys alertview" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
            XCUIElement *allowBtn = interruptingElement.buttons[@"Allow"];
            if (allowBtn.exists) {
                [allowBtn tap];
            }
            
            XCUIElement *confirmBtn = interruptingElement.buttons[@"好"];
            if (confirmBtn.exists) {
                [confirmBtn tap];
            }
            return YES;
        }];
        
        //异步验证注册登录是否成功
        XCTestExpectation *loginExpectation = [self expectationWithDescription:@"register and login"];
        XCUIElement *displayNameTF = app.textFields[@"displayName"];
        [navigation.buttons[@"login"] tap];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *displayName = (NSString *)displayNameTF.value;
            if (![displayName hasPrefix:@"+86-"]) {
                XCTFail("error displayName:%@",displayName);
            }
            [loginExpectation fulfill];
        });
        
        [self waitForExpectationsWithTimeout:8.0f handler:nil];
        
        //检测来电
        XCTestExpectation *acceptExpectation = [self expectationWithDescription:@"accept call"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCUIElement *accept = app.buttons[@"Accept"];
            if (accept.exists) {
                [acceptExpectation fulfill];
                [accept tap];
            }
        });
        [self waitForExpectationsWithTimeout:16.0 handler:nil];
        
        [self functionTest];
    }else{
        XCTFail("app launch failed");
    }
}

@end



































