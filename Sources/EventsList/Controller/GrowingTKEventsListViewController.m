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
#import "GrowingTKEventsListHeaderView.h"
#import "GrowingTKEventsListTableViewCell.h"
#import "GrowingTKEventDetailViewController.h"
#import "GrowingTKNavigationTitleView.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKEventsListPlugin.h"
#import "GrowingTKDatabase+Event.h"
#import "GrowingTKEventPersistence.h"
#import "GrowingTKDateUtil.h"

@interface GrowingTKEventsListViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) GrowingTKNavigationTitleView *titleView;
@property (nonatomic, strong) GrowingTKEventsListHeaderView *tableHeaderView;

@end

@implementation GrowingTKEventsListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = self.title ?: GrowingTKLocalizedString(@"事件库");
    __weak typeof(self) weakSelf = self;
    GrowingTKNavigationTitleView *titleView = [[GrowingTKNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)
                                                                                            title:title
                                                                                       components:@[GrowingTKLocalizedString(@"删除全部")]
    singleTapAction:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    } longPressAction:^(NSUInteger index) {
        __strong typeof(weakSelf) self = weakSelf;
        [GrowingTKEventsListPlugin.plugin.db clearAllEvents];
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

    if (@available(iOS 10.0, *)) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle =
            [[NSAttributedString alloc] initWithString:GrowingTKLocalizedString(@"下拉刷新")];
        [refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refreshControl;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.titleView reset];
    [self.tableHeaderView reset];
}

#pragma mark - Private Method

- (NSMutableArray *)refreshData {
    NSMutableArray *datasource = [NSMutableArray array];
    NSArray *events;
    if (self.eventTypes) {
        events = [GrowingTKEventsListPlugin.plugin.db getEventsByEventTypes:self.eventTypes].reverseObjectEnumerator.allObjects;
    }else {
        events = GrowingTKEventsListPlugin.plugin.db.getAllEvents.reverseObjectEnumerator.allObjects;
    }
    NSMutableArray *dayKeys = [NSMutableArray array];
    NSMutableArray *dayEvents = [NSMutableArray array];
    NSString *today = GrowingTKLocalizedString(@"今日");
    NSString *yesterday = GrowingTKLocalizedString(@"昨日");

    void (^block)(NSString *, GrowingTKEventPersistence *) = ^(NSString *key, GrowingTKEventPersistence *event) {
        if ([dayKeys containsObject:key]) {
            NSMutableArray *array = dayEvents[[dayKeys indexOfObject:key]];
            [array addObject:event];
        } else {
            [dayKeys addObject:key];
            [dayEvents addObject:@[event].mutableCopy];
        }
    };

    for (GrowingTKEventPersistence *event in events) {
        if ([GrowingTKDateUtil.sharedInstance isToday:event.timestamp]) {
            block(today, event);
        } else if ([GrowingTKDateUtil.sharedInstance isYesterday:event.timestamp]) {
            block(yesterday, event);
        } else {
            block(event.day, event);
        }
    }

    for (int i = 0; i < dayKeys.count; i++) {
        [datasource addObject:@{dayKeys[i]: dayEvents[i]}];
    }
    
    return datasource;
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
    });
}
#endif

- (void)searchAction:(NSString *)type isChoose:(BOOL)isChoose {
    GrowingTKEventsListViewController *controller = [[GrowingTKEventsListViewController alloc] init];
    if (isChoose) {
        controller.eventTypes = @[type];
    } else {
        NSMutableArray *eventTypes = [NSMutableArray array];
        for (NSString *eventType in self.tableHeaderView.types) {
            if ([eventType.lowercaseString containsString:type.lowercaseString]) {
                [eventTypes addObject:eventType];
            }
        }
        controller.eventTypes = eventTypes.copy;
    }
    controller.title = [NSString stringWithFormat:@"%@ %@", GrowingTKLocalizedString(@"搜索来自"), type];
    [self.navigationController pushViewController:controller animated:YES];
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
    GrowingTKEventsListTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"GrowingTKEventsListTableViewCell" forIndexPath:indexPath];
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    GrowingTKEventPersistence *event = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    [cell showEvent:event];
    
    if (self.gesids.count > 0) {
        if (self.gesids.count == 1) {
            NSNumber *gesid = (NSNumber *)self.gesids.firstObject;
            cell.backgroundColor = [event.globalSequenceId isEqualToNumber:gesid] ? [UIColor growingtk_colorWithHex:@"#FF9167" alpha:0.2f]
                                                                                  : UIColor.growingtk_white_1;
        } else {
            cell.backgroundColor = UIColor.growingtk_white_1;
            for (NSNumber *gesid in self.gesids) {
                if ([event.globalSequenceId isEqualToNumber:gesid]) {
                    cell.backgroundColor = [UIColor growingtk_colorWithHex:@"#FF9167" alpha:0.2f];
                    break;
                }
            }
        }
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GrowingTKScreenWidth, 40)];
    view.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, GrowingTKScreenWidth - 32, 24)];
    label.text = ((NSDictionary *)self.datasource[section]).allKeys.firstObject;
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
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    GrowingTKEventPersistence *event = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    controller.event = event;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Getter & Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = UIColor.growingtk_white_1;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionFooterHeight = 0.01f;
        [_tableView registerClass:[GrowingTKEventsListTableViewCell class]
            forCellReuseIdentifier:@"GrowingTKEventsListTableViewCell"];
        
        if (!self.eventTypes) {
            CGRect frame = CGRectMake(0, 0, GrowingTKScreenWidth, GrowingTKSizeFrom750(120));
            UIView *tableHeaderView = [[UIView alloc] initWithFrame:frame];
            __weak typeof(self) weakSelf = self;
            _tableHeaderView = [[GrowingTKEventsListHeaderView alloc] initWithFrame:CGRectZero
                                                                     searchCallback:^(NSString * _Nonnull type, BOOL isChoose) {
                [weakSelf searchAction:type isChoose:isChoose];
            }];
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
