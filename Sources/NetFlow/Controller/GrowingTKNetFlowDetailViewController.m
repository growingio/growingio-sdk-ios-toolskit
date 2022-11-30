//
//  GrowingTKNetFlowDetailViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/9.
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

#import "GrowingTKNetFlowDetailViewController.h"
#import "GrowingTKNetFlowDetailTableViewCell.h"
#import "GrowingTKSegmentedControl.h"
#import "GrowingTKRequestPersistence.h"
#import "UIImage+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKNumberUtil.h"
#import "GrowingTKUtil.h"

@interface GrowingTKNetFlowDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) GrowingTKSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UITableView *requestTableView;
@property (nonatomic, strong) UITableView *responseTableView;

@end

@implementation GrowingTKNetFlowDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.requestTableView];
    [self.view addSubview:self.responseTableView];

    CGFloat margin = GrowingTKSizeFrom750(24.0f);
    CGFloat closeButtonSideLength = GrowingTKSizeFrom750(60.0f);
    CGFloat segmentedControlWidth = GrowingTKSizeFrom750(320.0f);
    CGFloat segmentedControlHeight = GrowingTKSizeFrom750(80.0f);
    [NSLayoutConstraint activateConstraints:@[
        [self.segmentedControl.centerYAnchor constraintEqualToAnchor:self.closeButton.centerYAnchor],
        [self.segmentedControl.centerXAnchor
            constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.centerXAnchor],
        [self.segmentedControl.widthAnchor constraintEqualToConstant:segmentedControlWidth],
        [self.segmentedControl.heightAnchor constraintEqualToConstant:segmentedControlHeight],
        [self.closeButton.topAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.topAnchor
                                                   constant:margin],
        [self.closeButton.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor
                                                        constant:-margin],
        [self.closeButton.widthAnchor constraintEqualToConstant:closeButtonSideLength],
        [self.closeButton.heightAnchor constraintEqualToConstant:closeButtonSideLength],
        [self.requestTableView.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor constant:10.0f],
        [self.requestTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.requestTableView.leadingAnchor
            constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor],
        [self.requestTableView.trailingAnchor
            constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor],
        [self.responseTableView.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor constant:10.0f],
        [self.responseTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.responseTableView.leadingAnchor
            constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor],
        [self.responseTableView.trailingAnchor
            constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];

    self.requestTableView.hidden = NO;
    self.responseTableView.hidden = YES;
}

#pragma mark - Action

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return tableView == self.requestTableView ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GrowingTKNetFlowDetailTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"GrowingTKNetFlowDetailTableViewCell" forIndexPath:indexPath];
    if (tableView == self.requestTableView) {
        switch (indexPath.section) {
            case 0: {
                double mb = 1024.0 * 1024.0;
                double kb = 1024.0;
                double uploadFlow = self.request.uploadFlow.doubleValue;
                double requestBodyLength = self.request.requestBodyLength.doubleValue;
                NSString *length = nil;
                NSString *groupingSepUploadFlow = [GrowingTKNumberUtil.sharedInstance groupingSeparator:@(uploadFlow)];
                NSString *groupingSepRequestBodyLength =
                    [GrowingTKNumberUtil.sharedInstance groupingSeparator:@(requestBodyLength)];
                if (uploadFlow > mb) {
                    length = [NSString stringWithFormat:@"%.2f MB (%@ bytes, Body %@ bytes)",
                                                        uploadFlow / mb,
                                                        groupingSepUploadFlow,
                                                        groupingSepRequestBodyLength];
                } else if (uploadFlow > kb) {
                    length = [NSString stringWithFormat:@"%.2f KB (%@ bytes, Body %@ bytes)",
                                                        uploadFlow / kb,
                                                        groupingSepUploadFlow,
                                                        groupingSepRequestBodyLength];
                } else {
                    length = [NSString stringWithFormat:@"%@ bytes, Body %@ bytes",
                                                        groupingSepUploadFlow,
                                                        groupingSepRequestBodyLength];
                }

                NSString *text = [NSString stringWithFormat:@"%@：%@\n%@：%@\n%@：%@\n%@：%.f%@",
                                                            GrowingTKLocalizedString(@"链接"),
                                                            self.request.url,
                                                            GrowingTKLocalizedString(@"请求方式"),
                                                            self.request.method,
                                                            GrowingTKLocalizedString(@"请求大小"),
                                                            length,
                                                            GrowingTKLocalizedString(@"耗时"),
                                                            self.request.totalDuration.doubleValue * 1000,
                                                            GrowingTKLocalizedString(@"毫秒")];
                [cell showText:text];
            } break;
            case 1: {
                if (!self.request.requestHeader) {
                    [cell showText:GrowingTKLocalizedString(@"无")];
                    break;
                }
                NSString *jsonString = [GrowingTKUtil convertJSONFromJSONObject:self.request.requestHeader];
                [cell showText:jsonString];
            } break;
            case 2: {
                [cell showText:self.request.requestBody];
            } break;
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0: {
                NSString *text = [NSString stringWithFormat:@"%@：%@\n%@：%@\n%@：%@",
                                                            GrowingTKLocalizedString(@"链接"),
                                                            self.request.url,
                                                            GrowingTKLocalizedString(@"返回码"),
                                                            self.request.statusCode,
                                                            GrowingTKLocalizedString(@"返回信息"),
                                                            self.request.status];
                [cell showText:text];
            } break;
            case 1: {
                if (!self.request.responseHeader) {
                    [cell showText:GrowingTKLocalizedString(@"无")];
                    break;
                }
                NSString *jsonString = [GrowingTKUtil convertJSONFromJSONObject:self.request.responseHeader];
                [cell showText:jsonString];
            } break;
            default:
                break;
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GrowingTKScreenWidth, 40)];
    view.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, GrowingTKScreenWidth - 32, 24)];
    if (tableView == self.requestTableView) {
        switch (section) {
            case 0:
                label.text = GrowingTKLocalizedString(@"消息体");
                break;
            case 1:
                label.text = GrowingTKLocalizedString(@"请求头");
                break;
            case 2:
                label.text = GrowingTKLocalizedString(@"请求数据");
                break;
            default:
                break;
        }
    } else {
        switch (section) {
            case 0:
                label.text = GrowingTKLocalizedString(@"消息体");
                break;
            case 1:
                label.text = GrowingTKLocalizedString(@"响应头");
                break;
            default:
                break;
        }
    }
    label.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
    label.textColor = UIColor.whiteColor;
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

#pragma mark - Getter & Setter

- (UITableView *)requestTableView {
    if (!_requestTableView) {
        _requestTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _requestTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _requestTableView.backgroundColor = UIColor.growingtk_white_1;
        _requestTableView.delegate = self;
        _requestTableView.dataSource = self;
        _requestTableView.sectionFooterHeight = 0.01f;
        _requestTableView.allowsSelection = NO;
        _requestTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_requestTableView registerClass:[GrowingTKNetFlowDetailTableViewCell class]
                  forCellReuseIdentifier:@"GrowingTKNetFlowDetailTableViewCell"];
    }
    return _requestTableView;
}

- (UITableView *)responseTableView {
    if (!_responseTableView) {
        _responseTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _responseTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _responseTableView.backgroundColor = UIColor.growingtk_white_1;
        _responseTableView.delegate = self;
        _responseTableView.dataSource = self;
        _responseTableView.sectionFooterHeight = 0.01f;
        _responseTableView.allowsSelection = NO;
        _responseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_responseTableView registerClass:[GrowingTKNetFlowDetailTableViewCell class]
                   forCellReuseIdentifier:@"GrowingTKNetFlowDetailTableViewCell"];
    }
    return _responseTableView;
}

- (GrowingTKSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        __weak typeof(self) weakSelf = self;
        NSArray *titles = @[GrowingTKLocalizedString(@"请求"), GrowingTKLocalizedString(@"响应")];
        _segmentedControl =
            [[GrowingTKSegmentedControl alloc] initWithTitles:titles
                                                selectedBlock:^(NSInteger index, NSString *_Nonnull title) {
                                                    __strong typeof(weakSelf) self = weakSelf;
                                                    self.requestTableView.hidden = index != 0;
                                                    self.responseTableView.hidden = index == 0;
                                                }];
        _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _segmentedControl;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeButton setBackgroundImage:[UIImage growingtk_imageNamed:@"growingtk_close"]
                                forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
