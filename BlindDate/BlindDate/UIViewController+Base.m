//
//  UIViewController+Base.m
//  BlindDate
//
//  Created by wangbiao on 16/3/24.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "UIViewController+Base.h"

@implementation UIViewController (Base)

- (SlideMenuController *)slideMenuController {
    UIViewController *controller = self.parentViewController;
    
    while (controller != nil) {
        if (controller.class == SlideMenuController.class) {
            return (SlideMenuController *)controller;
        } else {
            controller = controller.parentViewController;
        }
    }
    
    return nil;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
