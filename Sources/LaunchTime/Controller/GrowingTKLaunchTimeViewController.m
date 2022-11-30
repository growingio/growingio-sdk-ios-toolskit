//
//  GrowingTKLaunchTimeViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/9.
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

#import "GrowingTKLaunchTimeViewController.h"
#import "GrowingTKLaunchTimeTableViewCell.h"
#import "GrowingTKNavigationTitleView.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKLaunchTimePlugin.h"
#import "GrowingTKDatabase+LaunchTime.h"
#import "GrowingTKLaunchTimePersistence.h"
#import "GrowingTKUtil.h"

@interface GrowingTKLaunchTimeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) GrowingTKNavigationTitleView *titleView;

@end

@implementation GrowingTKLaunchTimeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = self.title ?: GrowingTKLocalizedString(@"启动耗时");
    __weak typeof(self) weakSelf = self;
    GrowingTKNavigationTitleView *titleView = [[GrowingTKNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)
                                                                                            title:title
                                                                                       components:@[GrowingTKLocalizedString(@"删除全部")]
    singleTapAction:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    } longPressAction:^(NSUInteger index) {
        __strong typeof(weakSelf) self = weakSelf;
        [GrowingTKLaunchTimePlugin.plugin.db clearAllLaunchTime];
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
}

#pragma mark - Private Method

- (NSMutableArray *)refreshData {
    NSMutableArray *datasource = [NSMutableArray array];
    NSArray *records = GrowingTKLaunchTimePlugin.plugin.db.getAllLaunchTime.reverseObjectEnumerator.allObjects;
    
    NSMutableArray *appCycle = [NSMutableArray array];
    for (GrowingTKLaunchTimePersistence *record in records) {
        [appCycle addObject:record];
        
        if (record.type == GrowingTKLaunchTimeTypeAppLaunch) {
            if (datasource.count == 0) {
                [datasource addObject:@{GrowingTKLocalizedString(@"应用运行中") :appCycle.copy}];
            } else {
                [datasource addObject:@{GrowingTKLocalizedString(@"应用周期") :appCycle.copy}];
            }
            appCycle = [NSMutableArray array];
        }
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
    GrowingTKLaunchTimeTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"GrowingTKLaunchTimeTableViewCell" forIndexPath:indexPath];
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    GrowingTKLaunchTimePersistence *record = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    [cell showLaunchTime:record];
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
    
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    GrowingTKLaunchTimePersistence *record = ((NSArray *)dic[dic.allKeys.firstObject])[indexPath.row];
    if (record.attributes.length == 0) {
        // 非冷启动，没有 attributes 参数
        return;
    }
    NSData *jsonData = [record.attributes dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *attrs = [GrowingTKUtil convertDicFromData:jsonData];
    
    NSMutableString *message = [NSMutableString string];
    [message appendFormat:@"isActivePrewarm: %@\n", attrs[@"isActivePrewarm"]];
    [message appendFormat:@"exec_time: %@\n", attrs[@"exec"]];
    [message appendFormat:@"runtime_load_time: %@\n", attrs[@"load"]];
    [message appendFormat:@"cpp_init_time: %@\n", attrs[@"C++ Init"]];
    [message appendFormat:@"main_func_time: %@\n", attrs[@"main"]];
    [message appendFormat:@"didFinishLaunching_time: %@\n", attrs[@"didFinishLaunching"]];
    [message appendFormat:@"first_vc_didAppear_time: %@\n", attrs[@"firstVCDidAppear"]];
    [message appendFormat:@"total: %@\n", attrs[@"execTofirstVCDidAppear"]];

    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:GrowingTKLocalizedString(@"确定") style:UIAlertActionStyleCancel handler:nil]];
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
        [_tableView registerClass:[GrowingTKLaunchTimeTableViewCell class]
           forCellReuseIdentifier:@"GrowingTKLaunchTimeTableViewCell"];
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
