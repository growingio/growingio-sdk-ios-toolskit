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
#import "GrowingTKDefine.h"
#import "GrowingTKSDKUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation GrowingTKViewNode

#pragma mark - Swizzle

+ (void)load {
    if (![GrowingTKUseInRelease activeOrNot]) {
        return;
    }
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
    } else if (GrowingTKSDKUtil.sharedInstance.isSDK2ndGeneration) {
        // *************** SDK 2.0 ***************
    sdk2AvoidKVCCrash : {
        Class class = NSClassFromString(@"GrowingElement");
        if (!class) {
            return;
        }
        Method originMethod = class_getInstanceMethod(class, NSSelectorFromString(@"valueForUndefinedKey:"));
        IMP swizzledImplementation = (IMP)growingtk_valueForUndefinedKey;
        if (!class_addMethod(class, method_getName(originMethod), swizzledImplementation, "@@:@")) {
            method_setImplementation(originMethod, swizzledImplementation);
        }
    }
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
        Class cls = NSClassFromString(@"GrowingNodeHelper");
        if (cls) {
            SEL selector = NSSelectorFromString(@"getViewNode:");
            if ([cls respondsToSelector:selector]) {
                id node = ((id(*)(id, SEL, id))objc_msgSend)(cls, selector, view);
                _view = [node valueForKey:@"view"];
                _viewName = NSStringFromClass(_view.class);
                _viewContent = [node valueForKey:@"viewContent"] ?: @"";
                _path = [self pathForView:view];
                _xpath = [node valueForKey:@"xpath"];
                _xcontent = [node valueForKey:@"xcontent"];
                _index = ((NSNumber *)[node valueForKey:@"index"]).intValue;
                _hasListParent = ((NSNumber *)[node valueForKey:@"hasListParent"]).boolValue;
                
                // unused
                _originxpath = [node valueForKey:@"originXPath"];
                _originxcontent = [node valueForKey:@"originxcontent"];
                _nodeType = [node valueForKey:@"nodeType"];
                _position = ((NSNumber *)[node valueForKey:@"position"]).intValue;
            }
        }
    } else if (GrowingTKSDKUtil.sharedInstance.isSDK2ndGeneration) {
        Class cls = NSClassFromString(@"GrowingLocalCircleWindow");
        if (cls) {
            id circle = [[cls alloc] init];
            SEL selector = NSSelectorFromString(@"getElementFromNode:");
            if ([circle respondsToSelector:selector]) {
                id element = ((id(*)(id, SEL, id))objc_msgSend)(circle, selector, view);
                _view = view;
                _viewName = NSStringFromClass(_view.class);
                _viewContent = [element valueForKey:@"content"] ?: @"";
                _path = [element valueForKey:@"page"];
                _xpath = [element valueForKey:@"xpath"];
                if (_xpath.length == 0) {
                    _xpath = GrowingTKLocalizedString(@"当前SDK不支持此控件圈选");
                }
                _index = ((NSNumber *)[element valueForKey:@"index"]).intValue;
                _hasListParent = _index >= 0;
                
                // unused
                _originxpath = _xpath.copy;
                _nodeType = _viewName.copy;
                _position = 0;
            }
        }
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
        _viewContent = nodeDic[@"v"] ?: @"";
        _path = h5Path;
        _xpath = nodeDic[@"x"] ?: @"";
        _xcontent = nodeDic[@"xcontent"] ?: @"";
        if (nodeDic[@"idx"]) {
            _index = ((NSNumber *)nodeDic[@"idx"]).intValue;
            _hasListParent = YES;
        } else {
            _index = -1;
            _hasListParent = NO;
        }
        
        // unused
        _originxpath = _xpath.copy;
        _nodeType = nodeDic[@"nodeType"] ?: @"";
        _position = 0;
    }
    return self;
}

#pragma mark - Public Method

- (NSString *)toString {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"%@: %@", GrowingTKLocalizedString(@"当前"), self.viewName]];
    if (self.viewContent.length > 0) {
        [array addObject:[NSString stringWithFormat:@"%@: %@", GrowingTKLocalizedString(@"内容"), self.viewContent]];
    }
    if (self.hasListParent) {
        [array addObject:GrowingTKLocalizedString(@"列表: 是")];
    }
    if (self.index >= 0) {
        [array addObject:[NSString stringWithFormat:@"%@: %@", GrowingTKLocalizedString(@"位置"), @(self.index)]];
    }
    if (self.path && self.path.length > 0) {
        [array addObject:[NSString stringWithFormat:@"path: %@", self.path]];
    }
    [array addObject:[NSString stringWithFormat:@"xpath: %@", self.xpath]];
    if (GrowingTKSDKUtil.sharedInstance.isSDK4thGeneration) {
        [array addObject:[NSString stringWithFormat:@"xcontent: %@", self.xcontent]];
    }
    return [array componentsJoinedByString:@"\n"];
}

#pragma mark - Private Method

- (NSString *)pathForView:(UIView *)view {
    Class cls = NSClassFromString(@"GrowingPageManager");
    if (cls) {
        SEL selector = NSSelectorFromString(@"sharedInstance");
        if ([cls respondsToSelector:selector]) {
            id pageManager = ((id(*)(id, SEL))objc_msgSend)(cls, selector);
            if (pageManager) {
                SEL selector2 = NSSelectorFromString(@"findPageByView:");
                if ([pageManager respondsToSelector:selector2]) {
                    id page = ((id(*)(id, SEL, UIView *))objc_msgSend)(pageManager, selector2, view);
                    if (!page) {
                        SEL selector3 = NSSelectorFromString(@"currentPage");
                        if ([pageManager respondsToSelector:selector3]) {
                            page = ((id(*)(id, SEL))objc_msgSend)(pageManager, selector3);
                        }
                    }
                    if (page) {
                        if (GrowingTKSDKUtil.sharedInstance.isSDK4thGeneration) {
                            SEL selector4 = GrowingTKSDKUtil.sharedInstance.isSDK4thGeneration ? NSSelectorFromString(@"alias")
                                                                                               : NSSelectorFromString(@"path");
                            if ([page respondsToSelector:selector4]) {
                                NSString *alias = ((NSString * (*)(id, SEL)) objc_msgSend)(page, selector4);
                                return alias ?: @"";
                            }
                        }
                    }
                }
            }
        }
    }
    return @"";
}

@end
