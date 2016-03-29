//
//  UserInfo.h
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, strong) NSString *objectId;

@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *record;

@property (nonatomic, strong) NSString *salary;
@property (nonatomic, assign) NSInteger salaryValue;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, assign) NSInteger ageValue;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, assign) NSInteger heightValue;

@property (nonatomic, strong) NSString *marital;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *contact;
@property (nonatomic, strong) NSString *introduce;

@property (nonatomic, strong) NSString *createdAt;

+ (instancetype)userInfoWithDictionary:(NSDictionary *)data;

@end
