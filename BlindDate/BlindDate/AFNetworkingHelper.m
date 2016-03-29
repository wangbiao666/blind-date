//
//  AFNetworkingHelper.m
//  BlindDate
//
//  Created by wangbiao on 16/3/25.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "AFNetworkingHelper.h"

static AFNetworkingHelper *_instance = nil;

@interface AFNetworkingHelper ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation AFNetworkingHelper

+ (instancetype)defaultHelper {
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        _instance = [[super allocWithZone:NULL] init];
        [_instance initialization];
    });
    
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [AFNetworkingHelper defaultHelper];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [AFNetworkingHelper defaultHelper];
}

#pragma mark - HTTP

- (void)sendRequestWithURLString:(NSString *)urlString
                      parameters:(NSDictionary *)parameters
                         success:(void (^)(NSURLSessionDataTask *, id))success
                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
                           cache:(BOOL)useCache {
    //
    if (useCache == YES) {
        _manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    } else {
        _manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    
    //
    if (parameters != nil) { // POST
        [_manager POST:urlString parameters:parameters progress:nil
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   @try {
                       success(task, responseObject);
                   } @catch (NSException *exception) {
                       NSLog(@"[%@]throws exception: %@", NSStringFromSelector(_cmd), exception);
                   }
               }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   @try {
                       failure(task, error);
                   } @catch (NSException *exception) {
                       NSLog(@"[%@]throws exception: %@", NSStringFromSelector(_cmd), exception);
                   }
               }];
    } else { // GET
        [_manager GET:urlString parameters:parameters progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  @try {
                      success(task, responseObject);
                  } @catch (NSException *exception) {
                      NSLog(@"[%@]throws exception: %@", NSStringFromSelector(_cmd), exception);
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  @try {
                      failure(task, error);
                  } @catch (NSException *exception) {
                      NSLog(@"[%@]throws exception: %@", NSStringFromSelector(_cmd), exception);
                  }
              }];
    }
}

- (void)sendRequestWithURLString:(NSString *)urlString
                      parameters:(NSDictionary *)parameters
                         success:(void (^)(NSURLSessionDataTask *, id))success
                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    [self sendRequestWithURLString:urlString parameters:parameters
                           success:success failure:failure cache:NO];
}

- (void)sendRequestWithURLString:(NSString *)urlString
                         success:(void (^)(NSURLSessionDataTask *, id))success
                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
                           cache:(BOOL)useCache {
    [self sendRequestWithURLString:urlString parameters:nil
                           success:success failure:failure cache:useCache];
}

- (void)sendRequestWithURLString:(NSString *)urlString
                         success:(void (^)(NSURLSessionDataTask *, id))success
                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    [self sendRequestWithURLString:urlString parameters:nil
                           success:success failure:failure cache:NO];
}

- (void)uploadWithURLString:(NSString *)urlString
                       data:(NSData *)data
                    success:(void (^)(NSURLResponse *, id))success
                    failure:(void (^)(NSURLResponse *, NSError *))failure {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //
    [request addValue:@"b21fbd9b0ce4879dc618f6f685c223e0"
   forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [request addValue:@"8f397fe28f5e02d316d9af109b3fcdc9"
   forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
    //
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    
    //
    NSURLSessionDataTask *task = [_manager dataTaskWithRequest:request
                                             completionHandler:^(NSURLResponse *response,
                                                                 id object, NSError *error) {
                                                 @try {
                                                     if (error != nil) {
                                                         failure(response, error);
                                                     } else {
                                                         success(response, object);
                                                     }
                                                 } @catch (NSException *exception) {
                                                     NSLog(@"throws exception: %@", exception);
                                                 }
                                             }];
    [task resume];
}

#pragma mark - Private

- (void)initialization {
    self.manager = [AFHTTPSessionManager manager];
}

@end
