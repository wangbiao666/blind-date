//
//  UIColor+Int.h
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Int)

+ (UIColor *)colorWithComponent:(NSInteger)component alpha:(NSInteger)alpha;
+ (UIColor *)colorWithComponent:(NSInteger)component;

+ (UIColor *)colorWithR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b A:(NSInteger)a;
+ (UIColor *)colorWithR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b;

+ (UIColor *)colorWithHex:(NSInteger)hex;

@end
