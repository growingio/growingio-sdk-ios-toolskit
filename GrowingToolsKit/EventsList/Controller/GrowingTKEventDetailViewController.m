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
#import "GrowingTKEventPersistence.h"
#import "UIImage+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKEventDetailViewController ()

@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UITextView *textView;
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
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.bottomAnchor],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.leadingAnchor
                                                    constant:margin],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor]
    ]];

    self.typeLabel.text = [self.event.eventType uppercaseString];
    self.textView.attributedText = self.beautifulJsonString;
}

#pragma mark - Private Method

- (NSAttributedString *)beautifulJsonString {
    NSMutableAttributedString *beautifulJsonString = [[NSMutableAttributedString alloc] init];
    if (self.event.rawJsonString.length == 0) {
        return beautifulJsonString;
    }

    NSData *jsonData = [self.event.rawJsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if (![NSJSONSerialization isValidJSONObject:jsonObject]) {
        return beautifulJsonString;
    }

    if (![jsonObject isKindOfClass:[NSDictionary class]]) {
        return beautifulJsonString;
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0f;
    style.firstLineHeadIndent = 20.0f;
    style.headIndent = 0.0f;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSDictionary *dic = (NSDictionary *)jsonObject;
    NSDictionary<NSAttributedStringKey, id> *punctuationAttributes = @{
        NSForegroundColorAttributeName: [UIColor growingtk_colorWithHex:@"#495560"],
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)]
    };
    NSDictionary<NSAttributedStringKey, id> *keyAttributes = @{
        NSForegroundColorAttributeName: [UIColor growingtk_colorWithHex:@"#92288F"],
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)],
        NSParagraphStyleAttributeName :style
    };
    NSDictionary<NSAttributedStringKey, id> *stringValueAttributes = @{
        NSForegroundColorAttributeName: [UIColor growingtk_colorWithHex:@"#49BA57"],
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)]
    };
    NSDictionary<NSAttributedStringKey, id> *numberValueAttributes = @{
        NSForegroundColorAttributeName: [UIColor growingtk_colorWithHex:@"#25AAE2"],
        NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)]
    };

    typedef NSMutableAttributedString * (^CreateStringBlock)(NSString *, NSDictionary<NSAttributedStringKey, id> *);
    CreateStringBlock createString = ^(NSString *string, NSDictionary<NSAttributedStringKey, id> *attributes) {
        return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    };

    [beautifulJsonString appendAttributedString:createString(@"{\n", punctuationAttributes)];
    for (NSString *key in dic.allKeys) {
        NSString *keyString = [NSString stringWithFormat:@"\"%@\"", key];
        [beautifulJsonString appendAttributedString:createString(keyString, keyAttributes)];

        [beautifulJsonString appendAttributedString:createString(@":", punctuationAttributes)];

        NSString *valueString = [dic[key] isKindOfClass:[NSNumber class]]
                                    ? [NSString stringWithFormat:@"%@", dic[key]]
                                    : [NSString stringWithFormat:@"\"%@\"", dic[key]];
        NSDictionary<NSAttributedStringKey, id> *valueAttributes =
            [dic[key] isKindOfClass:[NSNumber class]] ? numberValueAttributes : stringValueAttributes;
        [beautifulJsonString appendAttributedString:createString(valueString, valueAttributes)];

        NSString *dotString = (key != dic.allKeys.lastObject) ? @",\n" : @"\n";
        [beautifulJsonString appendAttributedString:createString(dotString, punctuationAttributes)];
    }
    [beautifulJsonString appendAttributedString:createString(@"}", punctuationAttributes)];
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

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(32)];
        _textView.textColor = UIColor.growingtk_labelColor;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _textView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeButton setBackgroundImage:[UIImage growingtk_imageNamed:@"growingtk_close_orange"]
                                forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
