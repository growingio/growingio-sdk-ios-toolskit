//
//  GrowingTKNode.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GrowingTKNode <NSObject>

@required

/// 原始父节点
- (id<GrowingTKNode> _Nullable)growingNodeParent;

/// 是否不进行track
- (BOOL)growingNodeDonotTrack;

/// 是否不进行圈选
- (BOOL)growingNodeDonotCircle;

/// 是否可交互
- (BOOL)growingNodeUserInteraction;

- (CGRect)growingNodeFrame;

- (NSString *_Nullable)growingNodeName;
- (NSString *_Nullable)growingNodeContent;

- (NSDictionary *_Nullable)growingNodeDataDict;

- (UIWindow *_Nullable)growingNodeWindow;

- (UIImage *_Nullable)growingNodeScreenShot:(UIImage *_Nullable)fullScreenImage;
- (UIImage *_Nullable)growingNodeScreenShotWithScale:(CGFloat)maxScale;

@optional

- (BOOL)growingtk_hybrid;

- (BOOL)growingImpNodeIsVisible;

@end

NS_ASSUME_NONNULL_END
