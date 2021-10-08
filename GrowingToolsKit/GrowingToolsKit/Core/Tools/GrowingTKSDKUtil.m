//
//  GrowingTKSDKUtil.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/17.
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

#import "GrowingTKSDKUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+GrowingTKSwizzle.h"

@interface GrowingTKSDKUtil ()

// Common
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *subName;
@property (nonatomic, copy, readwrite) NSString *version;
@property (nonatomic, copy, readwrite) NSString *urlScheme;
@property (nonatomic, copy, readwrite) NSString *deviceId;
@property (nonatomic, copy, readwrite) NSString *userId;
@property (nonatomic, copy, readwrite) NSString *userKey;
@property (nonatomic, copy, readwrite) NSString *sessionId;
@property (nonatomic, copy, readwrite) NSString *cellularNetworkUploadEventSize;
@property (nonatomic, assign, readwrite) BOOL isInitialized;
@property (nonatomic, assign, readwrite) double initializationTime;
@property (nonatomic, assign, readwrite) BOOL delayInitialized;
@property (nonatomic, assign, readwrite, getter=isAdaptToURLScheme) BOOL adaptToURLScheme;
@property (nonatomic, assign, readwrite, getter=isAdaptToDeepLink) BOOL adaptToDeepLink;

// Tracker
@property (nonatomic, copy, readwrite) NSString *projectId;
@property (nonatomic, assign, readwrite) BOOL debugEnabled;
@property (nonatomic, assign, readwrite) NSUInteger cellularDataLimit;
@property (nonatomic, assign, readwrite) NSTimeInterval dataUploadInterval;
@property (nonatomic, assign, readwrite) NSTimeInterval sessionInterval;
@property (nonatomic, assign, readwrite) BOOL dataCollectionEnabled;
@property (nonatomic, assign, readwrite) BOOL uploadExceptionEnable;
@property (nonatomic, copy, readwrite) NSString *dataCollectionServerHost;
@property (nonatomic, assign, readwrite) NSUInteger excludeEvent;
@property (nonatomic, assign, readwrite) NSUInteger ignoreField;
@property (nonatomic, assign, readwrite) BOOL idMappingEnabled;

// AutoTracker
@property (nonatomic, assign, readwrite) float impressionScale;

// CDP
@property (nonatomic, copy, readwrite) NSString *dataSourceId;

// SDK 2.0
@property (nonatomic, copy, readwrite) NSString *sdk2ndAspectMode;

// Private
@property (nonatomic, strong, nullable) NSObject *sdk3rdConfiguration;

@end

@implementation GrowingTKSDKUtil

#pragma mark - Init

+ (instancetype)sharedInstance {
    static GrowingTKSDKUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKSDKUtil alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(applicationDidFinishLaunching)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    });
    return instance;
}

#pragma mark - Swizzle

+ (void)load {
    if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
        // *************** SDK 3.0 ***************
    sdk3AvoidKVCCrash : {
        Class class = NSClassFromString(@"GrowingTrackConfiguration");
        if (!class) {
            goto sdk3AutotrackerInitialization;
        }
        Method originMethod = class_getInstanceMethod(class, NSSelectorFromString(@"valueForUndefinedKey:"));
        IMP swizzledImplementation = (IMP)growingtk_valueForUndefinedKey;
        if (!class_addMethod(class, method_getName(originMethod), swizzledImplementation, "@@:@")) {
            method_setImplementation(originMethod, swizzledImplementation);
        }
    }
    sdk3AutotrackerInitialization : {
        Class class = NSClassFromString(@"GrowingRealAutotracker");
        if (!class) {
            goto sdk3TrackerInitialization;
        }

        __block NSInvocation *invocation = nil;
        SEL selector = NSSelectorFromString(@"trackerWithConfiguration:launchOptions:");
        id block = ^(id obj, id configuration, NSDictionary *launchOptions) {
            return growingtk_trackerInit(@"/Autotracker", invocation, configuration, launchOptions);
        };
        invocation = [class growingtk_swizzleClassMethod:selector withBlock:block error:nil];
    }
    sdk3TrackerInitialization : {
        Class class = NSClassFromString(@"GrowingRealTracker");
        if (!class) {
            goto end;
        }

        __block NSInvocation *invocation = nil;
        SEL selector = NSSelectorFromString(@"trackerWithConfiguration:launchOptions:");
        id block = ^(id obj, id configuration, NSDictionary *launchOptions) {
            return growingtk_trackerInit(@"/Tracker", invocation, configuration, launchOptions);
        };
        invocation = [class growingtk_swizzleClassMethod:selector withBlock:block error:nil];
    }
        // *************** SDK 3.0 ***************
    } else {
        // *************** SDK 2.0 ***************

        // *************** SDK 2.0 ***************
    }
end:;
}

static id growingtk_trackerInit(NSString *module,
                                NSInvocation *invocation,
                                id configuration,
                                NSDictionary *launchOptions) {
    if (!invocation) {
        return nil;
    }
    [invocation retainArguments];

    GrowingTKSDKUtil.sharedInstance.subName = module;

    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    [invocation setArgument:&configuration atIndex:2];
    [invocation setArgument:&launchOptions atIndex:3];
    [invocation invoke];
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    if (GrowingTKSDKUtil.sharedInstance.initializationTime <= 0) {
        //避免多次初始化影响，取第一次初始化耗时
        GrowingTKSDKUtil.sharedInstance.initializationTime = (endTime - startTime) * 1000LL;
    }
    GrowingTKSDKUtil.sharedInstance.isInitialized = YES;

    id ret = nil;
    [invocation getReturnValue:&ret];
    return ret;
}

static id growingtk_valueForUndefinedKey(NSString *key) {
    return @"";
}

#pragma mark - Public Method

- (BOOL)isSDK3rdGeneration {
    return NSClassFromString(@"GrowingRealTracker");
}

- (NSString *)nameDescription {
    return [NSString stringWithFormat:@"%@%@", self.name, self.subName];
}

- (NSString *)initializationDescription {
    return self.isInitialized ? (self.delayInitialized
                                     ? [NSString stringWithFormat:@"延迟初始化(耗时: %.2fms)", self.initializationTime]
                                     : [NSString stringWithFormat:@"已初始化(耗时: %.2fms)", self.initializationTime])
                              : @"未初始化";
}

- (NSString *)excludeEventDescription {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.isSDK3rdGeneration) {
        NSMutableArray *array = [NSMutableArray array];
        Class class = NSClassFromString(@"GrowingEventFilter");
        SEL selector = NSSelectorFromString(@"filterEventItems");
        if ([class respondsToSelector:selector]) {
            NSArray *filterItems = [class performSelector:selector];
            for (NSString *name in filterItems) {
                BOOL isFilter =
                    ((BOOL(*)(id, SEL, NSString *))objc_msgSend)(class, NSSelectorFromString(@"isFilterEvent:"), name);
                if (isFilter) {
                    [array addObject:name];
                }
            }
            return [array componentsJoinedByString:@"\n"];
        }
    } else {
        return @"";
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)ignoreFieldDescription {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.isSDK3rdGeneration) {
        NSMutableArray *array = [NSMutableArray array];
        Class class = NSClassFromString(@"GrowingFieldsIgnore");
        SEL selector = NSSelectorFromString(@"ignoreFieldsItems");
        if ([class respondsToSelector:selector]) {
            NSArray *filterItems = [class performSelector:selector];
            for (NSString *name in filterItems) {
                BOOL isFilter =
                    ((BOOL(*)(id, SEL, NSString *))objc_msgSend)(class, NSSelectorFromString(@"isIgnoreFields:"), name);
                if (isFilter) {
                    [array addObject:name];
                }
            }
            return [array componentsJoinedByString:@"\n"];
        }
    } else {
        return @"";
    }
#pragma clang diagnostic pop
    return @"";
}

- (void)ignoreViewController:(UIViewController *)viewController {
    if (self.isSDK3rdGeneration) {
        SEL selector = NSSelectorFromString(@"setGrowingPageIgnorePolicy:");
        if ([viewController respondsToSelector:selector]) {
            ((void (*)(id, SEL, NSUInteger))objc_msgSend)(viewController, selector, 3 /** GrowingIgnoreAll */);
        }
    } else {
    }
}

- (void)ignoreView:(UIView *)view {
    if (self.isSDK3rdGeneration) {
        SEL selector = NSSelectorFromString(@"setGrowingViewIgnorePolicy:");
        if ([view respondsToSelector:selector]) {
            ((void (*)(id, SEL, NSUInteger))objc_msgSend)(view, selector, 3 /** GrowingIgnoreAll */);
        }
    } else {
    }
}

#pragma mark - Private Method

- (Class)sceneDelegate {
    NSDictionary *sceneManifest = [[NSBundle mainBundle] infoDictionary][@"UIApplicationSceneManifest"];
    NSArray *rols = [sceneManifest objectForKey:@"UISceneConfigurations"][@"UIWindowSceneSessionRoleApplication"];
    if (rols.count == 0) {
        return nil;
    }
    for (NSDictionary *dic in rols) {
        NSString *classname = dic[@"UISceneDelegateClassName"];
        if (classname) {
            Class cls = NSClassFromString(classname);
            return cls;
        }
    }
    return nil;
}

#pragma mark - Notification

- (void)applicationDidFinishLaunching {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class session = NSClassFromString(@"GrowingSession");
    if (session) {
        SEL selector = NSSelectorFromString(@"currentSession");
        if ([session respondsToSelector:selector]) {
            id s = [session performSelector:selector];
            self.delayInitialized = (s == nil);
        }
    }
#pragma clang diagnostic pop
}

#pragma mark - Setter & Getter

- (NSString *)name {
    if (!_name) {
        if (self.isSDK3rdGeneration) {
            if (NSClassFromString(@"GrowingCdpEventInterceptor")) {
                _name = @"GrowingAnalytics-cdp";
            } else {
                _name = @"GrowingAnalytics";
            }
        } else {
            _name = @"";
        }
    }
    return _name;
}

- (NSString *)subName {
    if (!_subName) {
        if (self.isSDK3rdGeneration) {
            if (NSClassFromString(@"GrowingRealAutotracker")) {
                _subName = @"/Autotracker";
            } else if (NSClassFromString(@"GrowingRealTracker")) {
                _subName = @"/Tracker";
            }
        } else {
            _subName = @"";
        }
    }
    return _subName;
}

- (NSString *)version {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.isSDK3rdGeneration) {
        Class class = NSClassFromString(@"GrowingRealTracker");
        SEL selector = NSSelectorFromString(@"versionName");
        if ([class respondsToSelector:selector]) {
            NSString *version = [class performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"versionCode");
            if (version && [class respondsToSelector:selector2]) {
                NSString *code = [class performSelector:selector2];
                return [NSString stringWithFormat:@"%@(%@)", version, code];
            }
            return version ?: @"";
#ifdef GROWING_SDK30202
        }else {
            // dangerous, may cause 'dyld: Symbol not found'
            extern NSString *const GrowingTrackerVersionName;
            extern const int GrowingTrackerVersionCode;
            return [NSString stringWithFormat:@"%@(%d)", GrowingTrackerVersionName, GrowingTrackerVersionCode];
#endif
        }
    } else {
        return @"";
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)urlScheme {
    NSArray *urlTypes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in urlTypes) {
        NSArray *urlSchemes = [dic objectForKey:@"CFBundleURLSchemes"];
        for (NSString *urlScheme in urlSchemes) {
            if ([urlScheme isKindOfClass:[NSString class]] && [urlScheme hasPrefix:@"growing."]) {
                [array addObject:urlScheme.copy];
            }
        }
    }
    return [array componentsJoinedByString:@"\n"];
}

- (NSString *)deviceId {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.isSDK3rdGeneration) {
        Class class = NSClassFromString(@"GrowingDeviceInfo");
        SEL selector = NSSelectorFromString(@"currentDeviceInfo");
        if ([class respondsToSelector:selector]) {
            id deviceInfo = [class performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"deviceIDString");
            if ([deviceInfo respondsToSelector:selector2]) {
                NSString *deviceIDString = [deviceInfo performSelector:selector2];
                return deviceIDString ?: @"";
            }
        }
    } else {
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)userId {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.isSDK3rdGeneration) {
        Class class = NSClassFromString(@"GrowingSession");
        SEL selector = NSSelectorFromString(@"currentSession");
        if ([class respondsToSelector:selector]) {
            id session = [class performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"loginUserId");
            if ([session respondsToSelector:selector2]) {
                NSString *userId = [session performSelector:selector2];
                return userId ?: @"";
            }
        }
    } else {
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)userKey {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.isSDK3rdGeneration) {
        Class class = NSClassFromString(@"GrowingSession");
        SEL selector = NSSelectorFromString(@"currentSession");
        if ([class respondsToSelector:selector]) {
            id session = [class performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"loginUserKey");
            if ([session respondsToSelector:selector2]) {
                NSString *userKey = [session performSelector:selector2];
                return userKey ?: @"";
            }
        }
    } else {
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)sessionId {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.isSDK3rdGeneration) {
        Class class = NSClassFromString(@"GrowingSession");
        SEL selector = NSSelectorFromString(@"currentSession");
        if ([class respondsToSelector:selector]) {
            id session = [class performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"sessionId");
            if ([session respondsToSelector:selector2]) {
                NSString *sessionId = [session performSelector:selector2];
                return sessionId ?: @"";
            }
        }
    } else {
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)cellularNetworkUploadEventSize {
    if (self.isSDK3rdGeneration) {
        Class class = NSClassFromString(@"GrowingDataTraffic");
        SEL selector = NSSelectorFromString(@"cellularNetworkUploadEventSize");
        unsigned long long size = ((unsigned long long (*)(id, SEL))objc_msgSend)(class, selector);
        return [NSString stringWithFormat:@"%.2fKB", (double)size / 1000];
    } else {
        return @"";
    }
}

- (BOOL)isAdaptToURLScheme {
    Class sceneDelegate = self.sceneDelegate;
    if (self.isSDK3rdGeneration) {
        if (sceneDelegate) {
            SEL sel = @selector(scene:openURLContexts:);
            Method method = class_getInstanceMethod(sceneDelegate, sel);
            return method ? YES : NO;
        } else {
            NSObject *delegate = [UIApplication sharedApplication].delegate;
            if ([delegate respondsToSelector:@selector(application:openURL:options:)]) {
                return YES;
            } else if ([delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
                return YES;
            } else if ([delegate respondsToSelector:@selector(application:handleOpenURL:)]) {
                return YES;
            } else {
                return NO;
            }
        }
    } else {
        return YES;
    }
}

- (BOOL)isAdaptToDeepLink {
    Class sceneDelegate = self.sceneDelegate;
    if (self.isSDK3rdGeneration) {
        if (sceneDelegate) {
            SEL sel = @selector(scene:continueUserActivity:);
            Method method = class_getInstanceMethod(sceneDelegate, sel);
            return method ? YES : NO;
        } else {
            NSObject *delegate = [UIApplication sharedApplication].delegate;
            if ([delegate respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
                return YES;
            } else {
                return NO;
            }
        }
    } else {
        return YES;
    }
}

- (NSString *)projectId {
    if (self.isSDK3rdGeneration) {
        return [self.sdk3rdConfiguration valueForKey:@"projectId"] ?: @"";
    } else {
        return @"";
    }
}

- (BOOL)debugEnabled {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"debugEnabled"]).boolValue;
    } else {
        return YES;
    }
}

- (NSUInteger)cellularDataLimit {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"cellularDataLimit"]).integerValue;
    } else {
        return 0;
    }
}

- (NSTimeInterval)dataUploadInterval {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"dataUploadInterval"]).doubleValue;
    } else {
        return 0;
    }
}

- (NSTimeInterval)sessionInterval {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"sessionInterval"]).doubleValue;
    } else {
        return 0;
    }
}

- (BOOL)dataCollectionEnabled {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"dataCollectionEnabled"]).boolValue;
    } else {
        return YES;
    }
}

- (BOOL)uploadExceptionEnable {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"uploadExceptionEnable"]).boolValue;
    } else {
        return YES;
    }
}

- (NSString *)dataCollectionServerHost {
    if (self.isSDK3rdGeneration) {
        return [self.sdk3rdConfiguration valueForKey:@"dataCollectionServerHost"] ?: @"";
    } else {
        return @"";
    }
}

- (NSUInteger)excludeEvent {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"excludeEvent"]).integerValue;
    } else {
        return 0;
    }
}

- (NSUInteger)ignoreField {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"ignoreField"]).integerValue;
    } else {
        return 0;
    }
}

- (BOOL)idMappingEnabled {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"idMappingEnabled"]).boolValue;
    } else {
        return YES;
    }
}

- (float)impressionScale {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"impressionScale"]).floatValue;
    } else {
        return 0;
    }
}

- (NSString *)dataSourceId {
    if (self.isSDK3rdGeneration) {
        return [self.sdk3rdConfiguration valueForKey:@"dataSourceId"] ?: @"";
    } else {
        return @"";
    }
}

- (NSString *)sdk2ndAspectMode {
    return @"AspectModeDynamicSwizzling";  // AspectModeSubClass
}

- (NSObject *)sdk3rdConfiguration {
    if (!_sdk3rdConfiguration) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        Class class = NSClassFromString(@"GrowingConfigurationManager");
        SEL selector = NSSelectorFromString(@"sharedInstance");
        if (class && [class respondsToSelector:selector]) {
            id manager = [class performSelector:selector];
            SEL configurationSelector = NSSelectorFromString(@"trackConfiguration");
            if (manager && [manager respondsToSelector:configurationSelector]) {
                NSObject *configuration = [manager performSelector:configurationSelector];
                if (configuration) {
                    _sdk3rdConfiguration = configuration;
                }
            }
        }
#pragma clang diagnostic pop
    }
    return _sdk3rdConfiguration;
}

@end
