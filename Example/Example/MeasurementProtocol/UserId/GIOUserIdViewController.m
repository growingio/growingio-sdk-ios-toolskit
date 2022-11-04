//
//  GIOUserIdViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/5/22.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "GIOUserIdViewController.h"
#import "GIOConstants.h"

@interface GIOUserIdViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;

@end

@implementation GIOUserIdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIdTextField.accessibilityLabel = @"userIdTextField";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置UID为10048
- (IBAction)setUserId:(id)sender {
#if defined(SDK3rd)
    [[GrowingSDK sharedInstance] setLoginUserId:@"10048"];
#elif defined(SDK2nd)
    [Growing setUserId:@"10048"];
#endif

    NSLog(@"设置用户ID为10048");
    
}
//更新用户ID为10084
- (IBAction)changeUserId:(id)sender {
#if defined(SDK3rd)
    [[GrowingSDK sharedInstance] setLoginUserId:@"10084"];
#elif defined(SDK2nd)
    [Growing setUserId:@"10084"];
#endif

    NSLog(@"设置用户ID为10084");
}
//清除用户ID
- (IBAction)cleanUserId:(id)sender {
#if defined(SDK3rd)
    [[GrowingSDK sharedInstance] cleanLoginUserId];
#elif defined(SDK2nd)
    [Growing clearUserId];
#endif
    NSLog(@"清除用户ID");
}
//自定义UID操作
- (IBAction)customSetUserId:(id)sender {
    NSString *userId = self.userIdTextField.text;
#if defined(SDK3rd)
    [[GrowingSDK sharedInstance] setLoginUserId:userId];
#elif defined(SDK2nd)
    [Growing setUserId:userId];
#endif
    NSLog(@"设置用户ID为%@", userId);
}
//UID超过1000个字符操作
- (IBAction)setOutRangeUserId:(id)sender {
    NSString *outRangeUid = [GIOConstants getMyInput];
    NSLog(@"GetMyInput length:%ld",outRangeUid.length);
#if defined(SDK3rd)
    [[GrowingSDK sharedInstance] setLoginUserId:outRangeUid];
#elif defined(SDK2nd)
    [Growing setUserId:outRangeUid];
#endif
}

-(IBAction)setUserKey1:(id)sender{
#if defined(SDK3rd)
    [[GrowingSDK sharedInstance] setLoginUserId:@"10048" userKey:@"phone"];
#elif defined(SDK2nd)
    [Growing setUserId:@"10048"];
#endif
    NSLog(@"设置用户ID为10048,userkey为phone");
}
-(IBAction)setUserKey2:(id)sender{
#if defined(SDK3rd)
    [[GrowingSDK sharedInstance] setLoginUserId:@"10084" userKey:@"weixin"];
#elif defined(SDK2nd)
    [Growing setUserId:@"10084"];
#endif
    NSLog(@"设置用户ID为10084,userkey为phone");
}
- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender {
    [self.userIdTextField resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdTextField && textField.text) {
#if defined(SDK3rd)
        [[GrowingSDK sharedInstance] setLoginUserId:textField.text];
#elif defined(SDK2nd)
    [Growing setUserId:textField.text];
#endif
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
