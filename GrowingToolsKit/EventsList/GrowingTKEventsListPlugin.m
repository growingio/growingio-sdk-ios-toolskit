//
//  GrowingTKEventsListPlugin.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/7.
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

#import "GrowingTKEventsListPlugin.h"
#import "GrowingTKEventsListViewController.h"
#import "GrowingTKDatabase+Event.h"
#import "GrowingTKEventPersistence.h"
#import "GrowingTKSDKUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+GrowingTKSwizzle.h"
#import "GrowingTKUtil.h"
#import "GrowingTKBaseViewController.h"

@interface GrowingTKEventsListPlugin ()

@end

@implementation GrowingTKEventsListPlugin

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _db = [GrowingTKDatabase database];
        [_db createEventsTable];
        [_db cleanExpiredEventIfNeeded];

        [self hookEvents];
        
        [[NSNotificationCenter defaultCenter] addObserver:_db
                                                 selector:@selector(clearAllEvents)
                                                     name:GrowingTKClearAllEventNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showEventsList:)
                                                     name:GrowingTKShowEventsListNotification
                                                   object:nil];
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
    static GrowingTKEventsListPlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKEventsListPlugin alloc] init];
    });
    return instance;
}

- (NSString *)name {
    return GrowingTKLocalizedString(@"事件库");
}

- (NSString *)icon {
    return @"growingtk_eventsList";
}

- (NSString *)pluginName {
    return @"GrowingTKEventsListPlugin";
}

- (NSString *)atModule {
    return GrowingTKDefaultModuleName();
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    if (sdk.isIntegrated) {
        GrowingTKEventsListViewController *controller = [[GrowingTKEventsListViewController alloc] init];
        [GrowingTKHomeWindow openPlugin:controller];
    } else {
        GrowingTKBaseViewController *controller = (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"未集成SDK，请参考帮助文档进行集成")];
    }
}

#pragma mark - Notification

- (void)showEventsList:(NSNotification *)not {
    GrowingTKEventsListViewController *controller = [[GrowingTKEventsListViewController alloc] init];
    UIWindow *window = [not.userInfo[@"window"] isKindOfClass:[UIWindow class]] ? not.userInfo[@"window"]
                                                                                : [GrowingTKHomeWindow sharedInstance];
    controller.gesids = not.userInfo[@"gesids"];
    [(UINavigationController *)window.rootViewController pushViewController:controller animated:YES];
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
        NSString *jsonString = [event valueForKey:@"rawJsonString"];
        if (jsonString.length == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            SEL toJsonObject = NSSelectorFromString(@"toJSONObject");
            if ([event respondsToSelector:toJsonObject]) {
                id jsonObject = [event performSelector:toJsonObject];
                jsonString = [GrowingTKUtil convertJSONFromJSONObject:jsonObject];
            }
#pragma clang diagnostic pop
        }

        GrowingTKEventPersistence *e = [[GrowingTKEventPersistence alloc] initWithUUID:[event valueForKey:@"eventUUID"]
                                                                             eventType:[event valueForKey:@"eventType"]
                                                                            jsonString:jsonString
                                                                                isSend:NO];
        [GrowingTKEventsListPlugin.plugin.db insertEvent:e];
    } else {
        [GrowingTKEventsListPlugin.plugin.db updateEventDidSend:key];
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
        GrowingTKEventPersistence *e =
            [[GrowingTKEventPersistence alloc] initWithUUID:key
                                                  eventType:nil
                                                 jsonString:event
                                                     isSend:NO];
        if (e.eventType.length == 0) {
            // 无法解析，不是事件
            return;
        }
        if ([e.eventType isEqualToString:@"dbclck"]
            || [e.eventType isEqualToString:@"lngclck"]
            || [e.eventType isEqualToString:@"tchd"]) {
            // 不支持的事件，如 dbclck/lngclck/tchd 等等
            return;
        }
        
        [GrowingTKEventsListPlugin.plugin.db insertEvent:e];
    } else {
        [GrowingTKEventsListPlugin.plugin.db updateEventDidSend:key];
    }
}

static id growingtk_valueForUndefinedKey(NSString *key) {
    return @"";
}

@end
