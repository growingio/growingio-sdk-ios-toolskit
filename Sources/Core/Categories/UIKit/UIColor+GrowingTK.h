//
//  UIColor+GrowingTK.h
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/12.
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (GrowingTK)

+ (UIColor *)growingtk_colorWithHex:(NSString *)hex;
+ (UIColor *)growingtk_colorWithHex:(NSString *)hex alpha:(CGFloat)alpha;
+ (UIColor *)growingtk_primaryBackgroundColor;    //#FC5F3A
+ (UIColor *)growingtk_secondaryBackgroundColor;  //#FF9167
+ (UIColor *)growingtk_tertiaryBackgroundColor;   //#C22A0D
+ (UIColor *)growingtk_black_alpha;               //#000000 0.9
+ (UIColor *)growingtk_black_1;                   //#333333
+ (UIColor *)growingtk_black_2;                   //#666666
+ (UIColor *)growingtk_black_3;                   //#999999
+ (UIColor *)growingtk_labelColor;                // labelColor
+ (UIColor *)growingtk_secondaryLabelColor;       // secondaryLabelColor
+ (UIColor *)growingtk_white_1;                   // systemBackgroundColor
+ (UIColor *)growingtk_white_2;                   // secondarySystemBackgroundColor
+ (UIColor *)growingtk_bg_1;                      // tertiarySystemBackgroundColor
+ (UIColor *)growingtk_bg_2;                      //#F4F5F6
+ (UIColor *)growingtk_randomColor;

@end

NS_ASSUME_NONNULL_END
