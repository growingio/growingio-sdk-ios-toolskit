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
#import "GrowingTKUtil.h"
#import "GrowingTKSDKUtil.h"

static CGFloat const CheckButtonHeight = 130.0f;

@interface GrowingTKCheckSelfView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) NSArray *infoArray;

@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *constraintsForPortrait;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *constraintsForLandscape;
@property (nonatomic, strong) NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *tableViewLimitedHeightConstraint;

@end

@implementation GrowingTKCheckSelfView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:self.checkButton];
        [self addSubview:self.tableView];
        
        self.tableViewHeightConstraint = [self.tableView.heightAnchor constraintEqualToConstant:95.0f];
        self.tableViewLimitedHeightConstraint = [self.tableView.heightAnchor constraintEqualToConstant:200.0f];
        
        self.constraintsForPortrait = @[
            [self.checkButton.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.checkButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.tableView.topAnchor constraintEqualToAnchor:self.checkButton.bottomAnchor constant:10.0f],
            [self.tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            self.tableViewHeightConstraint
        ];
        
        self.constraintsForLandscape = @[
            [self.checkButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [NSLayoutConstraint constraintWithItem:self.checkButton
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self attribute:NSLayoutAttributeCenterX
                                        multiplier:0.3f
                                          constant:0.0f],
            [self.tableView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.tableView.leadingAnchor constraintEqualToAnchor:self.checkButton.trailingAnchor constant:10.0f],
            self.tableViewLimitedHeightConstraint
        ];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.checkButton.widthAnchor constraintEqualToConstant:CheckButtonHeight],
            [self.checkButton.heightAnchor constraintEqualToConstant:CheckButtonHeight],
            [self.tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        [self resetConstraintsWithOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }
    return self;
}

#pragma mark - Public Method

- (void)resetConstraintsWithOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.tableView.scrollEnabled = YES;
        self.tableView.showsVerticalScrollIndicator = YES;
        [NSLayoutConstraint deactivateConstraints:self.constraintsForPortrait];
        [NSLayoutConstraint activateConstraints:self.constraintsForLandscape];

    } else {
        self.tableView.scrollEnabled = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
        [NSLayoutConstraint deactivateConstraints:self.constraintsForLandscape];
        [NSLayoutConstraint activateConstraints:self.constraintsForPortrait];
    }
}

#pragma mark - Private Method

- (void)insertNext:(NSMutableArray *)fromArray delay:(BOOL)delay {
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

    if (delay) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refresh];
            [self insertNext:fromArray delay:YES];
        });
    }else {
        [self refresh];
        [self insertNext:fromArray delay:YES];
    }
}

- (void)refresh {
    [self.tableView reloadData];
    [self layoutIfNeeded];
    self.tableViewHeightConstraint.constant = self.tableView.contentSize.height;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        if (self.datasource.count > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        }
    } else {
        [self.tableView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [self layoutIfNeeded];
                         }];
    }
}

#pragma mark - Action

- (void)checkAction {
    self.checkButton.tag = 1;
    self.checkButton.userInteractionEnabled = NO;

    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    NSMutableArray *sdkInfo = [NSMutableArray arrayWithArray:@[
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": GrowingTKLocalizedString(@"正在获取SDK"),
            @"title": GrowingTKLocalizedString(@"SDK"),
            @"value": sdk.isIntegrated ? sdk.nameDescription : GrowingTKLocalizedString(@"未集成"),
            @"bad": @(!sdk.isIntegrated)
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": GrowingTKLocalizedString(@"正在获取SDK版本号"),
            @"title": GrowingTKLocalizedString(@"SDK版本号"),
            @"value": sdk.version
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": GrowingTKLocalizedString(@"正在获取SDK初始化状态"),
            @"title": GrowingTKLocalizedString(@"SDK初始化"),
            @"value": sdk.initializationDescription,
            @"bad": @(!(sdk.isInitialized))
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": GrowingTKLocalizedString(@"正在获取URL Scheme配置"),
            @"title": GrowingTKLocalizedString(@"URL Scheme"),
            @"value": sdk.urlScheme.length > 0 ? sdk.urlScheme : GrowingTKLocalizedString(@"未配置"),
            @"bad": @(sdk.urlScheme.length == 0)
        }],
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"check": @(0),
            @"checkMessage": GrowingTKLocalizedString(@"是否适配URL Scheme"),
            @"title": GrowingTKLocalizedString(@"适配URL Scheme"),
            @"value": GrowingTKLocalizedString(sdk.isAdaptToURLScheme ? @"YES" : @"NO"),
            @"bad": @(!sdk.isAdaptToURLScheme)
        }]
    ]];
    
    if (sdk.isSDK2ndGeneration) {
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                    @"check": @(0),
                    @"checkMessage": GrowingTKLocalizedString(@"是否适配Deep Link"),
                    @"title": GrowingTKLocalizedString(@"适配Deep Link"),
                    @"value": GrowingTKLocalizedString(sdk.isAdaptToDeepLink ? @"YES" : @"NO"),
                    @"bad": @(!sdk.isAdaptToDeepLink)
        }]];
    }

    if (sdk.isInitialized) {
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                     @"check": @(0),
                     @"checkMessage": GrowingTKLocalizedString(@"正在获取项目 ID"),
                     @"title": GrowingTKLocalizedString(@"Project ID"),
                     @"value": sdk.projectId
                 }]];
        
        if (sdk.isSDK2ndGeneration) {
            [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                         @"check": @(0),
                         @"checkMessage": GrowingTKLocalizedString(@"正在获取采样率"),
                         @"title": GrowingTKLocalizedString(@"采样率"),
                         @"value": [NSString stringWithFormat:@"%.3f%%", sdk.sampling * 100],
                         @"bad": @(sdk.sampling == 0)
                     }]];
        }

        if (sdk.dataSourceId.length > 0) {
            [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                         @"check": @(0),
                         @"checkMessage": GrowingTKLocalizedString(@"正在获取DataSource ID"),
                         @"title": GrowingTKLocalizedString(@"DataSource ID"),
                         @"value": sdk.dataSourceId
                     }]];
        }

        NSString *dataCollectionServerHost = sdk.dataCollectionServerHost;
        BOOL hostBad = (![GrowingTKUtil isIPAddress:dataCollectionServerHost]
                        && ![GrowingTKUtil isDomain:dataCollectionServerHost]);
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                     @"check": @(0),
                     @"checkMessage": GrowingTKLocalizedString(@"正在获取ServerHost"),
                     @"title": GrowingTKLocalizedString(@"ServerHost"),
                     @"value": dataCollectionServerHost,
                     @"bad": @(hostBad)
                 }]];

        NSString *debugEnabled = GrowingTKLocalizedString(sdk.debugEnabled ? @"YES" : @"NO");
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                     @"check": @(0),
                     @"checkMessage": GrowingTKLocalizedString(@"是否调试"),
                     @"title": GrowingTKLocalizedString(@"调试模式"),
                     @"value": debugEnabled,
                     @"bad": @(sdk.debugEnabled)
                 }]];

        NSString *dataCollectionEnabled = GrowingTKLocalizedString(sdk.dataCollectionEnabled ? @"YES" : @"NO");
        [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                     @"check": @(0),
                     @"checkMessage": GrowingTKLocalizedString(@"是否允许采集数据"),
                     @"title": GrowingTKLocalizedString(@"是否采集数据"),
                     @"value": dataCollectionEnabled,
                     @"bad": @(!(sdk.dataCollectionEnabled))
                 }]];
        
        if (sdk.isSDK3rdGeneration) {
            [sdkInfo addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                         @"check": @(0),
                         @"checkMessage": GrowingTKLocalizedString(@"检测集成模块"),
                         @"title": GrowingTKLocalizedString(@"集成模块"),
                         @"value": [sdk.SDK3Modules componentsJoinedByString:@", "]
                     }]];
        }
    }

    self.datasource = nil;
    [self insertNext:sdkInfo delay:NO];
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
    if (self.datasource.count > 0 || self.checkButton.tag > 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 95)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = GrowingTKLocalizedString(@"CHECK-SELF");
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    label.textColor = UIColor.growingtk_secondaryBackgroundColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:label];

    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
    label2.text = GrowingTKLocalizedString(@"点击检查埋点 SDK 是否集成成功");
    label2.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    label2.textColor = UIColor.growingtk_black_1;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.numberOfLines = 0;
    label2.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:label2];

    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectZero];
    label3.text = GrowingTKLocalizedString(@"By GrowingIO");
    label3.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    label3.textColor = UIColor.growingtk_black_1;
    label3.textAlignment = NSTextAlignmentCenter;
    label3.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:label3];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:view.topAnchor constant:15.0f],
        [label.heightAnchor constraintEqualToConstant:20.0f],
        [label.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [label2.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:5.0f],
        [label2.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:20.0f],
        [label2.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-20.0f],
        [label3.topAnchor constraintEqualToAnchor:label2.bottomAnchor constant:5.0f],
        [label3.heightAnchor constraintEqualToConstant:15.0f],
        [label3.centerXAnchor constraintEqualToAnchor:view.centerXAnchor]
    ]];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    // https://stackoverflow.com/questions/42246153/returning-cgfloat-leastnormalmagnitude-for-uitableview-section-header-causes-cra
    return (self.datasource.count > 0 || self.checkButton.tag > 0) ? 1.01f : 95.0f;
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
        _checkButton.tag = 0;
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
        _tableView.backgroundColor = UIColor.clearColor;
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
