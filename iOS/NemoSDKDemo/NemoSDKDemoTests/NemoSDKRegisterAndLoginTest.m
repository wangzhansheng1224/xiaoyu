//
//  NemoSDKRegisterAndLoginTest.m
//  NemoSDKDemo
//
//  Created by 杨旭东 on 2017/1/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NemoSDK.h>

@interface NemoSDKRegisterAndLoginTest : XCTestCase

@property (nonatomic, strong) NemoSDK *sdk;

@end

@implementation NemoSDKRegisterAndLoginTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _sdk = [NemoSDK shareNemoSessionExtID:@"0fd51c70dbaea818181001195fbe7d8443e59087" privateServer:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegisterAndLogin {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"registerAndLoginTest"];
    
    [_sdk registerExtUserWithExtUserID:nil displayName:nil completion:^(NSDictionary *userInfo, NSString *state) {
        XCTAssertTrue(userInfo != nil);
        
        NSString *userName = [userInfo objectForKey:@"userName"];
        NSString *password = [userInfo objectForKey:@"password"];
        
        [_sdk loginWithUserName:userName password:password completion:^(NSString *state) {
            XCTAssertTrue(state == nil);
            
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
