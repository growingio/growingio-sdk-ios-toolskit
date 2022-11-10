//
//  GrowingTKSDKInfoViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/19.
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

#import "GrowingTKSDKInfoViewController.h"
#import "GrowingTKSDKInfoTableViewCell.h"
#import "GrowingTKNavigationItemView.h"
#import "UIColor+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "UIViewController+GrowingTK.h"
#import "GrowingTKUtil.h"
#import "GrowingTKAppInfoUtil.h"
#import "GrowingTKSDKUtil.h"
#import "GrowingTKPermission.h"
#import "GrowingTKDevice.h"

@interface GrowingTKSDKInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, copy) NSString *networkPermission;

@end

@implementation GrowingTKSDKInfoViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [GrowingTKPermission stopListenToNetworkPermission];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.growingtk_fullscreen;
}

#pragma mark - Private Method

- (void)initUI {
    self.title = GrowingTKLocalizedString(@"SDK信息");

    self.tableView =
        [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.growingtk_width, self.view.growingtk_height)
                                     style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = UIColor.growingtk_white_1;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedSectionFooterHeight = 0.01f;
    [self.tableView registerClass:[GrowingTKSDKInfoTableViewCell class]
           forCellReuseIdentifier:@"GrowingTKSDKInfoTableViewCell"];
    [self.view addSubview:self.tableView];

    __weak typeof(self) weakSelf = self;
    GrowingTKNavigationItemView *customView =
        [[GrowingTKNavigationItemView alloc] initRightButtonWithFrame:CGRectMake(0, 0, 90, 44)
                                                                 text:GrowingTKLocalizedString(@"一键截图")
                                                            textColor:UIColor.growingtk_primaryBackgroundColor
                                                               action:^{
                                                                   __strong typeof(weakSelf) self = weakSelf;
                                                                   [self snapshotAction];
                                                               }];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)initData {
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    NSMutableArray *sdkInfo = [NSMutableArray arrayWithArray:@[
        @{@"title":  GrowingTKLocalizedString(@"SDK"), @"value": sdk.isIntegrated ? sdk.nameDescription : GrowingTKLocalizedString(@"未集成")},
        @{@"title": GrowingTKLocalizedString(@"SDK版本号"), @"value": sdk.version},
        @{@"title": GrowingTKLocalizedString(@"SDK初始化"), @"value": sdk.initializationDescription},
        @{@"title":  GrowingTKLocalizedString(@"URL Scheme"), @"value": sdk.urlScheme.length > 0 ? sdk.urlScheme : GrowingTKLocalizedString(@"未配置")},
        @{@"title":  GrowingTKLocalizedString(@"URL Schemes(InfoPlist)"), @"value": sdk.urlSchemesInInfoPlist.length > 0 ? sdk.urlSchemesInInfoPlist : GrowingTKLocalizedString(@"未配置")},
        @{@"title": GrowingTKLocalizedString(@"适配URL Scheme"), @"value": GrowingTKLocalizedString(sdk.isAdaptToURLScheme ? @"YES" : @"NO")},
        @{@"title": GrowingTKLocalizedString(@"适配Deep Link"), @"value": GrowingTKLocalizedString(sdk.isAdaptToDeepLink ? @"YES" : @"NO")}
    ]];

    if (sdk.isInitialized) {
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"Project ID"), @"value": sdk.projectId}];
        if (sdk.isSDK2ndGeneration) {
            [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"采样率"), @"value": [NSString stringWithFormat:@"%.3f%%", sdk.sampling * 100]}];
            [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"采集模式"), @"value": sdk.sdk2ndAspectMode}];
            [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"剪贴板权限"), @"value": GrowingTKLocalizedString(sdk.readClipBoardEnabled ? @"YES" : @"NO")}];
            [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"ASA 归因分析"), @"value": GrowingTKLocalizedString(sdk.asaEnabled ? @"YES" : @"NO")}];
        }

        if (sdk.dataSourceId.length > 0) {
            [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"DataSource ID"), @"value": sdk.dataSourceId}];
        }

        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"Device ID"), @"value": sdk.deviceId}];

        NSString *userId = sdk.userId;
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"User ID"), @"value": userId.length > 0 ? userId : GrowingTKLocalizedString(@"未配置")}];

        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"Session ID"), @"value": sdk.sessionId}];
        
        if (sdk.isSDK3rdGeneration) {
            NSString *idMappingEnabled = GrowingTKLocalizedString(sdk.idMappingEnabled ? @"YES" : @"NO");
            [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"Id Mapping"), @"value": idMappingEnabled}];
            
            if (sdk.idMappingEnabled) {
                NSString *userKey = sdk.userKey;
                [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"User Key"), @"value": userKey.length > 0 ? userKey : GrowingTKLocalizedString(@"未配置")}];
            }
        }

        NSString *debugEnabled = GrowingTKLocalizedString(sdk.debugEnabled ? @"YES" : @"NO");
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"调试模式"), @"value": debugEnabled}];
        
        NSString *encryptEnabled = GrowingTKLocalizedString(sdk.encryptEnabled ? @"YES" : @"NO");
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"数据加密"), @"value": encryptEnabled}];
        
        if (sdk.isSDK3rdGeneration) {
            [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"集成模块"), @"value": [sdk.SDK3Modules componentsJoinedByString:@", "]}];
        }

        NSString *cellularDataLimit = [NSString stringWithFormat:@"%luMB", (unsigned long)sdk.cellularDataLimit];
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"每日流量限制"), @"value": cellularDataLimit}];

        NSString *uploadSize = sdk.cellularNetworkUploadEventSize;
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"当前流量使用"), @"value": uploadSize}];

        NSString *dataUploadInterval = [NSString stringWithFormat:@"%.fs", sdk.dataUploadInterval];
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"数据发送间隔"), @"value": dataUploadInterval}];

        NSString *sessionInterval = [NSString stringWithFormat:@"%.fs", sdk.sessionInterval];
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"会话后台留存时长"), @"value": sessionInterval}];

        NSString *dataCollectionEnabled = sdk.dataCollectionEnabled ? @"YES" : @"NO";
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"是否采集数据"), @"value": dataCollectionEnabled}];

        NSString *dataCollectionServerHost = sdk.dataCollectionServerHost;
        [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"ServerHost"), @"value": dataCollectionServerHost}];

        if (sdk.isSDK3rdGeneration) {
            NSString *excludeEvent = sdk.excludeEventDescription;
            if (excludeEvent.length > 0) {
                [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"事件过滤"), @"value": excludeEvent}];
            }
            
            NSString *ignoreField = sdk.ignoreFieldDescription;
            if (ignoreField.length > 0) {
                [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"事件属性过滤"), @"value": ignoreField}];
            }
        }

        if (sdk.isSDKAutoTrack) {
            NSString *impressionScale = [NSString stringWithFormat:@"%.f", sdk.impressionScale];
            [sdkInfo addObject:@{@"title": GrowingTKLocalizedString(@"曝光事件比例因子"), @"value": impressionScale}];
        }
    }

    NSString *deviceName = [GrowingTKDevice deviceName];
    NSString *deviceSystemVersion = [GrowingTKDevice deviceSystemVersion];
    NSString *deviceType = [GrowingTKDevice platformString];
    NSString *deviceSize = [NSString stringWithFormat:@"%.0f * %.0f", GrowingTKScreenWidth, GrowingTKScreenHeight];
    NSString *ipv4 = [GrowingTKDevice IPv4Address];
    NSString *ipv6 = [GrowingTKDevice IPv6Address];
    NSString *appName = [GrowingTKAppInfoUtil appName];
    NSString *bundleIdentifier = [GrowingTKAppInfoUtil bundleIdentifier];
    NSString *bundleVersion = [GrowingTKAppInfoUtil bundleVersion];
    NSString *bundleShortVersionString = [GrowingTKAppInfoUtil bundleShortVersionString];
    GrowingTKAuthorizationStatus locationPermission = [GrowingTKPermission locationPermission];

    self.networkPermission = GrowingTKLocalizedString(@"用户没有选择");
    __weak typeof(self) weakSelf = self;
    [GrowingTKPermission startListenToNetworkPermissionDidUpdate:^(GrowingTKAuthorizationStatus status) {
        __strong typeof(weakSelf) self = weakSelf;
        switch (status) {
            case GrowingTKAuthorizationStatusNotDetermined:
                self.networkPermission = GrowingTKLocalizedString(@"用户没有选择");
                break;
            case GrowingTKAuthorizationStatusRestricted:
                self.networkPermission = GrowingTKLocalizedString(@"受限制 - 永不或WLAN");
                break;
            case GrowingTKAuthorizationStatusAuthorized:
                self.networkPermission = GrowingTKLocalizedString(@"无线局域网与蜂窝数据");
                break;
            default:
                break;
        }

        NSMutableDictionary *item = self.dataArray[3][@"array"][1];
        [item setValue:self.networkPermission forKey:@"value"];

        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            [self.tableView reloadData];
        });
    }];

    GrowingTKAuthorizationStatus pushPermission = [GrowingTKPermission pushPermission];
    GrowingTKAuthorizationStatus cameraPermission = [GrowingTKPermission cameraPermission];
    GrowingTKAuthorizationStatus audioPermission = [GrowingTKPermission audioPermission];
    GrowingTKAuthorizationStatus photoPermission = [GrowingTKPermission photoPermission];
    GrowingTKAuthorizationStatus contactsPermission = [GrowingTKPermission contactsPermission];
    GrowingTKAuthorizationStatus calendarPermission = [GrowingTKPermission calendarPermission];
    GrowingTKAuthorizationStatus notesPermission = [GrowingTKPermission notesPermission];

    NSArray *dataArray = @[
        @{@"title": GrowingTKLocalizedString(@"SDK信息"), @"array": sdkInfo},
        @{
            @"title": GrowingTKLocalizedString(@"手机信息"),
            @"array": @[
                @{@"title": GrowingTKLocalizedString(@"设备名称"), @"value": deviceName},
                @{@"title": GrowingTKLocalizedString(@"手机型号"), @"value": deviceType},
                @{@"title": GrowingTKLocalizedString(@"系统版本"), @"value": deviceSystemVersion},
                @{@"title": GrowingTKLocalizedString(@"手机屏幕"), @"value": deviceSize},
                @{@"title": @"IPv4", @"value": ipv4},
                @{@"title": @"IPv6", @"value": ipv6}
            ]
        },
        @{
            @"title": GrowingTKLocalizedString(@"App信息"),
            @"array": @[
                @{@"title": GrowingTKLocalizedString(@"AppName"), @"value": appName},
                @{@"title": GrowingTKLocalizedString(@"Bundle ID"), @"value": bundleIdentifier},
                @{@"title": GrowingTKLocalizedString(@"Version"), @"value": bundleShortVersionString},
                @{@"title": GrowingTKLocalizedString(@"Build"), @"value": bundleVersion}
            ]
        },
        @{
            @"title": GrowingTKLocalizedString(@"权限信息"),
            @"array": @[
                @{@"title": GrowingTKLocalizedString(@"地理位置权限"), @"value": @(locationPermission)},
                @{@"title": GrowingTKLocalizedString(@"网络权限"), @"value": self.networkPermission}.mutableCopy,
                @{@"title": GrowingTKLocalizedString(@"推送权限"), @"value": @(pushPermission)},
                @{@"title": GrowingTKLocalizedString(@"相机权限"), @"value": @(cameraPermission)},
                @{@"title": GrowingTKLocalizedString(@"麦克风权限"), @"value": @(audioPermission)},
                @{@"title": GrowingTKLocalizedString(@"相册权限"), @"value": @(photoPermission)},
                @{@"title": GrowingTKLocalizedString(@"通讯录权限"), @"value": @(contactsPermission)},
                @{@"title": GrowingTKLocalizedString(@"日历权限"), @"value": @(calendarPermission)},
                @{@"title": GrowingTKLocalizedString(@"提醒事项权限"), @"value": @(notesPermission)}
            ]
        }
    ];
    self.dataArray = dataArray;
}

- (UIImage *)snapshot {
    UIGraphicsBeginImageContextWithOptions(self.tableView.contentSize, NO, UIScreen.mainScreen.scale);
    self.tableView.contentOffset = CGPointZero;
    CGRect frame = CGRectMake(0, 0, self.tableView.contentSize.width, self.tableView.contentSize.height);
    self.tableView.frame = frame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [self.tableView removeFromSuperview];
    [view addSubview:self.tableView];
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self.tableView removeFromSuperview];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.growingtk_fullscreen;

    return image;
}

#pragma mark - Action

- (void)snapshotAction {
    CGPoint originOffset = self.tableView.contentOffset;
    NSInteger maxSection = self.dataArray.count - 1;
    NSInteger maxRow = ((NSArray *)self.dataArray[maxSection][@"array"]).count - 1;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:maxRow inSection:maxSection]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *image = [self snapshot];
        self.tableView.contentOffset = originOffset;
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[image]
                                                                                 applicationActivities:nil];
        [self presentViewController:controller animated:YES completion:nil];
    });
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section][@"array"];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GrowingTKSDKInfoTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"GrowingTKSDKInfoTableViewCell" forIndexPath:indexPath];
    NSArray *array = self.dataArray[indexPath.section][@"array"];
    NSDictionary *item = array[indexPath.row];
    [cell renderUIWithData:item];
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.growingtk_width, GrowingTKSizeFrom750(80))];
    sectionView.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(GrowingTKSizeFrom750(32),
                                                                    0,
                                                                    GrowingTKScreenWidth - GrowingTKSizeFrom750(32),
                                                                    GrowingTKSizeFrom750(80))];
    NSDictionary *dic = self.dataArray[section];
    titleLabel.text = dic[@"title"];
    titleLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
    titleLabel.textColor = UIColor.whiteColor;
    [sectionView addSubview:titleLabel];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return GrowingTKSizeFrom750(80);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3) {
        [GrowingTKUtil openAppSetting];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section != 3;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *action = [UITableViewRowAction
        rowActionWithStyle:UITableViewRowActionStyleDefault
                     title:GrowingTKLocalizedString(@"复制")
                   handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                       NSString *value = weakSelf.dataArray[indexPath.section][@"array"][indexPath.row][@"value"];
                       UIPasteboard *pboard = [UIPasteboard generalPasteboard];
                       pboard.string = value;
                   }];

    return @[action];
}

@end

