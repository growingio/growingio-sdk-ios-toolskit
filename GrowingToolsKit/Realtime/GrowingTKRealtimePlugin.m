//
//  GrowingTKRealtimePlugin.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/8/3.
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

#import "GrowingTKRealtimePlugin.h"
#import "GrowingTKRealtimeWindow.h"
#import "GrowingTKSDKUtil.h"
#import "GrowingTKUtil.h"
#import "GrowingTKBaseViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+GrowingTKSwizzle.h"

NSString *const GrowingTKRealtimeNotification = @"GrowingTKRealtimeNotification";

@interface GrowingTKRealtimePlugin ()

@property (nonatomic, strong) GrowingTKRealtimeWindow *realtimeWindow;

@end

@implementation GrowingTKRealtimePlugin

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        [self hookEvents];
    }
    return self;
}

- (void)hookEvents {
    if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
    // *************** SDK 3.0 ***************
    sdk3AvoidKVCCrash : {
        Class class = NSClassFromString(@"GrowingEventJSONPersistence");
        if (!class) {
            class = NSClassFromString(@"GrowingEventPersistence");
            if (!class) {
                return;
            }
        }
        Method originMethod = class_getInstanceMethod(class, NSSelectorFromString(@"valueForUndefinedKey:"));
        IMP swizzledImplementation = (IMP)growingtk_valueForUndefinedKey;
        if (!class_addMethod(class, method_getName(originMethod), swizzledImplementation, "@@:@")) {
            method_setImplementation(originMethod, swizzledImplementation);
        }
    }
    sdk3ProtobufAvoidKVCCrash : {
        Class class = NSClassFromString(@"GrowingEventProtobufPersistence");
        if (!class) {
            goto sdk3EventTrack;
        }
        Method originMethod = class_getInstanceMethod(class, NSSelectorFromString(@"valueForUndefinedKey:"));
        IMP swizzledImplementation = (IMP)growingtk_valueForUndefinedKey;
        if (!class_addMethod(class, method_getName(originMethod), swizzledImplementation, "@@:@")) {
            method_setImplementation(originMethod, swizzledImplementation);
        }
    }
    sdk3EventTrack : {
        Class class = NSClassFromString(@"GrowingEventDatabase");
        if (!class) {
            return;
        }

        __block NSInvocation *invocation = nil;
        SEL selector = NSSelectorFromString(@"setEvent:forKey:");
        id block = ^(id obj, id event, NSString *key) {
            return growingtk_eventTrack(invocation, obj, event, key);
        };
        invocation = [class growingtk_swizzleMethod:selector withBlock:block error:nil];
    }
        // *************** SDK 3.0 ***************
    } else {
        // *************** SDK 2.0 ***************
    sdk2EventTrack : {
        Class class = NSClassFromString(@"GrowingEventDataBase");
        if (!class) {
            return;
        }

        __block NSInvocation *invocation = nil;
        SEL selector = NSSelectorFromString(@"setValue:forKey:error:");
        id block = ^(id obj, NSString *event, NSString *key, NSError **error) {
            return growingtk_sdk2ndEventTrack(invocation, obj, event, key, error);
        };
        invocation = [class growingtk_swizzleMethod:selector withBlock:block error:nil];
    }
        // *************** SDK 2.0 ***************
    }
}

#pragma mark - GrowingTKPluginProtocol

+ (instancetype)plugin {
    static GrowingTKRealtimePlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKRealtimePlugin alloc] init];
    });
    return instance;
}

- (NSString *)name {
    return GrowingTKLocalizedString(@"实时事件");
}

- (NSString *)icon {
    return @"growingtk_realtime";
}

- (NSString *)pluginName {
    return @"GrowingTKRealtimePlugin";
}

- (NSString *)atModule {
    return GrowingTKDefaultModuleName();
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    if (sdk.isInitialized) {
        [self showRealtimeWindow];
    } else {
        GrowingTKBaseViewController *controller = (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"未初始化SDK，请参考帮助文档进行SDK初始化配置")];
    }
}

#pragma mark - Realtime View

- (void)showRealtimeWindow {
    [self.realtimeWindow show];
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKHomeShouldHideNotification object:nil];
}

- (void)hideRealtimeWindow {
    [self.realtimeWindow hide];
}

- (GrowingTKRealtimeWindow *)realtimeWindow {
    if (!_realtimeWindow) {
        _realtimeWindow = [[GrowingTKRealtimeWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideRealtimeWindow)
                                                     name:GrowingTKHomeWillShowNotification
                                                   object:nil];
    }
    return _realtimeWindow;
}

#pragma mark - Event Track

static void growingtk_eventTrack(NSInvocation *invocation, id obj, id event, NSString *key) {
    if (!invocation) {
        return;
    }
    [invocation setArgument:&event atIndex:2];
    [invocation setArgument:&key atIndex:3];
    [invocation invokeWithTarget:obj];

    if (event) {
        NSString *eventType = [event valueForKey:@"eventType"];
        NSNumber *gesid = nil;
        NSString *detail = @"";
        
        NSString *rawJsonString = [event valueForKey:@"rawJsonString"];
        NSData *jsonData = [rawJsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *eventDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        if (eventDic && eventDic.count > 0) {
            gesid = eventDic[@"globalSequenceId"];
            
            if ([eventType isEqualToString:@"PAGE"]) {
                detail = eventDic[@"path"];
                detail = [detail componentsSeparatedByString:@"/"].lastObject;
            } else if ([eventType isEqualToString:@"CUSTOM"]) {
                detail = eventDic[@"eventName"];
            } else if ([eventType isEqualToString:@"VISIT"]) {
                detail = eventDic[@"sessionId"];
            } else if ([eventType isEqualToString:@"VIEW_CLICK"]) {
                detail = eventDic[@"xpath"];
                detail = [detail componentsSeparatedByString:@"/"].lastObject;
            } else if ([eventType isEqualToString:@"VIEW_CHANGE"]) {
                detail = eventDic[@"xpath"];
                detail = [detail componentsSeparatedByString:@"/"].lastObject;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKRealtimeNotification
                                                            object:nil
                                                          userInfo:@{@"eventType": eventType,
                                                                     @"gesid" : gesid,
                                                                     @"detail" : detail}];
    }
}

static void growingtk_sdk2ndEventTrack(NSInvocation *invocation, id obj, NSString *event, NSString *key, NSError **error) {
    if (!invocation) {
        return;
    }
    [invocation setArgument:&event atIndex:2];
    [invocation setArgument:&key atIndex:3];
    [invocation setArgument:&error atIndex:4];
    [invocation invokeWithTarget:obj];

    if (event) {
        NSData *jsonData = [event dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *eventDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        if (!eventDic || eventDic.count == 0) {
            return;
        }
        NSString *eventType = eventDic[@"t"];
        if (eventType.length == 0) {
            // 无法解析，不是事件
            return;
        }
        
        NSNumber *gesid = eventDic[@"gesid"];
        if (!gesid) {
            // 不支持的事件，如 dbclck/lngclck 等等
            return;
        }
        NSString *detail = @"";
        if ([eventType isEqualToString:@"page"]) {
            detail = eventDic[@"p"];
        } else if ([eventType isEqualToString:@"cstm"]) {
            detail = eventDic[@"n"];
        } else if ([eventType isEqualToString:@"vst"]) {
            detail = eventDic[@"s"];
        } else if ([eventType isEqualToString:@"clck"]) {
            detail = eventDic[@"x"];
            detail = [detail componentsSeparatedByString:@"/"].lastObject;
        } else if ([eventType isEqualToString:@"chng"]) {
            detail = eventDic[@"x"];
            detail = [detail componentsSeparatedByString:@"/"].lastObject;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKRealtimeNotification
                                                            object:nil
                                                          userInfo:@{@"eventType" : eventType,
                                                                     @"gesid" : gesid,
                                                                     @"detail" : detail}];
    }
}

static id growingtk_valueForUndefinedKey(NSString *key) {
    return @"";
}

@end
