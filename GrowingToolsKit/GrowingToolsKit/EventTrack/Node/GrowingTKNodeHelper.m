//
//  GrowingTKNodeHelper.m
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

#import "GrowingTKNodeHelper.h"
#import "GrowingTKNode.h"

@implementation GrowingTKNodeHelper

+ (BOOL)checkShouldMask:(UIView *)view {
    id <GrowingTKNode>node = (id <GrowingTKNode>)view;
    return ![self checkDoNotTrack:node] && ([self checkUserInteraction:node]);
}

+ (BOOL)checkDoNotTrack:(id<GrowingTKNode>)node {
    BOOL result = NO;
    
    if ([node respondsToSelector:@selector(growingNodeDonotTrack)]) {
        result = result || node.growingNodeDonotTrack;
    }
    
    if ([node respondsToSelector:@selector(growingNodeDonotCircle)]) {
        result = result || node.growingNodeDonotCircle;
    }
    
    return result;
}

+ (BOOL)checkUserInteraction:(id<GrowingTKNode>)node {
    if ([node isKindOfClass:NSClassFromString(@"WKWebView")]) {
        return YES;
    }
    
    if ([node respondsToSelector:@selector(growingNodeUserInteraction)]) {
        return node.growingNodeUserInteraction;
    }
    
    return NO;
}

@end
