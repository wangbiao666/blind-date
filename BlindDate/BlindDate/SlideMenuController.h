//
//  SlideMenuController.h
//  BlindDate
//
//  Created by wangbiao on 16/3/24.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideMenuController : UIViewController

@property (nonatomic, weak) IBOutlet UIPanGestureRecognizer *pan;

- (void)switchController;

@end
