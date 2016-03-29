//
//  VerifyHelper.m
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "VerifyHelper.h"

@implementation VerifyHelper

+ (BOOL)isEmptyString:(NSString *)string {
    if (string == nil) {
        return YES;
    }
    
    if ([string isKindOfClass:NSNull.class]) {
        return YES;
    }
    
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    NSString *result = [string stringByTrimmingCharactersInSet:set];
    if (result.length == 0) {
        return YES;
    }
    
    return NO;
}

@end
