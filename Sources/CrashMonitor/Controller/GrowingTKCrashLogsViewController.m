//
//  GrowingTKCrashLogsViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/7.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingTKCrashLogsViewController.h"
#import "GrowingTKCrashLogsTableViewCell.h"
#import "GrowingTKNavigationTitleView.h"
#import "GrowingTKCrashLogsDetailViewController.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKCrashMonitorPlugin.h"
#import "GrowingTKDatabase+CrashLogs.h"
#import "GrowingTKCrashLogsPersistence.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKCrashLogsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) GrowingTKNavigationTitleView *titleView;

@end

@implementation GrowingTKCrashLogsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = self.title ?: GrowingTKLocalizedString(@"错误报告");
    __weak typeof(self) weakSelf = self;
    GrowingTKNavigationTitleView *titleView = [[GrowingTKNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)
                                                                                            title:title
                                                                                       components:@[GrowingTKLocalizedString(@"删除全部")]
    singleTapAction:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    } longPressAction:^(NSUInteger index) {
        __strong typeof(weakSelf) self = weakSelf;
        [GrowingTKCrashMonitorPlugin.plugin.db clearAllCrashLogs];
        self.datasource = [self refreshData];
        [self.tableView reloadData];
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

    self.datasource = [self refreshData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.titleView reset];
}

#pragma mark - Private Method

- (NSMutableArray *)refreshData {
    NSMutableArray *datasource = [NSMutableArray array];
    NSArray *crashLogs = GrowingTKCrashMonitorPlugin.plugin.db.getAllCrashLogs.reverseObjectEnumerator.allObjects;
    NSMutableArray *dayKeys = [NSMutableArray array];
    NSMutableArray *dayEvents = [NSMutableArray array];
    NSString *today = GrowingTKLocalizedString(@"今日");
    NSString *yesterday = GrowingTKLocalizedString(@"昨日");

    void (^block)(NSString *, GrowingTKCrashLogsPersistence *) = ^(NSString *key, GrowingTKCrashLogsPersistence *crashLog) {
        if ([dayKeys containsObject:key]) {
            NSMutableArray *array = dayEvents[[dayKeys indexOfObject:key]];
            [array addObject:crashLog];
        } else {
            [dayKeys addObject:key];
            [dayEvents addObject:@[crashLog].mutableCopy];
        }
    };

    for (GrowingTKCrashLogsPersistence *crashLog in crashLogs) {
        if ([GrowingTKDateUtil.sharedInstance isToday:crashLog.timestamp]) {
            block(today, crashLog);
        } else if ([GrowingTKDateUtil.sharedInstance isYesterday:crashLog.timestamp]) {
            block(yesterday, crashLog);
        } else {
            block(crashLog.day, crashLog);
        }
    }

    for (int i = 0; i < dayKeys.count; i++) {
        [datasource addObject:@{dayKeys[i]: dayEvents[i]}];
    }

    return datasource;
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
    GrowingTKCrashLogsTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"GrowingTKCrashLogsTableViewCell" forIndexPath:indexPath];
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    GrowingTKCrashLogsPersistence *crashLog = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    [cell showCrashLog:crashLog];
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
    GrowingTKCrashLogsDetailViewController *controller = [[GrowingTKCrashLogsDetailViewController alloc] init];
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    GrowingTKCrashLogsPersistence *crashLog = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    controller.crashLog = crashLog;
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
        [_tableView registerClass:[GrowingTKCrashLogsTableViewCell class]
           forCellReuseIdentifier:@"GrowingTKCrashLogsTableViewCell"];
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
