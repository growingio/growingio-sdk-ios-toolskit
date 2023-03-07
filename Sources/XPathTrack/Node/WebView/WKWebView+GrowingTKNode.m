//
//  WKWebView+GrowingTKNode.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/23.
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

#import "WKWebView+GrowingTKNode.h"
#import "GrowingTKDefine.h"
#import "GrowingTKHybridJS.h"
#import "GrowingTKSDKUtil.h"
#import "GrowingTKViewNode.h"
#import "NSObject+GrowingTKSwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const GrowingTKWebViewNodeInfoNotification = @"GrowingTKWebViewNodeInfoNotification";
static NSString *const GrowingTKWebViewBridge = @"GrowingToolsKit_WKWebView";

@interface GrowingTKPrivateScriptMessageHandler : NSObject <WKScriptMessageHandler>

+ (instancetype)sharedInstance;

@end

@interface WKWebView (GrowingTKNode)

@property (nonatomic, assign) BOOL growingtk_hybrid;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation WKWebView (GrowingTKNode)

#pragma mark - Hook Method

static void _growingtk_nodeUpdateMask(WKWebView *self, SEL _cmd, BOOL shouldMask, CGPoint point) {
    if (shouldMask) {
        point = [self.window convertPoint:point toView:self];
        // http://stackoverflow.com/questions/27159931/uiwebbrowserview-does-not-span-entire-uiwebview
        point.y -= self.scrollView.contentInset.top;
        if (@available(iOS 11.0, *)) {
            point.y -= self.scrollView.safeAreaInsets.top;
        }

        NSString *js = [NSString stringWithFormat:@"_gio_hybrid.hoverOn(%lf, %lf);", point.x, point.y];
        js = [NSString stringWithFormat:@"try { %@ } catch (e) { }", js];
        [self evaluateJavaScript:js completionHandler:nil];
    } else {
        NSString *js = @"_gio_hybrid.cancelHover();";
        js = [NSString stringWithFormat:@"try { %@ } catch (e) { }", js];
        [self evaluateJavaScript:js completionHandler:nil];
    }
}

static void _growingtk_nodeUpdateInfo(WKWebView *self, SEL _cmd) {
    NSString *js = [NSString stringWithFormat:@"_gio_hybrid.findElementAtPoint('');"];
    js = [NSString stringWithFormat:@"try { %@ } catch (e) { }", js];
    [self evaluateJavaScript:js completionHandler:nil];
}

static void growingtk_webView_addScriptMessageHandler(WKUserContentController *contentController) {
    GrowingTKPrivateScriptMessageHandler *scriptMessageHandler = [GrowingTKPrivateScriptMessageHandler sharedInstance];
    [contentController removeScriptMessageHandlerForName:GrowingTKWebViewBridge];
    [contentController addScriptMessageHandler:scriptMessageHandler name:GrowingTKWebViewBridge];
}

static void growingtk_webView_addUserScripts(WKUserContentController *contentController) {
    @try {
        NSArray<WKUserScript *> *userScripts = contentController.userScripts;

        __block BOOL isContainCircleScript = NO;
        [userScripts enumerateObjectsUsingBlock:^(WKUserScript *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj.source containsString:@"start circle"]) {
                isContainCircleScript = YES;
                *stop = YES;
            }
        }];
        if (!isContainCircleScript) {
            [contentController addUserScript:[[WKUserScript alloc] initWithSource:[GrowingTKHybridJS hybridJSCircleScript]
                                                                    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                                 forMainFrameOnly:NO]];
        }
    } @catch (NSException *exception) {
    }
}

static BOOL growingtk_webView_addBridge(WKWebView *webView) {
    if (NSClassFromString(@"GrowingTouchPopupManager")
        && [NSStringFromClass(webView.class) isEqualToString:@"GrowingTouchPopupWebView"]) {
        return NO;
    }
    
    if (GrowingTKSDKUtil.sharedInstance.isSDKAutoTrack) {
        SEL sel = GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration ? NSSelectorFromString(@"growingViewDontTrack")
                                                                     : NSSelectorFromString(@"growingAttributesDonotTrack");
        BOOL dontTrack = ((BOOL(*)(id, SEL))objc_msgSend)(webView, sel);
        if (dontTrack) {
            return NO;
        }
    }

    WKUserContentController *contentController = webView.configuration.userContentController;
    growingtk_webView_addScriptMessageHandler(contentController);
    growingtk_webView_addUserScripts(contentController);
    return YES;
}

- (WKNavigation *)growingtk_loadRequest:(NSURLRequest *)request {
    self.growingtk_hybrid = growingtk_webView_addBridge(self);
    return [self growingtk_loadRequest:request];
}

- (WKNavigation *)growingtk_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    self.growingtk_hybrid = growingtk_webView_addBridge(self);
    return [self growingtk_loadHTMLString:string baseURL:baseURL];
}

- (WKNavigation *)growingtk_loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    self.growingtk_hybrid = growingtk_webView_addBridge(self);
    return [self growingtk_loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

- (WKNavigation *)growingtk_loadData:(NSData *)data
                            MIMEType:(NSString *)MIMEType
               characterEncodingName:(NSString *)characterEncodingName
                             baseURL:(NSURL *)baseURL {
    self.growingtk_hybrid = growingtk_webView_addBridge(self);
    return [self growingtk_loadData:data MIMEType:MIMEType characterEncodingName:characterEncodingName baseURL:baseURL];
}

#pragma mark - Load

+ (void)load {
    if (![GrowingTKUseInRelease activeOrNot]) {
        return;
    }
    Class cls = self.class;

    class_addMethod(cls, @selector(growingtk_nodeUpdateMask:point:), (IMP)_growingtk_nodeUpdateMask, "v@:B{");
    class_addMethod(cls, @selector(growingtk_nodeUpdateInfo), (IMP)_growingtk_nodeUpdateInfo, "v@:");

    [cls growingtk_swizzleMethod:@selector(loadRequest:) withMethod:@selector(growingtk_loadRequest:) error:nil];
    [cls growingtk_swizzleMethod:@selector(loadHTMLString:baseURL:)
                      withMethod:@selector(growingtk_loadHTMLString:baseURL:)
                           error:nil];
    [cls growingtk_swizzleMethod:@selector(loadFileURL:allowingReadAccessToURL:)
                      withMethod:@selector(growingtk_loadFileURL:allowingReadAccessToURL:)
                           error:nil];
    [cls growingtk_swizzleMethod:@selector(loadData:MIMEType:characterEncodingName:baseURL:)
                      withMethod:@selector(growingtk_loadData:MIMEType:characterEncodingName:baseURL:)
                           error:nil];
}

- (void)setGrowingtk_hybrid:(BOOL)growingtk_hybrid {
    objc_setAssociatedObject(self, @selector(growingtk_hybrid), @(growingtk_hybrid), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)growingtk_hybrid {
    return ((NSNumber *)objc_getAssociatedObject(self, _cmd)).boolValue;
}

@end

@implementation GrowingTKPrivateScriptMessageHandler

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:GrowingTKWebViewBridge]) {
        NSData *jsonData = [message.body dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        if (![NSJSONSerialization isValidJSONObject:jsonObject]) {
            return;
        }

        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            return;
        }

        NSDictionary *dic = (NSDictionary *)jsonObject;
        NSString *type = dic[@"t"];
        if (![type isEqualToString:@"snap"]) {
            return;
        }

        NSArray *array = dic[@"e"];
        NSString *domain = dic[@"d"] ?: @"";
        NSString *h5Path = dic[@"p"] ?: @"";
        GrowingTKViewNode *node = [[GrowingTKViewNode alloc] initWithH5Node:array.firstObject
                                                                    webView:message.webView
                                                                     domain:domain
                                                                     h5Path:h5Path];

        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKWebViewNodeInfoNotification
                                                            object:nil
                                                          userInfo:@{@"info": node.toString}];
    }
}

@end

#pragma clang diagnostic pop
