//
//  GrowingTKEventsListViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/7.
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

#import "GrowingTKEventsListViewController.h"
#import "GrowingTKEventsListTableViewCell.h"
#import "GrowingTKEventDetailViewController.h"
#import "GrowingTKDefine.h"
#import "UIViewController+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKEventsListPlugin.h"
#import "GrowingTKDatabase.h"
#import "GrowingTKEventPersistence.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKEventsListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *datasource;

@end

@implementation GrowingTKEventsListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = GrowingTKLocalizedString(@"埋点数据");

    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];

    [self refreshData];
    [self.tableView reloadData];

    if (@available(iOS 10.0, *)) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:GrowingTKLocalizedString(@"下拉刷新")];
        [refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refreshControl;
    }
}

#pragma mark - Private Method

- (void)refreshData {
    self.datasource = [NSMutableDictionary dictionary];
    
    NSArray *events = GrowingTKEventsListPlugin.plugin.db.getAllEvents.reverseObjectEnumerator.allObjects;
    NSString *today = GrowingTKLocalizedString(@"今日");
    NSString *yesterday = GrowingTKLocalizedString(@"昨日");
    
    __weak typeof(self) weakSelf = self;
    void (^block)(NSString *, GrowingTKEventPersistence *) = ^(NSString *key, GrowingTKEventPersistence *event) {
        __strong typeof(weakSelf) self = weakSelf;
        if (self.datasource[key]) {
            NSMutableArray *array = self.datasource[key];
            [array addObject:event];
        }else {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:event];
            self.datasource[key] = array;
        }
    };
    
    for (GrowingTKEventPersistence *event in events) {
        if ([GrowingTKDateUtil.sharedInstance isToday:event.timestamp]) {
            block(today, event);
        }else if ([GrowingTKDateUtil.sharedInstance isYesterday:event.timestamp]) {
            block(yesterday, event);
        }else {
            block(event.day, event);
        }
    }
}

#pragma mark - Action

#if defined(__IPHONE_10_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0)
- (void)refreshAction {
    [self refreshData];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            [self.tableView.refreshControl endRefreshing];
        }
        [self.tableView reloadData];
    });
}
#endif

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSMutableArray *)self.datasource[[self.datasource.allKeys objectAtIndex:section]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GrowingTKEventsListTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"GrowingTKEventsListTableViewCell" forIndexPath:indexPath];
    NSString *dayKey = [self.datasource.allKeys objectAtIndex:indexPath.section];
    GrowingTKEventPersistence *event = ((NSMutableArray *)self.datasource[dayKey])[indexPath.row];
    [cell showEvent:event];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GrowingTKScreenWidth, 40)];
    view.backgroundColor = UIColor.growingtk_primaryBackgroundColor;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, GrowingTKScreenWidth - 32, 24)];
    label.text = [self.datasource.allKeys objectAtIndex:section];
    label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
    label.textColor = UIColor.whiteColor;
    [view addSubview:label];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GrowingTKEventDetailViewController *controller = [[GrowingTKEventDetailViewController alloc] init];
    NSString *dayKey = [self.datasource.allKeys objectAtIndex:indexPath.section];
    GrowingTKEventPersistence *event = ((NSMutableArray *)self.datasource[dayKey])[indexPath.row];
    controller.rawJsonString = event.rawJsonString;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Getter & Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 13.0, *)) {
            _tableView.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            _tableView.backgroundColor = [UIColor whiteColor];
        }
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[GrowingTKEventsListTableViewCell class]
            forCellReuseIdentifier:@"GrowingTKEventsListTableViewCell"];
    }
    return _tableView;
}

- (NSMutableDictionary *)datasource {
    if (!_datasource) {
        _datasource = [NSMutableDictionary dictionary];
    }
    return _datasource;
}

@end
