//
//  PersonalCell.m
//  BlindDate
//
//  Created by wangbiao on 16/3/29.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "PersonalCell.h"
#import "VerifyHelper.h"
#import <UIImageView+WebCache.h>
#import "ConversionHelper.h"
#import "User.h"

@implementation PersonalCell

- (void)setUserInfo:(UserInfo *)userInfo {
    _userInfo = userInfo;
    [self load];
}

- (void)load {
    // 头像
    UIImage *image = [UIImage imageNamed:@"personal_head"];
    NSString *photo = _userInfo.photo;
    if (![VerifyHelper isEmptyString:photo]) {
        NSURL *url = [NSURL URLWithString:photo];
        if (url != nil) {
            [_headImageView sd_setImageWithURL:url placeholderImage:image];
        } else {
            _headImageView.image = image;
        }
    } else {
        _headImageView.image = image;
    }
    
    // 昵称
    NSString *nickname = [ConversionHelper stringWithString:_userInfo.nickname defaultValue:@"-"];
    _nameLabel.text = nickname;
    
    // 性别
    NSString *sex = _userInfo.sex;
    if ([sex isEqualToString:@"男"]) {
        _sexImageView.image = [UIImage imageNamed:@"man"];
    } else if ([sex isEqualToString:@"女"]) {
        _sexImageView.image = [UIImage imageNamed:@"woman"];
    } else {
        _sexImageView.image = nil;
    }
    
    // 年龄
    NSInteger age = _userInfo.ageValue;
    NSString *text = (age > 0 ? [NSString stringWithFormat:@"%ld岁", age] : @"-");
    _ageLabel.text = text;
    
    // 身高
    NSInteger height = _userInfo.heightValue;
    text = (height > 0 ? [NSString stringWithFormat:@"身高: %ldcm", height] : @"身高: -");
    _heightLabel.text = text;
    
    // 学历
    NSString *record = [ConversionHelper stringWithString:_userInfo.record defaultValue:@"-"];
    _recordLabel.text = [NSString stringWithFormat:@"学历: %@", record];
    
    // 地址
    NSString *address = [ConversionHelper stringWithString:_userInfo.address defaultValue:@"-"];
    _addressLabel.text = address;
    
    // 月薪
    NSInteger salary = _userInfo.salaryValue;
    text = (salary > 0 ? [NSString stringWithFormat:@"月薪: %ld元", salary] : @"月薪: -");
    _salaryLabel.text = text;
    
    // 自我介绍
    NSString *introduce = [ConversionHelper stringWithString:_userInfo.introduce
                                                defaultValue:@"-"];
    _introduceLabel.text = introduce;
    
    // 创建日期
    NSString *createdAt = _userInfo.createdAt;
    if (createdAt != nil) {
        _timeLabel.text = [ConversionHelper intervalSinceNowFromDateString:createdAt];
    } else {
        _timeLabel.text = @"-";
    }
    
    // 打招呼
    User *currentUser = [User currentUser];
    if (currentUser == nil) {
        _helloButton.hidden = NO;
    } else {
        BOOL isMe = [_userInfo.objectId isEqualToString:currentUser.objectId];
        _helloButton.hidden = (isMe ? YES : NO);
    }
}

@end
