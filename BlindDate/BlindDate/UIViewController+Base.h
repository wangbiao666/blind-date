//
//  UIViewController+Base.h
//  BlindDate
//
//  Created by wangbiao on 16/3/24.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideMenuController.h"
#import "Passable.h"
#import "NavigationHelper.h"
#import "UINavigationController+Passable.h"

@interface UIViewController (Base)

@property (nonatomic, readonly) SlideMenuController *slideMenuController;

@end
