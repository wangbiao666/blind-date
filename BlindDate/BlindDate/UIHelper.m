//
//  UIHelper.m
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "UIHelper.h"
#import "UIColor+Int.h"

@implementation UIHelper

+ (void)showLoadingInView:(UIView *)view hasText:(BOOL)hasText {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    UIView *container = (view != nil ? view : window);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:container animated:YES];
    hud.color = [UIColor colorWithHex:0xd78b93];
    if (hasText) {
        hud.labelText = @"加载中...";
    }
}

+ (void)showLoadingInView:(UIView *)view {
    [self showLoadingInView:view hasText:NO];
}

+ (void)dismissLoadingInView:(UIView *)view {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    UIView *container = (view != nil ? view : window);
    [MBProgressHUD hideHUDForView:container animated:YES];
}

+ (void)showTipsWithText:(NSString *)text inView:(UIView *)view {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    UIView *container = (view != nil ? view : window);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:container animated:YES];
    
    hud.color = [UIColor colorWithHex:0xd78b93];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info"]];
    hud.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
    hud.detailsLabelText = text;
    
    [hud hide:YES afterDelay:1.5];
}

+ (void)showErrorWithText:(NSString *)text inView:(UIView *)view {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    UIView *container = (view != nil ? view : window);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:container animated:YES];
    
    hud.color = [UIColor colorWithHex:0xd78b93];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
    hud.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
    hud.detailsLabelText = text;
    
    [hud hide:YES afterDelay:1.5];
}

@end
