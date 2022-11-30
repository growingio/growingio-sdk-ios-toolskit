//
//  GrowingTKEventsListHeaderView.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/10.
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

#import "GrowingTKEventsListHeaderView.h"
#import "GrowingTKEventTypeChooseView.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "GrowingTKSDKUtil.h"

@interface UISearchBar (GrowingTK)

@end

@implementation UISearchBar (GrowingTK)

- (nullable UITextField *)growingtk_textField {
    if (@available(iOS 13.0, *)) {
        return self.searchTextField;
    } else {
        for (UIView *view in self.subviews) {
            for (UIView *subView in view.subviews) {
                if ([subView isKindOfClass:[UITextField class]]) {
                    return (UITextField *)subView;
                }
            }
        }
    }
    return nil;
}

@end

@interface GrowingTKEventsListHeaderView () <UISearchBarDelegate>

@property (nonatomic, copy) void (^searchCallback)(NSString *, BOOL);
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *typeButton;
@property (nonatomic, strong) GrowingTKEventTypeChooseView *chooseView;

@end

@implementation GrowingTKEventsListHeaderView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame searchCallback:(void (^)(NSString *, BOOL))searchCallback {
    if (self = [super initWithFrame:frame]) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchBar.growingtk_textField.keyboardType = UIKeyboardTypeASCIICapable;
        self.searchBar.growingtk_textField.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28)];
        self.searchBar.placeholder = GrowingTKLocalizedString(@"输入要搜索的事件类型");
        self.searchBar.delegate = self;
        self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.searchBar];

        self.typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.typeButton.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;
        self.typeButton.layer.cornerRadius = 5.0f;
        self.typeButton.titleLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(28) weight:UIFontWeightBold];
        [self.typeButton setTitle:GrowingTKLocalizedString(@"类型") forState:UIControlStateNormal];
        [self.typeButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.typeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.typeButton];

        [NSLayoutConstraint activateConstraints:@[
            [self.typeButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                          constant:20.0f],
            [self.typeButton.trailingAnchor constraintEqualToAnchor:self.searchBar.leadingAnchor],
            [self.typeButton.centerYAnchor constraintEqualToAnchor:self.searchBar.centerYAnchor],
            [self.typeButton.widthAnchor constraintEqualToConstant:GrowingTKSizeFrom750(100)],
            [self.typeButton.heightAnchor constraintEqualToConstant:GrowingTKSizeFrom750(60)],
            [self.searchBar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor
                                                          constant:-20.0f],
            [self.searchBar.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [self.searchBar.heightAnchor constraintEqualToConstant:GrowingTKSizeFrom750(70)]
        ]];

        self.searchCallback = searchCallback;
    }
    return self;
}

#pragma mark - Public Method

- (void)reset {
    if (self.chooseView && self.chooseView.superview) {
        [self.chooseView removeFromSuperview];
        self.chooseView = nil;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    if (self.searchCallback) {
        self.searchCallback(searchBar.growingtk_textField.text, NO);
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self reset];
    return YES;
}

#pragma mark - Action

- (void)buttonAction:(UIButton *)button {
    [self endEditing:YES];

    if (self.chooseView.superview) {
        [self reset];
        return;
    }

    __weak typeof(self) weakSelf = self;
    CGPoint point = CGPointMake(button.growingtk_right, button.growingtk_bottom);
    point = [self convertPoint:point toView:self.window];
    self.chooseView = [[GrowingTKEventTypeChooseView alloc] initWithPoint:point
                                                                    types:self.types
                                                           chooseCallback:^(NSUInteger index) {
        NSString *type = weakSelf.types[index];
        if (weakSelf.searchCallback) {
            weakSelf.searchCallback(type, YES);
        }
        
        [weakSelf.chooseView removeFromSuperview];
        weakSelf.chooseView = nil;
    }];

    [self.growingtk_viewController.view addSubview:self.chooseView];
}

#pragma mark - Getter & Setter

- (NSArray<NSString *> *)types {
    if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
        return @[
            @"PAGE",
            @"CUSTOM",
            @"VISIT",
            @"VIEW_CLICK",
            @"APP_CLOSED",
            @"VIEW_CHANGE",
            @"FORM_SUBMIT",
            @"PAGE_ATTRIBUTES",
            @"CONVERSION_VARIABLES",
            @"LOGIN_USER_ATTRIBUTES",
            @"VISITOR_ATTRIBUTES"
        ];
    } else {
        return @[@"page", @"vst", @"cstm", @"clck", @"imp", @"chng", @"reengage", @"activate"];
    }
}

@end
