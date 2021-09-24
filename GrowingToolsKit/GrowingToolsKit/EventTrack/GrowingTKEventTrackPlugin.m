//
//  GrowingTKEventTrackPlugin.m
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

#import "GrowingTKEventTrackPlugin.h"
#import "GrowingTKEventTrackWindow.h"

@interface GrowingTKEventTrackPlugin ()

@property (nonatomic, strong) GrowingTKEventTrackWindow *trackView;

@end

@implementation GrowingTKEventTrackPlugin

#pragma mark - GrowingTKPluginProtocol

+ (instancetype)plugin {
    static GrowingTKEventTrackPlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKEventTrackPlugin alloc] init];
    });
    return instance;
}

- (NSString *)name {
    return GrowingTKLocalizedString(@"埋点跟踪");
}

- (NSString *)icon {
    return @"growingtk_eventTrack";
}

- (NSString *)pluginName {
    return @"GrowingTKEventTrackPlugin";
}

- (NSString *)atModule {
    return GrowingTKDefaultModuleName();
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    [self showTrackView];
}

#pragma mark - Event Track

- (void)showTrackView {
    [self.trackView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKHomeShouldHideNotification object:nil];
}

- (void)hideTrackView {
    [self.trackView hide];
}

- (GrowingTKEventTrackWindow *)trackView {
    if (!_trackView) {
        _trackView = [[GrowingTKEventTrackWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideTrackView)
                                                     name:GrowingTKHomeWillShowNotification
                                                   object:nil];
    }
    return _trackView;
}

@end
