//
//  GrowingTKCheckSelfView.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/9.
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

#import "GrowingTKCheckSelfView.h"
#import "GrowingTKCheckInfoTableViewCell.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKSDKUtil.h"

static CGFloat const CheckButtonHeight = 130.0f;

@interface GrowingTKCheckSelfView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) NSArray *infoArray;

@end

@implementation GrowingTKCheckSelfView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:self.checkButton];
        [self addSubview:self.tableView];

        [NSLayoutConstraint activateConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.checkButton
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.checkButton
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:CheckButtonHeight],
            [NSLayoutConstraint constraintWithItem:self.checkButton
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:CheckButtonHeight],
            [NSLayoutConstraint constraintWithItem:self.checkButton
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.tableView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.checkButton
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:10.0],
            [NSLayoutConstraint constraintWithItem:self.tableView
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.tableView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.tableView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.tableView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                          constant:80.0],
        ]];
    }
    return self;
}

#pragma mark - Private Method

- (void)insertNext:(NSMutableArray *)fromArray {
    if (fromArray.count <= self.datasource.count
        && ((NSNumber *)((NSMutableDictionary *)self.datasource.lastObject)[@"check"]).boolValue) {
        self.checkButton.userInteractionEnabled = YES;
        return;
    }

    if (((NSNumber *)((NSMutableDictionary *)self.datasource.lastObject)[@"check"]).boolValue
        || self.datasource.count == 0) {
        [self.datasource addObject:fromArray[self.datasource.count]];
    } else {
        [((NSMutableDictionary *)self.datasource.lastObject) setObject:@(1) forKey:@"check"];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refresh];
        [self insertNext:fromArray];
    });
}

- (void)refresh {
    [self.tableView reloadData];
    
    [self layoutIfNeeded];
    NSArray *constraints = self.tableView.constraints;
    for (NSLayoutConstraint *constraint in constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = self.tableView.contentSize.height;

            [self.tableView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 [self layoutIfNeeded];
                             }];
            break;
        }
    }
}

#pragma mark - Action

- (void)checkAction {
    self.checkButton.userInteractionEnabled = NO;
    
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    NSMutableArray *sdkInfo = [NSMutableArray arrayWithArray:@[
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": @"正在获取SDK",
            @"title": @"SDK",
            @"value": sdk.nameDescription
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": @"正在获取SDK版本号",
            @"title": GrowingTKLocalizedString(@"SDK版本号"),
            @"value": sdk.version
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": @"正在获取SDK初始化状态",
            @"title": GrowingTKLocalizedString(@"SDK初始化"),
            @"value": sdk.initializationDescription,
            @"bad" : @(!(sdk.isInitialized))
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": @"正在获取URL Scheme配置",
            @"title": @"URL Scheme",
            @"value": sdk.urlScheme.length > 0 ? sdk.urlScheme : @"未配置",
            @"bad" : @(sdk.urlScheme.length == 0)
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": @"是否适配URL Scheme",
            @"title": @"适配URL Scheme",
            @"value": sdk.isAdaptToURLScheme ? @"是" : @"否",
            @"bad" : @(!sdk.isAdaptToURLScheme)
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": @"是否适配Deep Link",
            @"title": @"适配Deep Link",
            @"value": sdk.isAdaptToDeepLink ? @"是" : @"否",
            @"bad" : @(!sdk.isAdaptToDeepLink)
        }]
    ]];

    if (sdk.isInitialized) {
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                     @"check": @(0),
                     @"checkMessage": @"正在获取Project ID",
                     @"title": @"Project ID",
                     @"value": sdk.projectId
                 }]];

        if (sdk.dataSourceId.length > 0) {
            [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                         @"check": @(0),
                         @"checkMessage": @"正在获取DataSource ID",
                         @"title": @"DataSource ID",
                         @"value": sdk.dataSourceId
                     }]];
        }

        NSString *dataCollectionServerHost = sdk.dataCollectionServerHost;
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                     @"check": @(0),
                     @"checkMessage": @"正在获取ServerHost",
                     @"title": @"ServerHost",
                     @"value": dataCollectionServerHost
                 }]];

        NSString *debugEnabled = sdk.debugEnabled ? @"YES" : @"NO";
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                     @"check": @(0),
                     @"checkMessage": @"是否调试",
                     @"title": GrowingTKLocalizedString(@"调试模式"),
                     @"value": debugEnabled,
                     @"bad" : @(sdk.debugEnabled)
                 }]];

        NSString *dataCollectionEnabled = sdk.dataCollectionEnabled ? @"YES" : @"NO";
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                     @"check": @(0),
                     @"checkMessage": @"是否允许采集数据",
                     @"title": GrowingTKLocalizedString(@"是否采集数据"),
                     @"value": dataCollectionEnabled,
                     @"bad" : @(!(sdk.dataCollectionEnabled))
                 }]];
    }

    self.datasource = nil;
    [self refresh];
    [self insertNext:sdkInfo];
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GrowingTKCheckInfoTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"GrowingTKCheckInfoTableViewCell" forIndexPath:indexPath];
    NSDictionary *dic = self.datasource[indexPath.row];
    if (((NSNumber *)dic[@"check"]).boolValue) {
        [cell showInfo:dic[@"title"] message:dic[@"value"] bad:dic[@"bad"] ? ((NSNumber *)dic[@"bad"]).boolValue : NO];
    } else {
        [cell showCheck:dic[@"checkMessage"]];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.datasource.count > 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.frame.size.width, 20)];
    label.text = @"CHECK-SELF";
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    label.textColor = UIColor.growingtk_secondaryBackgroundColor;
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];

    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, 15)];
    label2.text = @"点击检查埋点 SDK 是否集成成功";
    label2.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    label2.textColor = UIColor.growingtk_black_1;
    label2.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label2];

    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.frame.size.width, 15)];
    label3.text = @"BY GROWINGIO";
    label3.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    label3.textColor = UIColor.growingtk_black_1;
    label3.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label3];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return self.datasource.count > 0 ? 0.01f : 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - Getter & Setter

- (UIButton *)checkButton {
    if (!_checkButton) {
        CGFloat sideLength = CheckButtonHeight;
        CGFloat margin = 20.0f;
        CGFloat containViewSideLength = sideLength - margin * 2;
        CGFloat imageMargin = 16.0f;

        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.frame = CGRectMake(0, 0, sideLength, sideLength);
        _checkButton.backgroundColor = UIColor.growingtk_primaryBackgroundColor;
        _checkButton.layer.cornerRadius = sideLength / 2;
        _checkButton.layer.masksToBounds = YES;

        UIView *view =
            [[UIView alloc] initWithFrame:CGRectMake(margin, margin, containViewSideLength, containViewSideLength)];
        view.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;
        view.layer.cornerRadius = containViewSideLength / 2;
        view.layer.masksToBounds = YES;
        view.userInteractionEnabled = NO;
        [_checkButton addSubview:view];

        UIImageView *imageView =
            [[UIImageView alloc] initWithFrame:CGRectMake(imageMargin,
                                                          imageMargin,
                                                          containViewSideLength - imageMargin * 2,
                                                          containViewSideLength - imageMargin * 2)];
        imageView.image = [UIImage growingtk_imageNamed:@"growingtk_sdkCheck"];
        [view addSubview:imageView];

        [_checkButton addTarget:self action:@selector(checkAction) forControlEvents:UIControlEventTouchUpInside];
        _checkButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _checkButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   CheckButtonHeight,
                                                                   self.growingtk_width,
                                                                   self.growingtk_height - CheckButtonHeight)
                                                  style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 13.0, *)) {
            _tableView.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            _tableView.backgroundColor = [UIColor whiteColor];
        }
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.allowsSelection = NO;
        _tableView.estimatedSectionFooterHeight = 0.01f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[GrowingTKCheckInfoTableViewCell class]
            forCellReuseIdentifier:@"GrowingTKCheckInfoTableViewCell"];
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
