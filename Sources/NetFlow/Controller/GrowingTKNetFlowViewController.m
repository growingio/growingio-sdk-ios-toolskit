//
//  GrowingTKNetFlowViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/8.
//  Copyright (C) 2021 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GrowingTKNetFlowViewController.h"
#import "GrowingTKNetFlowHeaderView.h"
#import "GrowingTKNetFlowTableViewCell.h"
#import "GrowingTKNetFlowDetailViewController.h"
#import "GrowingTKNavigationTitleView.h"
#import "GrowingTKNetFlowPlugin.h"
#import "GrowingTKDatabase+Request.h"
#import "GrowingTKRequestPersistence.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKNetFlowViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GrowingTKNavigationTitleView *titleView;
@property (nonatomic, strong) GrowingTKNetFlowHeaderView *tableHeaderView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) NSMutableArray *allRequests;
@property (nonatomic, assign) BOOL noMoreData;

@end

@implementation GrowingTKNetFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = self.title ?: GrowingTKLocalizedString(@"网络记录");
    __weak typeof(self) weakSelf = self;
    GrowingTKNavigationTitleView *titleView = [[GrowingTKNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)
                                                                                            title:title
                                                                                       components:@[GrowingTKLocalizedString(@"删除全部")]
    singleTapAction:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    } longPressAction:^(NSUInteger index) {
        __strong typeof(weakSelf) self = weakSelf;
        [GrowingTKNetFlowPlugin.plugin clearAllRequests];
        
        self.allRequests = [NSMutableArray array];
        self.noMoreData = NO;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self fetchMoreData:^(NSMutableArray *datasource, BOOL noMoreData) {
                [self reloadData:datasource noMoreData:noMoreData delay:0];
            }];
        });
    }];
    self.navigationItem.titleView = titleView;
    self.titleView = titleView;

    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];
    
    if (@available(iOS 10.0, *)) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle =
            [[NSAttributedString alloc] initWithString:GrowingTKLocalizedString(@"下拉刷新")];
        [refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refreshControl;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self fetchMoreData:^(NSMutableArray *datasource, BOOL noMoreData) {
            [self reloadData:datasource noMoreData:noMoreData delay:0];
        }];
    });
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.titleView reset];
}

#pragma mark - Private Method

- (void)reloadData:(NSMutableArray *)datasource noMoreData:(BOOL)noMoreData delay:(NSTimeInterval)delay {
    if (noMoreData) {
        self.noMoreData = YES;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            if (self.tableView.refreshControl.isRefreshing) {
                [self.tableView.refreshControl endRefreshing];
            }
        }
        self.datasource = datasource;
        [self.tableView reloadData];
    });
}

- (void)fetchMoreData:(void(^)(NSMutableArray *datasource, BOOL noMoreData))callback {
    double oldestRequestTime = 0;
    if (self.allRequests.count > 0) {
        oldestRequestTime = ((GrowingTKRequestPersistence *)self.allRequests.lastObject).startTimestamp;
    } else {
        oldestRequestTime = NSDate.date.timeIntervalSince1970 * 1000LL;
    }
    NSUInteger pageSize = 40;
    NSArray *requests = [GrowingTKNetFlowPlugin.plugin getRequestsWithRequestTimeEarlyThan:oldestRequestTime
                                                                                  pageSize:pageSize];
    if (callback) {
        callback([self recalculateDatasourceByAppendRequests:requests], requests.count < pageSize);
    }
}

- (NSMutableArray *)recalculateDatasourceByAppendRequests:(NSArray *)requests {
    [self.allRequests addObjectsFromArray:requests];
    
    NSMutableArray *datasource = [NSMutableArray array];
    NSMutableArray *dayKeys = [NSMutableArray array];
    NSMutableArray *dayRequests = [NSMutableArray array];
    NSString *runtime = GrowingTKLocalizedString(@"运行期间");
    NSString *today = GrowingTKLocalizedString(@"今日");
    NSString *yesterday = GrowingTKLocalizedString(@"昨日");

    void (^block)(NSString *, GrowingTKRequestPersistence *) = ^(NSString *key, GrowingTKRequestPersistence *request) {
        if ([dayKeys containsObject:key]) {
            NSMutableArray *array = dayRequests[[dayKeys indexOfObject:key]];
            [array addObject:request];
        } else {
            [dayKeys addObject:key];
            [dayRequests addObject:@[request].mutableCopy];
        }
    };

    for (GrowingTKRequestPersistence *request in self.allRequests) {
        if (request.startTimestamp > GrowingTKNetFlowPlugin.plugin.pluginStartTimestamp) {
            block(runtime, request);
        } else if ([GrowingTKDateUtil.sharedInstance isToday:request.startTimestamp]) {
            block(today, request);
        } else if ([GrowingTKDateUtil.sharedInstance isYesterday:request.startTimestamp]) {
            block(yesterday, request);
        } else {
            block(request.day, request);
        }
    }

    for (int i = 0; i < dayKeys.count; i++) {
        [datasource addObject:@{dayKeys[i]: dayRequests[i]}];
    }
    
    return datasource;
}

#pragma mark - Action

#if defined(__IPHONE_10_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0)
- (void)refreshAction {
    self.allRequests = [NSMutableArray array];
    self.noMoreData = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self fetchMoreData:^(NSMutableArray *datasource, BOOL noMoreData) {
            [self reloadData:datasource noMoreData:noMoreData delay:0.5];
        }];
    });
}
#endif

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        return;
    }
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (self.noMoreData) {
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self fetchMoreData:^(NSMutableArray *datasource, BOOL noMoreData) {
                [self reloadData:datasource noMoreData:noMoreData delay:0];
            }];
        });
    }
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = (NSDictionary *)self.datasource[section];
    NSArray *array = dic[dic.allKeys.firstObject];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GrowingTKNetFlowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GrowingTKNetFlowTableViewCell"
                                                                          forIndexPath:indexPath];
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    GrowingTKRequestPersistence *request = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    [cell showRequest:request];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GrowingTKScreenWidth, 40)];
    view.backgroundColor = UIColor.growingtk_white_2;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, GrowingTKScreenWidth - 32, 24)];
    label.text = ((NSDictionary *)self.datasource[section]).allKeys.firstObject;
    label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
    label.textColor = UIColor.growingtk_black_2;
    [view addSubview:label];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    GrowingTKNetFlowDetailViewController *controller = [[GrowingTKNetFlowDetailViewController alloc] init];
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    GrowingTKRequestPersistence *request = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    controller.request = request;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Getter & Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = UIColor.growingtk_white_2;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionFooterHeight = 0.01f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[GrowingTKNetFlowTableViewCell class]
            forCellReuseIdentifier:@"GrowingTKNetFlowTableViewCell"];

        CGRect frame = CGRectMake(0, 0, GrowingTKScreenWidth, GrowingTKSizeFrom750(280));
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:frame];
        _tableHeaderView = [[GrowingTKNetFlowHeaderView alloc] initWithFrame:CGRectZero];
        _tableHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
        [tableHeaderView addSubview:_tableHeaderView];
        [NSLayoutConstraint activateConstraints:@[
            [_tableHeaderView.topAnchor constraintEqualToAnchor:tableHeaderView.topAnchor],
            [_tableHeaderView.bottomAnchor constraintEqualToAnchor:tableHeaderView.bottomAnchor],
            [_tableHeaderView.leadingAnchor constraintEqualToAnchor:tableHeaderView.leadingAnchor],
            [_tableHeaderView.trailingAnchor constraintEqualToAnchor:tableHeaderView.trailingAnchor]
        ]];
        _tableView.tableHeaderView = tableHeaderView;
    }
    return _tableView;
}

- (NSMutableArray *)datasource {
    if (!_datasource) {
        _datasource = [NSMutableArray array];
    }
    return _datasource;
}

- (NSMutableArray *)allRequests {
    if (!_allRequests) {
        _allRequests = [NSMutableArray array];
    }
    return _allRequests;
}

@end
