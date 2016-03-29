//
//  HomeViewController.m
//  BlindDate
//
//  Created by wangbiao on 16/3/24.
//  Copyright © 2016年 wangbiao. All rights reserved.
//

#import "HomeViewController.h"
#import "UIViewController+Base.h"
#import "UserInfo.h"
#import "PersonalCell.h"
#import "User.h"
#import "UtilsMacro.h"
#import <MJRefresh.h>
#import "AFNetworkingHelper.h"
#import "VerifyHelper.h"
#import "UIHelper.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL noMore;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSDictionary *filterData;

@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, weak) IBOutlet UITextField *field;
@property (nonatomic, weak) IBOutlet UIView *searchContainer;

@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.slideMenuController.pan.enabled = YES;
    [self registerNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.slideMenuController.pan.enabled = NO;
    [self unregisterNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置委托
    NavigationHelper *helper = [NavigationHelper defaultHelper];
    self.navigationController.delegate = helper;
    
    // 初始化设置
    self.page = 0;
    self.noMore = NO;
    
    // 设置搜索框宽度 & 表视图的滚动
    CGFloat width = [[UIScreen mainScreen] bounds].size.width - 110;
    CGRect frame = _searchContainer.frame;
    frame.size.width = width;
    _searchContainer.frame = frame;
    _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    // 添加下拉刷新 & 上拉加载更多
    [self addHeader];
    [self addFooter];
    
    // 载入数据
    [self load];
}

- (void)viewControllerDidShowWithTag:(NSString *)tag data:(NSObject *)data {
    self.filterData = (NSDictionary *)data;
    [self startSearching];
}

- (IBAction)menuButtonPressed {
    [self.slideMenuController switchController];
}

- (IBAction)textFieldDidEndOnExit {
    [self startSearching];
}

- (IBAction)filterButtonPressed {
    [self.navigationController pushViewControllerWithStoryboardID:@"Filter"
                                                         animated:YES data:_filterData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonalCell *cell = (PersonalCell *)[_table dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *data = _objects[indexPath.row];
    UserInfo *userInfo = [UserInfo userInfoWithDictionary:data];
    cell.userInfo = userInfo;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isMe = NO;
    
    PersonalCell *cell = (PersonalCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *objectId = cell.userInfo.objectId;
    
    User *currentUser = [User currentUser];
    if (currentUser != nil) {
        isMe = [currentUser.objectId isEqualToString:objectId];
    }
    
    NSDictionary *data = @{@"isMe": [NSNumber numberWithBool:isMe], @"objectId": objectId};
    [self.navigationController pushViewControllerWithStoryboardID:@"Personal"
                                                         animated:YES data:data];
}

#pragma mark - Private

- (void)registerNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didLogin) name:kNotificationTypeLogin object:nil];
    [center addObserver:self selector:@selector(didLogout)
                   name:kNotificationTypeLogout object:nil];
}

- (void)unregisterNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)didLogin {
    [_table reloadData];
}

- (void)didLogout {
    [_table reloadData];
}

- (void)addHeader {
    MJRefreshNormalHeader *header =
    [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                     refreshingAction:@selector(refresh)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    _table.mj_header = header;
}

- (void)addFooter {
    MJRefreshBackNormalFooter *footer =
    [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                         refreshingAction:@selector(loadMore)];
    footer.stateLabel.hidden = YES;
    _table.mj_footer = footer;
}

- (void)load {
    //
    [_table.mj_header beginRefreshing];
    
    //
    CGFloat y = _table.contentOffset.y - _table.mj_header.frame.size.height;
    [_table setContentOffset:CGPointMake(0, y) animated:YES];
    
    //
    [self fetchObjectsOnPage:0 refresh:YES cache:YES];
}

- (void)refresh {
    [self fetchObjectsOnPage:0 refresh:YES cache:NO];
}

- (void)loadMore {
    if (_noMore == YES) {
        if ([self.table.mj_footer isRefreshing]) {
            [self.table.mj_footer endRefreshing];
        }
        
        [UIHelper showTipsWithText:@"没有更多的数据" inView:self.view];
    } else {
        [self fetchObjectsOnPage:(_page + 1) refresh:NO cache:NO];
    }
}

- (void)fetchObjectsOnPage:(NSInteger)page refresh:(BOOL)refresh cache:(BOOL)cache {
    //
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"page"] = [NSNumber numberWithInteger:page];
    
    NSString *keyword = [_field text];
    if (![VerifyHelper isEmptyString:keyword]) {
        params[@"keyword"] = keyword;
    }
    
    if (_filterData != nil) {
        [params addEntriesFromDictionary:_filterData];
    }
    
    //
    AFNetworkingHelper *helper = [AFNetworkingHelper defaultHelper];
    [helper sendRequestWithURLString:kURLTypeList parameters:params
                             success:^(NSURLSessionDataTask *task, NSDictionary *response) {
                                 [self requestDidCompleted];
                                 [self successWithTask:task response:response refresh:refresh];
                             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 [self requestDidCompleted];
                                 [self failureWithTask:task error:error];
                             } cache:cache];
}

- (void)requestDidCompleted {
    [UIHelper dismissLoadingInView:self.view];
    
    if ([_table.mj_header isRefreshing]) {
        [_table.mj_header endRefreshing];
    }
    
    if ([_table.mj_footer isRefreshing]) {
        [_table.mj_footer endRefreshing];
    }
}

- (void)successWithTask:(NSURLSessionDataTask *)task
               response:(NSDictionary *)response refresh:(BOOL)refresh {
    NSInteger code = [response[@"code"] intValue];
    if (code == 200) {
        NSArray *entries = response[@"data"];
        if (entries != nil) {
            if (refresh == YES) {
                self.page = 0;
                self.noMore = NO;
                self.objects = [entries mutableCopy];
            } else {
                self.page++;
                [self.objects addObjectsFromArray:entries];
            }
            
            if (entries.count < kPageLimit) {
                self.noMore = YES;
            }
            
            //
            [self.table reloadData];
        } else {
            self.noMore = YES;
            [UIHelper showTipsWithText:@"没有更多的数据" inView:self.view];
        }
    } else {
        [UIHelper showTipsWithText:response[@"msg"] inView:self.view];
    }
}

- (void)failureWithTask:(NSURLSessionDataTask *)task error:(NSError *)error {
    [UIHelper showErrorWithText:@"网络异常，请稍候重试" inView:self.view];
}

- (void)startSearching {
    [UIHelper showLoadingInView:self.view];
    [self fetchObjectsOnPage:0 refresh:YES cache:NO];
}

@end
