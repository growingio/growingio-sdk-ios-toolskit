//
//  GrowingTKEventDetailViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/13.
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

#import "GrowingTKEventDetailViewController.h"
#import "GrowingTKCopyTextView.h"
#import "GrowingTKEventPersistence.h"
#import "UIImage+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKEventDetailViewController ()

@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) GrowingTKCopyTextView *textView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation GrowingTKEventDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.typeLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.textView];

    CGFloat margin = 12.0f;
    CGFloat closeButtonSideLength = 30.0f;
    [NSLayoutConstraint activateConstraints:@[
        [self.typeLabel.centerYAnchor constraintEqualToAnchor:self.closeButton.centerYAnchor],
        [self.typeLabel.leadingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor
                                                     constant:margin * 1.5],
        [self.closeButton.topAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.topAnchor
                                                   constant:margin],
        [self.closeButton.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor
                                                        constant:-margin],
        [self.closeButton.widthAnchor constraintEqualToConstant:closeButtonSideLength],
        [self.closeButton.heightAnchor constraintEqualToConstant:closeButtonSideLength],
        [self.textView.topAnchor constraintEqualToAnchor:self.closeButton.bottomAnchor constant:margin],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor
                                                    constant:margin],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];

    self.typeLabel.text = [self.event.eventType uppercaseString];
    self.textView.attributedText = self.beautifulJsonString;
}

#pragma mark - Private Method

- (UIColor *)punctuationColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#495560"];
            } else {
                return [UIColor growingtk_colorWithHex:@"#D4D4D4"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#495560"];
}

- (UIColor *)keyColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#92288F"];
            } else {
                return [UIColor growingtk_colorWithHex:@"#9ADBFF"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#92288F"];
}

- (UIColor *)stringColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#49BA57"];
            } else {
                return [UIColor growingtk_colorWithHex:@"#D09176"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#49BA57"];
}

- (UIColor *)numberColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor growingtk_colorWithHex:@"#25AAE2"];
            } else {
                return [UIColor growingtk_colorWithHex:@"#B3CCA5"];
            }
        }];
    }
    return [UIColor growingtk_colorWithHex:@"#25AAE2"];
}

- (NSAttributedString *)beautifulJsonString {
    if (self.event.rawJsonString.length == 0) {
        return [[NSAttributedString alloc] init];
    }

    NSData *jsonData = [self.event.rawJsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if (![NSJSONSerialization isValidJSONObject:jsonObject]) {
        return [[NSAttributedString alloc] init];
    }

    if (![jsonObject isKindOfClass:[NSDictionary class]]) {
        return [[NSAttributedString alloc] init];
    }
    
    NSDictionary *dic = (NSDictionary *)jsonObject;
    return [self createStringFromDic:dic attributeIndent:20.0f closingBraceIndent:0.0f];
}

- (NSAttributedString *)createStringFromDic:(NSDictionary *)dic
                            attributeIndent:(CGFloat)attributeIndent
                         closingBraceIndent:(CGFloat)closingBraceIndent {
    typedef NSMutableAttributedString * (^CreateStringBlock)(NSString *, NSDictionary<NSAttributedStringKey, id> *);
    CreateStringBlock createString = ^(NSString *string, NSDictionary<NSAttributedStringKey, id> *attributes) {
        return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    };
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0f;
    style.firstLineHeadIndent = attributeIndent > 0 ? attributeIndent : 20.0f;
    style.headIndent = 0.0f;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSDictionary<NSAttributedStringKey, id> *punctuationAttributes = @{
        NSForegroundColorAttributeName: self.punctuationColor,
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)]
    };
    NSDictionary<NSAttributedStringKey, id> *keyAttributes = @{
        NSForegroundColorAttributeName: self.keyColor,
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)],
        NSParagraphStyleAttributeName :style
    };
    NSDictionary<NSAttributedStringKey, id> *stringValueAttributes = @{
        NSForegroundColorAttributeName: self.stringColor,
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)]
    };
    NSDictionary<NSAttributedStringKey, id> *numberValueAttributes = @{
        NSForegroundColorAttributeName: self.numberColor,
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)]
    };
    
    NSMutableAttributedString *beautifulJsonString = [[NSMutableAttributedString alloc] init];
    
    [beautifulJsonString appendAttributedString:createString(@"{\n", punctuationAttributes)];
    for (NSString *key in dic.allKeys) {
        NSString *keyString = [NSString stringWithFormat:@"\"%@\"", key];
        [beautifulJsonString appendAttributedString:createString(keyString, keyAttributes)];

        [beautifulJsonString appendAttributedString:createString(@" : ", punctuationAttributes)];

        if ([dic[key] isKindOfClass:[NSDictionary class]]) {
            [beautifulJsonString appendAttributedString:[self createStringFromDic:(NSDictionary *)(dic[key])
                                                                  attributeIndent:attributeIndent + 20.0f
                                                               closingBraceIndent:attributeIndent]];
        } else if ([dic[key] isKindOfClass:[NSNumber class]]) {
            NSString *valueString = [NSString stringWithFormat:@"%@", dic[key]];
            [beautifulJsonString appendAttributedString:createString(valueString, numberValueAttributes)];
        } else {
            NSString *valueString = [NSString stringWithFormat:@"\"%@\"", dic[key]];
            [beautifulJsonString appendAttributedString:createString(valueString, stringValueAttributes)];
        }

        NSString *dotString = (key != dic.allKeys.lastObject) ? @",\n" : @"\n";
        [beautifulJsonString appendAttributedString:createString(dotString, punctuationAttributes)];
    }
    
    NSMutableParagraphStyle *closingBraceStyle = [[NSMutableParagraphStyle alloc] init];
    closingBraceStyle.lineSpacing = 5.0f;
    closingBraceStyle.firstLineHeadIndent = closingBraceIndent;
    closingBraceStyle.headIndent = 0.0f;
    closingBraceStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary<NSAttributedStringKey, id> *closingBraceAttributes = @{
        NSForegroundColorAttributeName: self.punctuationColor,
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)],
        NSParagraphStyleAttributeName :closingBraceStyle
    };
    [beautifulJsonString appendAttributedString:createString(@"}", closingBraceAttributes)];
    
    return beautifulJsonString;
}

#pragma mark - Action

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter & Setter

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(40) weight:UIFontWeightSemibold];
        _typeLabel.textColor = UIColor.growingtk_primaryBackgroundColor;
        _typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _typeLabel;
}

- (GrowingTKCopyTextView *)textView {
    if (!_textView) {
        _textView = [[GrowingTKCopyTextView alloc] initWithFrame:CGRectZero];
        _textView.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
        _textView.textColor = UIColor.growingtk_labelColor;
        _textView.backgroundColor = UIColor.clearColor;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _textView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeButton setBackgroundImage:[UIImage growingtk_imageNamed:@"growingtk_close"]
                                forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
