//
//  ConversionHelper.h
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversionHelper : NSObject

+ (NSString *)toStringWithNumber:(NSNumber *)number defaultValue:(NSString *)value;
+ (NSString *)stringWithString:(NSString *)string defaultValue:(NSString *)value;
+ (NSDictionary *)timeIntervalFromDateString:(NSString *)string;
+ (NSString *)intervalSinceNowFromDateString:(NSString *)string;

@end
