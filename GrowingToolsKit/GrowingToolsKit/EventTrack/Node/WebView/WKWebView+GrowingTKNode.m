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
#import "WKWebView+GrowingTKHybridJS.h"
#import "GrowingTKSDKUtil.h"
#import "GrowingTKViewNode.h"
#import "NSObject+GrowingTKSwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const GrowingTKWebViewNodeInfoNotification = @"GrowingTKWebViewNodeInfoNotification";
static NSString *const GrowingTKWebViewBridge = @"GrowingToolsKit_WKWebView";

@interface GrowingTKPrivateScriptMessageHandler : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak, readonly) WKWebView *webView;

- (instancetype)initWithWKWebView:(WKWebView *)webView;

@end

@interface WKWebView (GrowingTKNode)

@property (nonatomic, assign) BOOL growingtk_hybrid;
@property (nonatomic, strong) GrowingTKPrivateScriptMessageHandler *growingtk_scriptMessageHandler;

@end

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

        NSString *js = [NSString stringWithFormat:@"_vds_hybrid.hoverOn(%lf, %lf);", point.x, point.y];
        js = [NSString stringWithFormat:@"try { %@ } catch (e) { }", js];
        [self evaluateJavaScript:js completionHandler:nil];
    } else {
        NSString *js = @"_vds_hybrid.cancelHover();";
        js = [NSString stringWithFormat:@"try { %@ } catch (e) { }", js];
        [self evaluateJavaScript:js completionHandler:nil];
    }
}

static void _growingtk_nodeUpdateInfo(WKWebView *self, SEL _cmd) {
    NSString *js = [NSString stringWithFormat:@"_vds_hybrid.findElementAtPoint('');"];
    js = [NSString stringWithFormat:@"try { %@ } catch (e) { }", js];
    [self evaluateJavaScript:js completionHandler:nil];
}

static void growingtk_webView_addScriptMessageHandler(WKWebView *webView) {
    GrowingTKPrivateScriptMessageHandler *scriptMessageHandler = webView.growingtk_scriptMessageHandler;
    if (!scriptMessageHandler) {
        return;
    }

    WKUserContentController *contentController = webView.configuration.userContentController;
    [contentController removeScriptMessageHandlerForName:GrowingTKWebViewBridge];
    [contentController addScriptMessageHandler:scriptMessageHandler name:GrowingTKWebViewBridge];
}

static void growingtk_webView_addUserScripts(WKWebView *webView) {
    @try {
        WKUserContentController *contentController = webView.configuration.userContentController;
        NSArray<WKUserScript *> *userScripts = contentController.userScripts;

        // Hybrid JS
        if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
            __block BOOL isContainHybridScript = NO;
            [userScripts enumerateObjectsUsingBlock:^(WKUserScript *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([obj.source containsString:@"_vds_ios"] || [obj.source containsString:@"_vds_hybrid_config"]
                    /*|| [obj.source containsString:@"gio_hybrid.min.js"]*/) {
                    isContainHybridScript = YES;
                }
            }];

            if (!isContainHybridScript) {
                [contentController
                    addUserScript:[[WKUserScript alloc] initWithSource:@"window._vds_ios = true;"
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                      forMainFrameOnly:NO]];

                [contentController
                    addUserScript:[[WKUserScript alloc] initWithSource:webView.growingtk_configHybridScript
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                      forMainFrameOnly:NO]];

                [contentController
                    addUserScript:[[WKUserScript alloc] initWithSource:webView.growingtk_hybridJSScript
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                      forMainFrameOnly:NO]];
            }
        }

        // Circle JS
        __block BOOL isContainCircleScript = NO;
        [userScripts enumerateObjectsUsingBlock:^(WKUserScript *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj.source containsString:@"start circle"]) {
                isContainCircleScript = YES;
            }
        }];
        if (!isContainCircleScript) {
            [contentController addUserScript:[[WKUserScript alloc] initWithSource:webView.growingtk_hybridJSCircleScript
                                                                    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                                 forMainFrameOnly:NO]];
        }
    } @catch (NSException *exception) {
    }
}

- (instancetype)growingtk_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    WKWebView *webview = [self growingtk_initWithFrame:frame configuration:configuration];
    webview.growingtk_scriptMessageHandler = [[GrowingTKPrivateScriptMessageHandler alloc] initWithWKWebView:webview];
    return webview;
}

- (WKNavigation *)growingtk_loadRequest:(NSURLRequest *)request {
    growingtk_webView_addScriptMessageHandler(self);
    growingtk_webView_addUserScripts(self);
    self.growingtk_hybrid = YES;
    return [self growingtk_loadRequest:request];
}

- (WKNavigation *)growingtk_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    growingtk_webView_addScriptMessageHandler(self);
    growingtk_webView_addUserScripts(self);
    self.growingtk_hybrid = YES;
    return [self growingtk_loadHTMLString:string baseURL:baseURL];
}

- (WKNavigation *)growingtk_loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    growingtk_webView_addScriptMessageHandler(self);
    growingtk_webView_addUserScripts(self);
    self.growingtk_hybrid = YES;
    return [self growingtk_loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

- (WKNavigation *)growingtk_loadData:(NSData *)data
                            MIMEType:(NSString *)MIMEType
               characterEncodingName:(NSString *)characterEncodingName
                             baseURL:(NSURL *)baseURL {
    growingtk_webView_addScriptMessageHandler(self);
    growingtk_webView_addUserScripts(self);
    self.growingtk_hybrid = YES;
    return [self growingtk_loadData:data MIMEType:MIMEType characterEncodingName:characterEncodingName baseURL:baseURL];
}

#pragma mark - Load

+ (void)load {
    Class cls = self.class;

    class_addMethod(cls, @selector(growingtk_nodeUpdateMask:point:), (IMP)_growingtk_nodeUpdateMask, "v@:B{");
    class_addMethod(cls, @selector(growingtk_nodeUpdateInfo), (IMP)_growingtk_nodeUpdateInfo, "v@:");

    if (GrowingTKSDKUtil.sharedInstance.isSDK3rdGeneration) {
        // *************** SDK 3.0 ***************
        [cls growingtk_swizzleMethod:@selector(initWithFrame:configuration:)
                          withMethod:@selector(growingtk_initWithFrame:configuration:)
                               error:nil];
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
        // *************** SDK 3.0 ***************
    } else {
        // *************** SDK 2.0 ***************

        // *************** SDK 2.0 ***************
    }
}

static void *const hybridKey = &hybridKey;
- (void)setGrowingtk_hybrid:(BOOL)growingtk_hybrid {
    objc_setAssociatedObject(self, hybridKey, @(growingtk_hybrid), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)growingtk_hybrid {
    return ((NSNumber *)objc_getAssociatedObject(self, hybridKey)).boolValue;
}

static void *const handlerKey = &handlerKey;
- (void)setGrowingtk_scriptMessageHandler:(GrowingTKPrivateScriptMessageHandler *)growingtk_scriptMessageHandler {
    objc_setAssociatedObject(self, handlerKey, growingtk_scriptMessageHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GrowingTKPrivateScriptMessageHandler *)growingtk_scriptMessageHandler {
    return objc_getAssociatedObject(self, handlerKey);
}

@end

@implementation GrowingTKPrivateScriptMessageHandler

- (instancetype)initWithWKWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
    }
    return self;
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
        NSString *h5Path = dic[@"p"] ?: @"";
        GrowingTKViewNode *node = [[GrowingTKViewNode alloc] initWithH5Node:array.firstObject
                                                                    webView:self.webView
                                                                     h5Path:h5Path];

        [[NSNotificationCenter defaultCenter] postNotificationName:GrowingTKWebViewNodeInfoNotification
                                                            object:nil
                                                          userInfo:@{@"info": node.toString}];
    }
}

@end
