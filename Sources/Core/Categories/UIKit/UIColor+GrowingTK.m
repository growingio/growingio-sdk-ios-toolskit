//
//  UIColor+GrowingTK.m
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

#import "UIColor+GrowingTK.h"

@implementation UIColor (GrowingTK)

+ (UIColor *)growingtk_colorWithHex:(NSString *)hex {
    return [self growingtk_colorWithHex:hex alpha:1.0f];
}

+ (UIColor *)growingtk_colorWithHex:(NSString *)hex alpha:(CGFloat)alpha {
    hex = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    if (hex.length < 6) {
        return UIColor.clearColor;
    }
    if ([hex hasPrefix:@"0X"]) {
        hex = [hex substringFromIndex:2];
    }
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringFromIndex:1];
    }
    if (hex.length != 6) {
        return UIColor.clearColor;
    }

    NSRange range = NSMakeRange(0, 2);
    NSString *rString = [hex substringWithRange:range];
    range.location = 2;
    NSString *gString = [hex substringWithRange:range];
    range.location = 4;
    NSString *bString = [hex substringWithRange:range];

    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

+ (UIColor *)growingtk_primaryBackgroundColor {
    return [UIColor growingtk_colorWithHex:@"#FC5F3A"];
}

+ (UIColor *)growingtk_secondaryBackgroundColor {
    return [UIColor growingtk_colorWithHex:@"#FF9167"];
}

+ (UIColor *)growingtk_tertiaryBackgroundColor {
    return [UIColor growingtk_colorWithHex:@"#C22A0D"];
}

+ (UIColor *)growingtk_black_alpha {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#000000" alpha:0.9f];
            } else {
                return [UIColor growingtk_colorWithHex:@"#FFFFFF" alpha:0.9f];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#2C2C2E"];
}

+ (UIColor *)growingtk_black_1 {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#333333"];
            } else {
                return [UIColor growingtk_colorWithHex:@"#DDDDDD"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#333333"];
}

+ (UIColor *)growingtk_black_2 {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#666666"];
            } else {
                return [UIColor growingtk_colorWithHex:@"#AAAAAA"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#666666"];
}

+ (UIColor *)growingtk_black_3 {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#999999"];
            } else {
                return [UIColor growingtk_colorWithHex:@"#666666"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#999999"];
}

+ (UIColor *)growingtk_labelColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.labelColor;
    }
    return UIColor.blackColor;
}

+ (UIColor *)growingtk_secondaryLabelColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.secondaryLabelColor;
    }
    return UIColor.grayColor;
}

+ (UIColor *)growingtk_white_1 {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return UIColor.whiteColor;
            } else {
                return [UIColor growingtk_colorWithHex:@"#232323"];
            }
        }];
    }
    return UIColor.whiteColor;
}

+ (UIColor *)growingtk_white_2 {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return UIColor.secondarySystemBackgroundColor;
            } else {
                return [UIColor growingtk_colorWithHex:@"#181818"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"F2F2F7"];
}

+ (UIColor *)growingtk_bg_1 {
    if (@available(iOS 13.0, *)) {
        return UIColor.tertiarySystemBackgroundColor;
    }
    return UIColor.whiteColor;
}

+ (UIColor *)growingtk_bg_2 {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#F4F5F6"];
            } else {
                return [UIColor growingtk_colorWithHex:@"#353537"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#F4F5F6"];
}

+ (UIColor *)growingtk_randomColor {
    CGFloat red = (arc4random() % 255 / 255.0);
    CGFloat green = (arc4random() % 255 / 255.0);
    CGFloat blue = (arc4random() % 255 / 255.0);
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
