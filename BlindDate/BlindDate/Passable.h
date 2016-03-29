//
//  Passable.h
//  BlindDate
//
//  Created by wangbiao on 16/3/25.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Passable <NSObject>

@optional
- (void)viewControllerDidShowWithTag:(NSString *)tag data:(NSObject *)data;

@end
