//
//  User.h
//  BlindDate
//
//  Created by wangbiao on 16/3/25.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *username;

+ (instancetype)currentUser;
+ (void)loginWithID:(NSString *)objectId username:(NSString *)username;
+ (void)logout;

@end
