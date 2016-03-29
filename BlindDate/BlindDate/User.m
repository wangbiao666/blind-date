//
//  User.m
//  BlindDate
//
//  Created by wangbiao on 16/3/25.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "User.h"

static BOOL _loaded = NO;
static User *_instance = nil;

@implementation User

+ (instancetype)currentUser {
    if (!_loaded) {
        _instance = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
        _loaded = YES;
    }
    return _instance;
}

+ (void)loginWithID:(NSString *)objectId username:(NSString *)username {
    _instance = [[User alloc] initWithID:objectId username:username];
    [NSKeyedArchiver archiveRootObject:_instance toFile:[self filePath]];
    _loaded = YES;
}

+ (void)logout {
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:[self filePath] error:nil];
    _instance = nil;
    _loaded = YES;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_objectId forKey:@"objectId"];
    [coder encodeObject:_username forKey:@"username"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _objectId = [coder decodeObjectForKey:@"objectId"];
        _username = [coder decodeObjectForKey:@"username"];
    }
    return self;
}

#pragma mark - Private

- (instancetype)initWithID:(NSString *)objectId username:(NSString *)username {
    if (self = [super init]) {
        self.objectId = objectId;
        self.username = username;
    }
    return self;
}

+ (NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:@"user"];
}

@end
