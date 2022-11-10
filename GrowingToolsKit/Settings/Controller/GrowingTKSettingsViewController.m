//
//  GrowingTKSettingsViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/8/16.
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

#import "GrowingTKSettingsViewController.h"
#import "GrowingTKSettingsTableViewCell.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *datasource;

@end

@implementation GrowingTKSettingsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = GrowingTKLocalizedString(@"通用设置");
    
    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = (NSDictionary *)self.datasource[section];
    NSArray *elements = (NSArray *)dic[dic.allKeys.firstObject];
    return elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GrowingTKSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GrowingTKSettingsTableViewCell"
                                                                           forIndexPath:indexPath];
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    NSArray *elements = dic[dic.allKeys.firstObject];
    NSDictionary *element = (NSDictionary *)elements[indexPath.row];
    [cell configWithTitle:element[@"title"] detail:element[@"detail"] image:element[@"image"]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GrowingTKScreenWidth, GrowingTKSizeFrom750(100))];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(GrowingTKSizeFrom750(134),
                                                               GrowingTKSizeFrom750(26),
                                                               GrowingTKScreenWidth - GrowingTKSizeFrom750(64),
                                                               GrowingTKSizeFrom750(48))];
    label.text = ((NSDictionary *)self.datasource[section]).allKeys.firstObject;
    label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(30) weight:UIFontWeightMedium];
    label.textColor = UIColor.systemGreenColor;
    [view addSubview:label];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return GrowingTKSizeFrom750(100);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = (NSDictionary *)self.datasource[indexPath.section];
    NSArray *elements = dic[dic.allKeys.firstObject];
    NSDictionary *element = (NSDictionary *)elements[indexPath.row];
    NSString *message = element[@"detail"];
    NSString *notification = element[@"notification"];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:GrowingTKLocalizedString(@"提示")
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:GrowingTKLocalizedString(@"确定")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:GrowingTKLocalizedString(@"取消")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [controller addAction:cancelAction];
    [controller addAction:confirmAction];
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
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[GrowingTKSettingsTableViewCell class]
            forCellReuseIdentifier:@"GrowingTKSettingsTableViewCell"];
    }
    return _tableView;
}

- (NSArray *)datasource {
    if (!_datasource) {
        _datasource = @[
        @{
            GrowingTKLocalizedString(@"数据") : @[
                @{@"title" : GrowingTKLocalizedString(@"清空事件"),
                  @"detail" : GrowingTKLocalizedString(@"清空事件库中的所有事件数据"),
                  @"image" : [UIImage growingtk_imageNamed:@"growingtk_eventsList_black"],
                  @"notification" : GrowingTKClearAllEventNotification
                },
                @{@"title" : GrowingTKLocalizedString(@"清空网络"),
                  @"detail" : GrowingTKLocalizedString(@"清空网络记录下的所有请求数据"),
                  @"image" : [UIImage growingtk_imageNamed:@"growingtk_netFlow_black"],
                  @"notification" : GrowingTKClearAllRequestsNotification
                },
                @{@"title" : GrowingTKLocalizedString(@"清空性能数据"),
                  @"detail" : GrowingTKLocalizedString(@"清空性能监控下产生的所有历史数据"),
                  @"image" : [UIImage growingtk_imageNamed:@"growingtk_performance_black"],
                  @"notification" : GrowingTKClearAllPerformanceDataNotification
                }
            ]
        }];
    }
    return _datasource;
}

@end
