//
//  NavigationHelper.h
//  BlindDate
//
//  Created by wangbiao on 16/3/25.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bucket.h"

@interface NavigationHelper : NSObject <UINavigationControllerDelegate>

@property (nonatomic, strong) Bucket *bucket;

+ (instancetype)defaultHelper;

@end
