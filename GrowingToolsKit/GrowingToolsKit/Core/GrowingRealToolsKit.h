//
//  GrowingRealToolsKit.h
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/10/8.
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrowingRealToolsKit : NSObject

/// 启动GrowingToolsKit
+ (void)start;

/// 启动GrowingToolsKit
/// @param position 入口位置
/// @param autoDock 是否自动停靠，默认为YES
+ (void)startWithPosition:(CGPoint)position autoDock:(BOOL)autoDock;

@end

NS_ASSUME_NONNULL_END

