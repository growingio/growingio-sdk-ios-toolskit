//
//  GrowingTKXPathTrackPlugin.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/16.
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

#import "GrowingTKXPathTrackPlugin.h"
#import "GrowingTKXPathTrackWindow.h"
#import "GrowingTKSDKUtil.h"
#import "GrowingTKUtil.h"
#import "GrowingTKBaseViewController.h"

@interface GrowingTKXPathTrackPlugin ()

@property (nonatomic, strong) GrowingTKXPathTrackWindow *trackView;

@end

@implementation GrowingTKXPathTrackPlugin

#pragma mark - GrowingTKPluginProtocol

+ (instancetype)plugin {
    static GrowingTKXPathTrackPlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKXPathTrackPlugin alloc] init];
    });
    return instance;
}

- (NSString *)name {
    return GrowingTKLocalizedString(@"XPath跟踪");
}

- (NSString *)icon {
    return @"growingtk_xPathTrack";
}

- (NSString *)pluginName {
    return @"GrowingTKXPathTrackPlugin";
}

- (NSString *)atModule {
    return GrowingTKDefaultModuleName();
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    if (sdk.isIntegrated && sdk.isSDKAutoTrack) {
        [self showTrackView];
    } else {
        GrowingTKBaseViewController *controller = (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"未集成无埋点SDK，请参考帮助文档进行集成")];
    }
}

#pragma mark - Event Track

- (void)showTrackView {
    [self.trackView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKHomeShouldHideNotification object:nil];
}

- (void)hideTrackView {
    [self.trackView hide];
}

- (GrowingTKXPathTrackWindow *)trackView {
    if (!_trackView) {
        _trackView = [[GrowingTKXPathTrackWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideTrackView)
                                                     name:GrowingTKHomeWillShowNotification
                                                   object:nil];
    }
    return _trackView;
}

@end
