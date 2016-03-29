//
//  ConversionHelper.m
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "ConversionHelper.h"
#import "VerifyHelper.h"
#import "UtilsMacro.h"

@implementation ConversionHelper

+ (NSString *)toStringWithNumber:(NSNumber *)number defaultValue:(NSString *)value {
    if (number != nil && [number intValue] > 0) {
        return [NSString stringWithFormat:@"%d", [number intValue]];
    } else {
        return value;
    }
}

+ (NSString *)stringWithString:(NSString *)string defaultValue:(NSString *)value {
    if (![VerifyHelper isEmptyString:string]) {
        return string;
    } else {
        return value;
    }
}

+ (NSDictionary *)timeIntervalFromDateString:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [formatter dateFromString:string];
    
    NSCalendarUnit flags = (NSCalendarUnitYear | NSCalendarUnitMonth |
                            NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *componentsPast = [calendar components:flags fromDate:date];
    NSDateComponents *componentsNow = [calendar components:flags fromDate:[NSDate date]];
    
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit:NSCalendarUnitMonth forDate:date];
    NSInteger daysInLastMonth = range.length;
    NSInteger years = componentsNow.year - componentsPast.year;
    NSInteger months = componentsNow.month - componentsPast.month + years * 12;
    NSInteger days = componentsNow.day - componentsPast.day + months * daysInLastMonth;
    NSInteger hours = componentsNow.hour - componentsPast.hour + days * 24;
    NSInteger minutes = componentsNow.minute - componentsPast.minute + hours * 60;
    
    NSDictionary *result = @{kDateTypeYears: [NSNumber numberWithInteger:years],
                             kDateTypeMonths: [NSNumber numberWithInteger:months],
                             kDateTypeDays: [NSNumber numberWithInteger:days],
                             kDateTypeHours: [NSNumber numberWithInteger:hours],
                             kDateTypeMinutes: [NSNumber numberWithInteger:minutes]};
    
    return result;
}

+ (NSString *)intervalSinceNowFromDateString:(NSString *)string {
    NSDictionary *data = [self timeIntervalFromDateString:string];
    NSInteger months = [data[kDateTypeMonths] integerValue];
    NSInteger days = [data[kDateTypeDays] integerValue];
    NSInteger hours = [data[kDateTypeHours] integerValue];
    NSInteger minutes = [data[kDateTypeMinutes] integerValue];
    
    if (minutes < 1) {
        return @"刚刚";
    } else if (minutes < 60) {
        return [NSString stringWithFormat:@"%ld分钟前", minutes];
    } else if (hours < 24) {
        return [NSString stringWithFormat:@"%ld小时前", hours];
    } else if (hours < 48 && days == 1) {
        return @"昨天";
    } else if (days < 30) {
        return [NSString stringWithFormat:@"%ld天前", days];
    } else if (days < 60) {
        return @"一个月前";
    } else if (months < 12) {
        return [NSString stringWithFormat:@"%ld个月前", months];
    } else {
        NSArray *components = [string componentsSeparatedByString:@" "];
        return components.firstObject;
    }
}

@end
