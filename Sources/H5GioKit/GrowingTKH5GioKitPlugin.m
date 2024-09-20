//
//  GrowingTKH5GioKitPlugin.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/12/29.
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

#import "GrowingTKH5GioKitPlugin.h"
#import "GrowingTKUtil.h"
#import "GrowingTKBaseViewController.h"
#import "GrowingTKDefine.h"

#import "NSBundle+GrowingTK.h"
#import <WebKit/WebKit.h>

@implementation GrowingTKH5GioKitPlugin

#pragma mark - GrowingTKPluginProtocol

+ (instancetype)plugin {
    static GrowingTKH5GioKitPlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKH5GioKitPlugin alloc] init];
    });
    return instance;
}

- (NSString *)name {
    return GrowingTKLocalizedString(@"H5_GioKit");
}

- (NSString *)icon {
    return @"growingtk_h5giokit";
}

- (NSString *)pluginName {
    return @"GrowingTKH5GioKitPlugin";
}

- (NSString *)atModule {
    return GrowingTKDefaultModuleName();
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    NSArray *webViews = [self findViewsForClass:WKWebView.class fromParentView:GrowingTKUtil.keyWindow];
    if (webViews.count > 0) {
        NSString *jsPath = @"https://assets.giocdn.com/sdk/webjs/giokit.min.js";
        NSString *cssPath = @"https://assets.giocdn.com/sdk/webjs/giokit.css";

        NSString *js = [NSString stringWithFormat:@"javascript:(function(){try{var p=document.createElement('script');p.src='%@';p.type='text/javascript';p.onload=function(){var gioKit = new window.GioKit({cssHref: '%@'})};document.head.appendChild(p);}catch(e){}})()", jsPath, cssPath];
        WKWebView *webView = webViews.lastObject;
        @try {
            [webView evaluateJavaScript:js completionHandler:nil];
        } @catch (NSException *exception) {
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKHomeShouldHideNotification object:nil];
    } else {
        GrowingTKBaseViewController *controller = (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"无可用WebView")];
    }
}

- (NSArray *)findViewsForClass:(Class)class fromParentView:(UIView *)parentView {
    NSMutableArray *result = [NSMutableArray array];
    for (UIView *subview in parentView.subviews) {
        if ([subview isKindOfClass:class]) {
            [result addObject:subview];
        }
        [result addObjectsFromArray:[self findViewsForClass:class fromParentView:subview]];
    }
    return result;
}

@end
