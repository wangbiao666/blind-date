//
//  RegisterViewController.m
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "RegisterViewController.h"
#import "VerifyHelper.h"
#import "UIHelper.h"
#import "AFNetworkingHelper.h"

@interface RegisterViewController ()

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *fields;

@end

@implementation RegisterViewController

- (IBAction)touched {
    [self.view endEditing:YES];
}

- (IBAction)registerButtonPressed:(id)sender {
    if ([self verify]) {
        [UIHelper showLoadingInView:self.view];
        
        NSString *username = [_fields[0] text];
        NSString *password = [_fields[1] text];
        NSDictionary *params = @{@"username": username, @"password": password};
        
        AFNetworkingHelper *helper = [AFNetworkingHelper defaultHelper];
        [helper sendRequestWithURLString:kURLTypeRegister
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

- (IBAction)textFieldDidEndOnExit:(UITextField *)field {
    NSInteger index = [_fields indexOfObject:field];
    if (index < 2) {
        [field resignFirstResponder];
        [_fields[++index] becomeFirstResponder];
    } else {
        [field resignFirstResponder];
    }
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
    
    NSString *passwordAgain = [_fields[2] text];
    if ([VerifyHelper isEmptyString:passwordAgain]) {
        [UIHelper showTipsWithText:@"请再次输入密码" inView:self.view];
        return NO;
    }
    
    if (![password isEqualToString:passwordAgain]) {
        [UIHelper showTipsWithText:@"两次输入的密码不一致" inView:self.view];
        return NO;
    }
    
    return YES;
}

- (void)successWithTask:(NSURLSessionDataTask *)task response:(NSDictionary *)response {
    NSInteger code = [response[@"code"] integerValue];
    if (code == 200) {
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
