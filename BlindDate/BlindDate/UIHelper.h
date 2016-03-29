//
//  UIHelper.h
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>

@interface UIHelper : NSObject

+ (void)showLoadingInView:(UIView *)view hasText:(BOOL)hasText;
+ (void)showLoadingInView:(UIView *)view;
+ (void)dismissLoadingInView:(UIView *)view;
+ (void)showTipsWithText:(NSString *)text inView:(UIView *)view;
+ (void)showErrorWithText:(NSString *)text inView:(UIView *)view;

@end
