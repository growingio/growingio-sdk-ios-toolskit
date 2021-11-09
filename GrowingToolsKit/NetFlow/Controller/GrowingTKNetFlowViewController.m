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
#import "GrowingTKNetFlowPlugin.h"
#import "GrowingTKDatabase+Request.h"
#import "GrowingTKRequestPersistence.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKNetFlowViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GrowingTKNetFlowHeaderView *tableHeaderView;
@property (nonatomic, strong) NSMutableArray *datasource;

@end

@implementation GrowingTKNetFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = GrowingTKLocalizedString(@"网络请求");

    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];

    self.datasource = [self refreshData];
    [self.tableView reloadData];
    [self refreshHeaderView];

    if (@available(iOS 10.0, *)) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle =
            [[NSAttributedString alloc] initWithString:GrowingTKLocalizedString(@"下拉刷新")];
        [refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refreshControl;
    }
}

#pragma mark - Private Method

- (NSMutableArray *)refreshData {
    NSMutableArray *datasource = [NSMutableArray array];
    NSArray *requests = GrowingTKNetFlowPlugin.plugin.db.getAllRequests.reverseObjectEnumerator.allObjects;
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

    for (GrowingTKRequestPersistence *request in requests) {
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

- (void)refreshHeaderView {
    if (self.datasource.count == 0 || !self.tableHeaderView) {
        return;
    }
    NSString *runtime = GrowingTKLocalizedString(@"运行期间");
    NSDictionary *dic = (NSDictionary *)self.datasource[0];
    if ([dic.allKeys.firstObject isEqualToString:runtime]) {
        [self.tableHeaderView
            configWithRuntimeDatasource:(NSArray<GrowingTKRequestPersistence *> *)dic[dic.allKeys.firstObject]];
    }
}

#pragma mark - Action

#if defined(__IPHONE_10_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0)
- (void)refreshAction {
    NSMutableArray *datasource = [self refreshData];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            [self.tableView.refreshControl endRefreshing];
        }
        self.datasource = datasource;
        [self.tableView reloadData];
        [self refreshHeaderView];
    });
}
#endif

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
    if (@available(iOS 13.0, *)) {
        view.backgroundColor = [UIColor secondarySystemBackgroundColor];
    } else {
        view.backgroundColor = [UIColor growingtk_colorWithHex:@"f2f2f7ff"];
    }
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
    //    GrowingTKEventDetailViewController *controller = [[GrowingTKEventDetailViewController alloc] init];
    //    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    //    GrowingTKRequestPersistence *request = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    //    controller.request = request;
    //    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Getter & Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 13.0, *)) {
            _tableView.backgroundColor = [UIColor secondarySystemBackgroundColor];
        } else {
            _tableView.backgroundColor = [UIColor growingtk_colorWithHex:@"f2f2f7ff"];
        }
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionFooterHeight = 0.01f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[GrowingTKNetFlowTableViewCell class]
            forCellReuseIdentifier:@"GrowingTKNetFlowTableViewCell"];

        // UITableView.tableHeaderView就算到了didMoveToSuperview，约束中的width还是0
        // 会导致手写约束报warnings，这里加一层view嵌套来避免
        CGRect frame = CGRectMake(0, 0, GrowingTKScreenWidth, GrowingTKSizeFrom750(280));
        _tableHeaderView = [[GrowingTKNetFlowHeaderView alloc] initWithFrame:frame];
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:frame];
        [tableHeaderView addSubview:_tableHeaderView];
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

@end
