//
//  GrowingTKViewNode.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrowingTKViewNode : NSObject

@property (nonatomic, weak, readonly) UIView *view;
@property (nonatomic, copy, readonly) NSString *viewName;
@property (nonatomic, copy, readonly) NSString *viewContent;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *xpath;
@property (nonatomic, copy, readonly) NSString *xindex;
@property (nonatomic, copy, readonly) NSString *originxindex;
@property (nonatomic, copy, readonly) NSString *originxpath; // sdk 2.x
@property (nonatomic, copy, readonly) NSString *nodeType;
//如果有父节点，且父节点为列表，则index有值，和父节点一致，否则为-1
@property (nonatomic, assign, readonly) int index;
//视图在父节点的排序index，称之为position,例如UIView下的第一个UIButton,postion=0
@property (nonatomic, assign, readonly) int position;
@property (nonatomic, assign, readonly) BOOL hasListParent;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithView:(UIView *)view;

- (instancetype)initWithH5Node:(NSDictionary *)nodeDic
                       webView:(UIView *)webView
                        domain:(NSString *)domain
                        h5Path:(NSString *)h5Path;

- (NSString *)toString;

@end

NS_ASSUME_NONNULL_END
