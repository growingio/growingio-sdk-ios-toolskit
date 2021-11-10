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
@property (nonatomic, copy, readwrite) NSString *urlSchemesInInfoPlist;
@property (nonatomic, copy, readwrite) NSString *deviceId;
@property (nonatomic, copy, readwrite) NSString *userId;
@property (nonatomic, copy, readwrite) NSString *userKey;
@property (nonatomic, copy, readwrite) NSString *sessionId;
@property (nonatomic, copy, readwrite) NSString *cellularNetworkUploadEventSize;
@property (nonatomic, assign, readwrite) BOOL isIntegrated;
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
@property (nonatomic, assign, readwrite) BOOL encryptEnabled;

// AutoTracker
@property (nonatomic, assign, readwrite) float impressionScale;

// CDP
@property (nonatomic, copy, readwrite) NSString *dataSourceId;

// SDK 2.0
@property (nonatomic, assign, readwrite) float sampling;
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
            return growingtk_sdk3rdInit(@"/Autotracker", invocation, configuration, launchOptions);
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
            return growingtk_sdk3rdInit(@"/Tracker", invocation, configuration, launchOptions);
        };
        invocation = [class growingtk_swizzleClassMethod:selector withBlock:block error:nil];
    }
        // *************** SDK 3.0 ***************
    } else if (GrowingTKSDKUtil.sharedInstance.isSDK2ndGeneration) {
    // *************** SDK 2.0 ***************
    sdk2CoreKitInitialization : {
        Class class = NSClassFromString(@"Growing");
        if (!class) {
            goto end;
        }

        __block NSInvocation *invocation = nil;
        SEL selector = NSSelectorFromString(@"startWithAccountId:withSampling:");
        id block = ^(id obj, NSString *accountId, CGFloat sampling) {
            return growingtk_sdk2ndInit(invocation, accountId, sampling);
        };
        invocation = [class growingtk_swizzleClassMethod:selector withBlock:block error:nil];
    }
    sdk2CoreKitHandleURL : {
        Class class = NSClassFromString(@"Growing");
        if (!class) {
            goto end;
        }

        __block NSInvocation *invocation = nil;
        SEL selector = NSSelectorFromString(@"handleUrl:");
        id block = ^(id obj, NSURL *url) {
            return growingtk_sdk2ndHandleURL(invocation, url);
        };
        invocation = [class growingtk_swizzleClassMethod:selector withBlock:block error:nil];
    }
        // *************** SDK 2.0 ***************
    }
end:;
}

static id growingtk_sdk3rdInit(NSString *module,
                               NSInvocation *invocation,
                               id configuration,
                               NSDictionary *launchOptions) {
    if (!invocation) {
        return nil;
    }
    [invocation retainArguments];

    // 防止集成了无埋点SDK，却初始化了埋点SDK的情况
    GrowingTKSDKUtil.sharedInstance.subName = module;

    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    [invocation setArgument:&configuration atIndex:2];
    [invocation setArgument:&launchOptions atIndex:3];
    [invocation invoke];
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    if (GrowingTKSDKUtil.sharedInstance.initializationTime <= 0) {
        // 避免多次初始化影响，取第一次初始化耗时
        GrowingTKSDKUtil.sharedInstance.initializationTime = (endTime - startTime) * 1000LL;
    }
    GrowingTKSDKUtil.sharedInstance.isInitialized = YES;

    id ret = nil;
    [invocation getReturnValue:&ret];
    return ret;
}

static void growingtk_sdk2ndInit(NSInvocation *invocation, NSString *accountId, CGFloat sampling) {
    if (!invocation) {
        return;
    }
    [invocation retainArguments];

    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    [invocation setArgument:&accountId atIndex:2];
    [invocation setArgument:&sampling atIndex:3];
    [invocation invoke];
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    if (GrowingTKSDKUtil.sharedInstance.initializationTime <= 0) {
        // 避免多次初始化影响，取第一次初始化耗时
        GrowingTKSDKUtil.sharedInstance.initializationTime = (endTime - startTime) * 1000LL;
        GrowingTKSDKUtil.sharedInstance.sampling = sampling;
    }
    GrowingTKSDKUtil.sharedInstance.isInitialized = YES;
}

static BOOL kGrowingTKHandleURL = NO;
static void growingtk_sdk2ndHandleURL(NSInvocation *invocation, NSURL *url) {
    if (!invocation) {
        return;
    }
    [invocation retainArguments];
    [invocation setArgument:&url atIndex:2];
    [invocation invoke];

    kGrowingTKHandleURL = YES;
}

static id growingtk_valueForUndefinedKey(NSString *key) {
    return @"";
}

#pragma mark - Public Method

- (BOOL)isSDK3rdGeneration {
    return NSClassFromString(@"GrowingRealTracker") != nil;
}

- (BOOL)isSDK2ndGeneration {
    return NSClassFromString(@"Growing") != nil;
}

- (BOOL)isSDKAutoTrack {
    if (self.isSDK3rdGeneration) {
        return [self.subName containsString:@"Auto"];
    } else if (self.isSDK2ndGeneration) {
        Class cls = NSClassFromString(@"Growing");
        SEL selector = NSSelectorFromString(@"globalImpScale");
        return [cls respondsToSelector:selector];
    }
    return NO;
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
    } else if (self.isSDK2ndGeneration) {
        // SDK 2.0 windowLevel != UIWindowLevelNormal 不会采集
    }
}

- (void)ignoreView:(UIView *)view {
    if (self.isSDK3rdGeneration) {
        SEL selector = NSSelectorFromString(@"setGrowingViewIgnorePolicy:");
        if ([view respondsToSelector:selector]) {
            ((void (*)(id, SEL, NSUInteger))objc_msgSend)(view, selector, 3 /** GrowingIgnoreAll */);
        }
    } else if (self.isSDK2ndGeneration) {
        SEL selector = NSSelectorFromString(@"setGrowingAttributesDonotTrack:");
        if ([view respondsToSelector:selector]) {
            ((void (*)(id, SEL, BOOL))objc_msgSend)(view, selector, YES);
        }
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
    if (self.isSDK3rdGeneration) {
        Class session = NSClassFromString(@"GrowingSession");
        if (session) {
            SEL selector = NSSelectorFromString(@"currentSession");
            if ([session respondsToSelector:selector]) {
                id s = [session performSelector:selector];
                self.delayInitialized = (s == nil);
            }
        }
    } else if (self.isSDK2ndGeneration) {
        Class cls = NSClassFromString(@"GrowingInstance");
        if (cls) {
            SEL selector = NSSelectorFromString(@"sharedInstance");
            if ([cls respondsToSelector:selector]) {
                id s = [cls performSelector:selector];
                self.delayInitialized = (s == nil);
            }
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
        } else if (self.isSDK2ndGeneration) {
            Class cls = NSClassFromString(@"Growing");
            if ([cls respondsToSelector:NSSelectorFromString(@"trackPage:")]) {
                _name = @"GrowingCDPCoreKit";
            } else if ([cls respondsToSelector:NSSelectorFromString(@"autoTrackKitVersion")]) {
                _name = @"GrowingAutoTrackKit";
            } else {
                _name = @"GrowingCoreKit";
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
        } else if (self.isSDK2ndGeneration) {
            _subName = @"";
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
        } else {
            // dangerous, may cause 'dyld: Symbol not found'
            extern NSString *const GrowingTrackerVersionName;
            extern const int GrowingTrackerVersionCode;
            return [NSString stringWithFormat:@"%@(%d)", GrowingTrackerVersionName, GrowingTrackerVersionCode];
#endif
        }
    } else if (self.isSDK2ndGeneration) {
        Class cls = NSClassFromString(@"Growing");
        SEL selector = NSSelectorFromString(@"sdkVersion");
        if ([cls respondsToSelector:selector]) {
            NSString *version = [cls performSelector:selector];
            return version ?: @"";
        } else if ([cls respondsToSelector:NSSelectorFromString(@"autoTrackKitVersion")]) {
            NSString *version = [cls performSelector:selector];
            return version ?: @"";
        }
    } else {
        return @"-";
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)urlScheme {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class class = NSClassFromString(@"GrowingDeviceInfo");
    SEL selector = NSSelectorFromString(@"currentDeviceInfo");
    if ([class respondsToSelector:selector]) {
        id deviceInfo = [class performSelector:selector];
        SEL selector2 = NSSelectorFromString(@"urlScheme");
        if ([deviceInfo respondsToSelector:selector2]) {
            NSString *urlScheme = [deviceInfo performSelector:selector2];
            return urlScheme ?: @"";
        }
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)urlSchemesInInfoPlist {
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
    } else if (self.isSDK2ndGeneration) {
        Class class = NSClassFromString(@"GrowingCustomField");
        SEL selector = NSSelectorFromString(@"shareInstance");
        if ([class respondsToSelector:selector]) {
            id instance = [class performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"cs1");
            if ([instance respondsToSelector:selector2]) {
                NSString *userId = [instance performSelector:selector2];
                return userId ?: @"";
            }
        }
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
    } else if (self.isSDK2ndGeneration) {
        Class class = NSClassFromString(@"Growing");
        SEL selector = NSSelectorFromString(@"getSessionId");
        if ([class respondsToSelector:selector]) {
            NSString *sessionId = [class performSelector:selector];
            return sessionId ?: @"";
        }
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
    } else if (self.isSDK2ndGeneration) {
        Class class = NSClassFromString(@"GrowingFileStore");
        SEL selector = NSSelectorFromString(@"cellularNetworkUploadEventSize");
        unsigned long long size = ((unsigned long long (*)(id, SEL))objc_msgSend)(class, selector);
        return [NSString stringWithFormat:@"%.2fKB", (double)size / 1000];
    }
    return @"";
}

- (BOOL)isIntegrated {
    return self.isSDK3rdGeneration || self.isSDK2ndGeneration;
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
    } else if (self.isSDK2ndGeneration) {
        kGrowingTKHandleURL = NO;
        NSObject *delegate = [UIApplication sharedApplication].delegate;
        if ([delegate respondsToSelector:@selector(application:openURL:options:)]) {
            ((BOOL(*)(id, SEL, id, id, id))objc_msgSend)(delegate,
                                                         @selector(application:openURL:options:),
                                                         [UIApplication sharedApplication],
                                                         [NSURL URLWithString:@"growingio://test"],
                                                         nil);
            return kGrowingTKHandleURL;
        } else if ([delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
            ((BOOL(*)(id, SEL, id, id, id, id))objc_msgSend)(delegate,
                                                             @selector(application:
                                                                           openURL:sourceApplication:annotation:),
                                                             [UIApplication sharedApplication],
                                                             [NSURL URLWithString:@"growingio://test"],
                                                             @"",
                                                             nil);
            return kGrowingTKHandleURL;
        } else if ([delegate respondsToSelector:@selector(application:handleOpenURL:)]) {
            ((BOOL(*)(id, SEL, id, id))objc_msgSend)(delegate,
                                                     @selector(application:handleOpenURL:),
                                                     [UIApplication sharedApplication],
                                                     [NSURL URLWithString:@"growingio://test"]);
            return kGrowingTKHandleURL;
        } else {
            return NO;
        }
    }
    return NO;
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
    } else if (self.isSDK2ndGeneration) {
        kGrowingTKHandleURL = NO;
        NSObject *delegate = [UIApplication sharedApplication].delegate;
        NSUserActivity *acitivity = [[NSUserActivity alloc] initWithActivityType:@"Test"];
        void (^block)(NSArray<id<UIUserActivityRestoring>> *_Nullable) =
            ^(NSArray<id<UIUserActivityRestoring>> *_Nullable array) {
            };
        if ([delegate respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
            ((BOOL(*)(id, SEL, id, id, id))objc_msgSend)(delegate,
                                                         @selector(application:
                                                             continueUserActivity:restorationHandler:),
                                                         [UIApplication sharedApplication],
                                                         acitivity,
                                                         block);
            return kGrowingTKHandleURL;
        } else {
            return NO;
        }
    }
    return NO;
}

- (NSString *)projectId {
    if (self.isSDK3rdGeneration) {
        return [self.sdk3rdConfiguration valueForKey:@"projectId"] ?: @"";
    } else if (self.isSDK2ndGeneration) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        Class cls = NSClassFromString(@"GrowingInstance");
        SEL selector = NSSelectorFromString(@"sharedInstance");
        if ([cls respondsToSelector:selector]) {
            id instance = [cls performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"accountID");
            if ([instance respondsToSelector:selector2]) {
                NSString *accountId = [instance performSelector:selector2];
                return accountId ?: @"";
            }
        }
#pragma clang diagnostic pop
    }
    return @"";
}

- (BOOL)debugEnabled {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"debugEnabled"]).boolValue;
    } else if (self.isSDK2ndGeneration) {
        Class class = NSClassFromString(@"Growing");
        SEL selector = NSSelectorFromString(@"getEnableLog");
        return ((BOOL(*)(id, SEL))objc_msgSend)(class, selector);
    }
    return YES;
}

- (NSUInteger)cellularDataLimit {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"cellularDataLimit"]).integerValue;
    } else if (self.isSDK2ndGeneration) {
        Class class = NSClassFromString(@"Growing");
        SEL selector = NSSelectorFromString(@"getDailyDataLimit");
        NSUInteger limit = ((NSUInteger(*)(id, SEL))objc_msgSend)(class, selector);
        return limit / 1024;
    }
    return 0;
}

- (NSTimeInterval)dataUploadInterval {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"dataUploadInterval"]).doubleValue;
    } else if (self.isSDK2ndGeneration) {
        Class class = NSClassFromString(@"Growing");
        SEL selector = NSSelectorFromString(@"getFlushInterval");
        return ((NSTimeInterval(*)(id, SEL))objc_msgSend)(class, selector);
    }
    return 0;
}

- (NSTimeInterval)sessionInterval {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"sessionInterval"]).doubleValue;
    } else if (self.isSDK2ndGeneration) {
        Class class = NSClassFromString(@"Growing");
        SEL selector = NSSelectorFromString(@"getSessionInterval");
        return ((NSTimeInterval(*)(id, SEL))objc_msgSend)(class, selector);
    }
    return 0;
}

- (BOOL)dataCollectionEnabled {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"dataCollectionEnabled"]).boolValue;
    } else if (self.isSDK2ndGeneration) {
#ifdef GROWING_SDK2nd
        // dangerous, may cause 'dyld: Symbol not found'
        extern BOOL g_GDPRFlag;
        return !g_GDPRFlag;
#endif
    }
    return NO;
}

- (BOOL)uploadExceptionEnable {
    if (self.isSDK3rdGeneration) {
        return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"uploadExceptionEnable"]).boolValue;
    } else if (self.isSDK2ndGeneration) {
        // TODO:SDK 2.0
    }
    return NO;
}

- (NSString *)dataCollectionServerHost {
    if (self.isSDK3rdGeneration) {
        return [self.sdk3rdConfiguration valueForKey:@"dataCollectionServerHost"] ?: @"";
    } else if (self.isSDK2ndGeneration) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        Class cls = NSClassFromString(@"GrowingNetworkConfig");
        SEL selector = NSSelectorFromString(@"sharedInstance");
        if ([cls respondsToSelector:selector]) {
            id instance = [cls performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"growingApiHost");
            if ([instance respondsToSelector:selector2]) {
                NSString *host = [instance performSelector:selector2];
                return host ?: @"";
            }
        }
#pragma clang diagnostic pop
    }
    return @"";
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
        return NO;
    }
}

- (BOOL)encryptEnabled {
    if (self.isSDK3rdGeneration) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        Class cls = NSClassFromString(@"GrowingEventRequestHeaderAdapter");
        id adapter = [[cls alloc] init];
        SEL selector = NSSelectorFromString(@"adaptedRequest:");
        if ([adapter respondsToSelector:selector]) {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            request = [adapter performSelector:selector withObject:request];
            for (NSString *key in request.allHTTPHeaderFields.allKeys) {
                if ([key isEqualToString:@"X-Crypt-Codec"]) {
                    return YES;
                }
            }
        }
#pragma clang diagnostic pop
        return NO;
    } else {
        return YES;
    }
}

- (float)impressionScale {
    if (self.isSDKAutoTrack) {
        if (self.isSDK3rdGeneration) {
            return ((NSNumber *)[self.sdk3rdConfiguration valueForKey:@"impressionScale"]).floatValue;
        } else if (self.isSDK2ndGeneration) {
            Class class = NSClassFromString(@"Growing");
            SEL selector = NSSelectorFromString(@"globalImpScale");
            return ((double (*)(id, SEL))objc_msgSend)(class, selector);
        }
    }
    return 0;
}

- (NSString *)dataSourceId {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.isSDK3rdGeneration) {
        Class cls = self.isSDKAutoTrack ? NSClassFromString(@"GrowingAutotracker") : NSClassFromString(@"GrowingTracker");
        SEL selector = NSSelectorFromString(@"sharedInstance");
        if ([cls respondsToSelector:selector]) {
            id instance = [cls performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"interceptor");
            // [GrowingAutotracker/GrowingTracker class] 被hook了，所以这里用 instancesRespondToSelector 而不是 respondsToSelector
            if ([cls instancesRespondToSelector:selector2]) {
                id interceptor = [instance performSelector:selector2];
                SEL selector3 = NSSelectorFromString(@"dataSourceId");
                if ([interceptor respondsToSelector:selector3]) {
                    NSString *dataSourceId = [interceptor performSelector:selector3];
                    return dataSourceId ?: @"";
                }
            }
        }
    } else if (self.isSDK2ndGeneration) {
        Class cls = NSClassFromString(@"GrowingInstance");
        SEL selector = NSSelectorFromString(@"sharedInstance");
        if ([cls respondsToSelector:selector]) {
            id instance = [cls performSelector:selector];
            SEL selector2 = NSSelectorFromString(@"dataSourceID");
            if ([instance respondsToSelector:selector2]) {
                NSString *dataSourceId = [instance performSelector:selector2];
                return dataSourceId ?: @"";
            }
        }
    }
#pragma clang diagnostic pop
    return @"";
}

- (NSString *)sdk2ndAspectMode {
    Class class = NSClassFromString(@"Growing");
    SEL selector = NSSelectorFromString(@"getAspectMode");
    NSInteger mode = ((NSInteger(*)(id, SEL))objc_msgSend)(class, selector);
    return mode == 1 ? @"AspectModeDynamicSwizzling" : @"AspectModeSubClass";
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
