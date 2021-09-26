//
//  GrowingTKViewNode.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/22.
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

#import "GrowingTKViewNode.h"
#import "GrowingTKSDKUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface GrowingTKViewNode ()

@end

@implementation GrowingTKViewNode

#pragma mark - Swizzle

+ (void)load {
    if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
        // *************** SDK 3.0 ***************
    sdk3AvoidKVCCrash : {
        Class class = NSClassFromString(@"GrowingViewNode");
        if (!class) {
            return;
        }
        Method originMethod = class_getInstanceMethod(class, NSSelectorFromString(@"valueForUndefinedKey:"));
        IMP swizzledImplementation = (IMP)growingtk_valueForUndefinedKey;
        if (!class_addMethod(class, method_getName(originMethod), swizzledImplementation, "@@:@")) {
            method_setImplementation(originMethod, swizzledImplementation);
        }
    }
        // *************** SDK 3.0 ***************
    } else {
        // *************** SDK 2.0 ***************

        // *************** SDK 2.0 ***************
    }
}

static id growingtk_valueForUndefinedKey(NSString *key) {
    return @"";
}

#pragma mark - Init

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
        _path = [self pathForView:view];
        Class cls = NSClassFromString(@"GrowingNodeHelper");
        if (cls) {
            SEL selector = NSSelectorFromString(@"getViewNode:");
            if ([cls respondsToSelector:selector]) {
                id node = ((id(*)(id, SEL, id))objc_msgSend)(cls, selector, view);
                _view = [node valueForKey:@"view"];
                _viewName = NSStringFromClass(_view.class);
                _viewContent = [node valueForKey:@"viewContent"] ?: @"";
                _xPath = [node valueForKey:@"xPath"];
                _originXPath = [node valueForKey:@"originXPath"];
                _nodeType = [node valueForKey:@"nodeType"];
                _index = ((NSNumber *)[node valueForKey:@"index"]).intValue;
                _position = ((NSNumber *)[node valueForKey:@"position"]).intValue;
                _hasListParent = ((NSNumber *)[node valueForKey:@"hasListParent"]).boolValue;
            }
        }
    } else {
    }

    return self;
}

- (instancetype)initWithH5Node:(NSDictionary *)nodeDic
                       webView:(UIView *)webView
                        domain:(NSString *)domain
                        h5Path:(NSString *)h5Path {
    if (self = [super init]) {
        _view = webView;
        _viewName = domain;
        _path = h5Path;
        _viewContent = nodeDic[@"v"] ?: @"";
        _xPath = nodeDic[@"x"] ?: @"";
        _nodeType = nodeDic[@"nodeType"] ?: @"";
        _position = 0;
        if (nodeDic[@"idx"]) {
            _index = ((NSNumber *)nodeDic[@"idx"]).intValue;
            _hasListParent = YES;
        } else {
            _index = -1;
            _hasListParent = NO;
        }
    }
    return self;
}

#pragma mark - Public Method

- (NSString *)toString {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"当前: %@", self.viewName]];
    if (self.viewContent.length > 0) {
        [array addObject:[NSString stringWithFormat:@"内容: %@", self.viewContent]];
    }
    if (self.hasListParent) {
        [array addObject:[NSString stringWithFormat:@"列表: %@", @"是"]];
        [array addObject:[NSString stringWithFormat:@"位置: %@", @(self.index)]];
    }
    [array addObject:[NSString stringWithFormat:@"xpath: %@%@", self.path, self.xPath]];
    return [array componentsJoinedByString:@"\n"];
}

#pragma mark - Private Method

- (NSString *)pathForView:(UIView *)view {
    Class cls = NSClassFromString(@"GrowingPageManager");
    if (cls) {
        SEL selector = NSSelectorFromString(@"sharedInstance");
        id pageManager = ((id(*)(id, SEL))objc_msgSend)(cls, selector);
        if (pageManager) {
            SEL selector2 = NSSelectorFromString(@"findPageByView:");
            id page = ((id(*)(id, SEL, UIView *))objc_msgSend)(pageManager, selector2, view);
            if (!page) {
                SEL selector3 = NSSelectorFromString(@"currentPage");
                page = ((id(*)(id, SEL))objc_msgSend)(pageManager, selector3);
            }
            SEL selector4 = NSSelectorFromString(@"path");
            NSString *path = ((NSString * (*)(id, SEL)) objc_msgSend)(page, selector4);
            return path ?: @"";
        }
    }
    return @"";
}

@end
