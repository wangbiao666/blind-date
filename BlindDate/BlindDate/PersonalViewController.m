//
//  PersonalViewController.m
//  BlindDate
//
//  Created by wangbiao on 16/3/28.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "PersonalViewController.h"
#import "UserInfo.h"
#import "AFNetworkingHelper.h"
#import "UIHelper.h"
#import <UIImageView+WebCache.h>
#import "ConversionHelper.h"

@interface PersonalViewController ()

@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) UserInfo *object;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *labels;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *editItem;

@end

@implementation PersonalViewController

- (void)viewControllerDidShowWithTag:(NSString *)tag data:(NSObject *)data {
    NSDictionary *entries = (NSDictionary *)data;
    self.isMe = [entries[@"isMe"] boolValue];
    self.objectId = entries[@"objectId"];
    
    [self refresh];
}

- (IBAction)editButtonPressed {
    //
    NSMutableDictionary *data = [@{@"head": _imageView.image} mutableCopy];
    if (_object != nil) {
        data[@"object"] = _object;
    }
    
    //
    [self.navigationController pushViewControllerWithStoryboardID:@"Edit"
                                                         animated:YES data:data];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_isMe ? 2 : 3);
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 114;
    } else if (indexPath.row == 1) {
        return [self theSecondCellHeight];
    } else {
        return 60;
    }
}

#pragma mark - Private

- (void)refresh {
    //
    if (_isMe == NO) {
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"个人资料";
    }
    
    //
    NSDictionary *data = @{@"objectId": _objectId};
    
    AFNetworkingHelper *helper = [AFNetworkingHelper defaultHelper];
    [helper sendRequestWithURLString:kURLTypeInfos parameters:data
                             success:^(NSURLSessionDataTask *task, NSDictionary *response) {
                                 [self successWithTask:task response:response];
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 [self failureWithTask:task error:error];
                             }];
}

- (CGFloat)theSecondCellHeight {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat width = screenSize.width - 64;
    CGSize size = CGSizeMake(width, 0);
    size = [_labels[9] sizeThatFits:size];
    return (size.height + 284);
}

- (void)successWithTask:(NSURLSessionDataTask *)task response:(NSDictionary *)response {
    NSDictionary *data = response[@"data"];
    if (data != nil) {
        self.object = [UserInfo userInfoWithDictionary:data];
        [self reload:_object];
    } else {
        [UIHelper showErrorWithText:@"网络异常，请稍后重试" inView:self.view];
    }
}

- (void)failureWithTask:(NSURLSessionDataTask *)task error:(NSError *)error {
    [UIHelper showErrorWithText:@"网络异常，请稍后重试" inView:self.view];
}

- (void)reload:(UserInfo *)object {
    //
    UIImage *image = [UIImage imageNamed:@"personal_head"];
    NSURL *url = [NSURL URLWithString:object.photo];
    if (url != nil) {
        [_imageView sd_setImageWithURL:url placeholderImage:image];
    } else {
        _imageView.image = image;
    }
    
    //
    NSString *nickname = [ConversionHelper stringWithString:object.nickname defaultValue:@"-"];
    NSString *sex = [ConversionHelper stringWithString:object.sex defaultValue:@"-"];
    NSString *record = [ConversionHelper stringWithString:object.record defaultValue:@"-"];
    NSString *marital = [ConversionHelper stringWithString:object.marital defaultValue:@"-"];
    NSString *address = [ConversionHelper stringWithString:object.address defaultValue:@"-"];
    NSString *contact = [ConversionHelper stringWithString:object.contact defaultValue:@"-"];
    NSString *introduce = [ConversionHelper stringWithString:object.introduce defaultValue:@"-"];
    
    [_labels[0] setText:nickname];
    [_labels[1] setText:sex];
    [_labels[2] setText:record];
    [_labels[3] setText:object.salary];
    [_labels[4] setText:object.age];
    [_labels[5] setText:object.height];
    [_labels[6] setText:marital];
    [_labels[7] setText:address];
    [_labels[8] setText:contact];
    [_labels[9] setText:introduce];
    
    //
    [self.tableView reloadData];
}

@end
