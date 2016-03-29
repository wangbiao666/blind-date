//
//  Bucket.h
//  BlindDate
//
//  Created by wangbiao on 16/3/25.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBucketKeyTypeTag @"kBucketDataKeyTypeTag"
#define kBucketKeyTypeData @"kBucketDataKeyTypeData"

@interface Bucket : NSObject

- (instancetype)init;
- (void)bucketInWithKey:(NSString *)key value:(NSObject *)value;
- (NSObject *)bucketOutWithKey:(NSString *)key;
- (NSObject *)valueForKey:(NSString *)key;

@end
