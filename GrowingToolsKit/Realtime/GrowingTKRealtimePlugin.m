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
#import "GrowingTKRealtimeEvent.h"
#import "GrowingTKSDKUtil.h"
#import "GrowingTKUtil.h"
#import "GrowingTKBaseViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+GrowingTKSwizzle.h"

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
        [self toggleRealtimeWindow];
    } else {
        GrowingTKBaseViewController *controller = (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"未初始化SDK，请参考帮助文档进行SDK初始化配置")];
    }
}

#pragma mark - Realtime View

- (void)toggleRealtimeWindow {
    [self.realtimeWindow toggle];
    
    NSString *name = self.realtimeWindow.isHidden ? GrowingTKLocalizedString(@"实时事件") : GrowingTKLocalizedString(@"实时事件监控中");
    [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKRealtimeStatusNotification
                                                        object:nil
                                                      userInfo:@{@"key" : self.key,
                                                                 @"name" : name,
                                                                 @"isSelected" : @(!self.realtimeWindow.isHidden)
                                                               }];
}

- (GrowingTKRealtimeWindow *)realtimeWindow {
    if (!_realtimeWindow) {
        _realtimeWindow = [[GrowingTKRealtimeWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
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
        NSNumber *globalSequenceId = nil;
        NSNumber *timestamp = nil;
        NSString *detail = @"";
        BOOL isCustomEvent = NO;
        
        NSString *rawJsonString = [event valueForKey:@"rawJsonString"];
        if (rawJsonString.length == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            SEL toJsonObject = NSSelectorFromString(@"toJSONObject");
            if ([event respondsToSelector:toJsonObject]) {
                id jsonObject = [event performSelector:toJsonObject];
                rawJsonString = [GrowingTKUtil convertJSONFromJSONObject:jsonObject];
            }
#pragma clang diagnostic pop
        }
        NSData *jsonData = [rawJsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *eventDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        if (eventDic && eventDic.count > 0) {
            globalSequenceId = eventDic[@"globalSequenceId"];
            timestamp = eventDic[@"timestamp"];
            
            if ([eventType isEqualToString:@"PAGE"]) {
                detail = eventDic[@"path"];
                detail = [detail componentsSeparatedByString:@"/"].lastObject;
            } else if ([eventType isEqualToString:@"CUSTOM"]) {
                detail = eventDic[@"eventName"];
                if (eventDic[@"attributes"]) {
                    NSString *eventDuration = eventDic[@"attributes"][@"eventDuration"];
                    if (eventDuration) {
                        detail = [NSString stringWithFormat:@"%@(%@)", detail, eventDuration];
                    }
                }
            } else if ([eventType isEqualToString:@"VISIT"]) {
                detail = eventDic[@"sessionId"];
            } else if ([eventType isEqualToString:@"VIEW_CLICK"]) {
                detail = eventDic[@"xpath"];
                detail = [detail componentsSeparatedByString:@"/"].lastObject;
            } else if ([eventType isEqualToString:@"VIEW_CHANGE"]) {
                detail = eventDic[@"xpath"];
                detail = [detail componentsSeparatedByString:@"/"].lastObject;
            }
            
            if ([eventType isEqualToString:@"CUSTOM"]
                || [eventType isEqualToString:@"PAGE_ATTRIBUTES"]
                || [eventType isEqualToString:@"CONVERSION_VARIABLES"]
                || [eventType isEqualToString:@"LOGIN_USER_ATTRIBUTES"]
                || [eventType isEqualToString:@"VISITOR_ATTRIBUTES"]) {
                isCustomEvent = YES;
            }
        }
        
        GrowingTKRealtimeEvent *eventEntity = [[GrowingTKRealtimeEvent alloc] init];
        eventEntity.eventType = eventType;
        eventEntity.globalSequenceId = globalSequenceId;
        eventEntity.detail = detail;
        eventEntity.timestamp = timestamp;
        eventEntity.isCustomEvent = isCustomEvent;
        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKRealtimeEventNotification
                                                            object:nil
                                                          userInfo:@{@"event": eventEntity}];
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
        if ([eventType isEqualToString:@"dbclck"]
            || [eventType isEqualToString:@"lngclck"]
            || [eventType isEqualToString:@"tchd"]) {
            // 不支持的事件，如 dbclck/lngclck/tchd 等等
            return;
        }
        
        NSNumber *gesid = eventDic[@"gesid"];
        NSNumber *timestamp = eventDic[@"tm"];
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
        
        BOOL isCustomEvent = NO;
        if ([eventType isEqualToString:@"cstm"]
            || [eventType isEqualToString:@"activate"]
            || [eventType isEqualToString:@"reengage"]) {
            isCustomEvent = YES;
        }

        GrowingTKRealtimeEvent *eventEntity = [[GrowingTKRealtimeEvent alloc] init];
        eventEntity.eventType = eventType;
        eventEntity.globalSequenceId = gesid;
        eventEntity.detail = detail;
        eventEntity.timestamp = timestamp;
        eventEntity.isCustomEvent = isCustomEvent;
        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKRealtimeEventNotification
                                                            object:nil
                                                          userInfo:@{@"event": eventEntity}];
    }
}

static id growingtk_valueForUndefinedKey(NSString *key) {
    return @"";
}

@end
