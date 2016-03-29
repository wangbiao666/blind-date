//
//  LoginViewController.m
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "LoginViewController.h"
#import "VerifyHelper.h"
#import "UIHelper.h"
#import "AFNetworkingHelper.h"
#import "User.h"
#import "UtilsMacro.h"

@interface LoginViewController ()

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *fields;

@end

@implementation LoginViewController

- (IBAction)loginButtonPressed:(id)sender {
    if ([self verify]) {
        [UIHelper showLoadingInView:self.view];
        
        NSString *username = [_fields[0] text];
        NSString *password = [_fields[1] text];
        NSDictionary *params = @{@"username": username, @"password": password};
        
        AFNetworkingHelper *helper = [AFNetworkingHelper defaultHelper];
        [helper sendRequestWithURLString:kURLTypeLogin
                              parameters:params
                                 success:^(NSURLSessionDataTask *task, NSDictionary *response) {
                                     [UIHelper dismissLoadingInView:self.view];
                                     [self successWithTask:task response:response];
                                 }
                                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     [UIHelper dismissLoadingInView:self.view];
                                     [self failureWithTask:task error:error];
                                 }];
    }
}

- (IBAction)textFieldDidEndOnExit:(id)sender {
    if (_fields[0] == sender) {
        [sender resignFirstResponder];
        [_fields[1] becomeFirstResponder];
    } else {
        [_fields[1] resignFirstResponder];
    }
}

- (IBAction)touched {
    [self.view endEditing:YES];
}

#pragma mark - Private

- (BOOL)verify {
    //
    NSString *name = [_fields[0] text];
    if ([VerifyHelper isEmptyString:name]) {
        [UIHelper showTipsWithText:@"请输入用户名" inView:self.view];
        return NO;
    }
    
    //
    NSString *password = [_fields[1] text];
    if ([VerifyHelper isEmptyString:password]) {
        [UIHelper showTipsWithText:@"请输入密码" inView:self.view];
        return NO;
    }
    
    return YES;
}

- (void)successWithTask:(NSURLSessionDataTask *)task response:(NSDictionary *)response {
    NSInteger code = [response[@"code"] integerValue];
    if (code == 200) {
        //
        NSDictionary *data = response[@"data"];
        NSString *objectId = data[@"objectId"];
        NSString *username = data[@"username"];
        [User loginWithID:objectId username:username];
        
        //
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:kNotificationTypeLogin object:nil];
        
        //
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSString *text = response[@"msg"];
        [UIHelper showTipsWithText:text inView:self.view];
    }
}

- (void)failureWithTask:(NSURLSessionDataTask *)task error:(NSError *)error {
    [UIHelper showErrorWithText:@"网络异常，请稍候重试" inView:self.view];
}

@end
