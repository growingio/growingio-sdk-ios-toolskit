//
//  GrowingTKEventTrackViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/16.
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

#import "GrowingTKEventTrackViewController.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKEventTrackViewController ()

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation GrowingTKEventTrackViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor growingtk_colorWithHex:@"54545899"];

    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize viewSize = self.view.window.bounds.size;

        CGFloat closeWidth = GrowingTKSizeFrom750(44);
        CGFloat closeHeight = GrowingTKSizeFrom750(44);
        self.closeBtn =
            [[UIButton alloc] initWithFrame:CGRectMake(viewSize.width - closeWidth - GrowingTKSizeFrom750(16),
                                                       GrowingTKSizeFrom750(16),
                                                       closeWidth,
                                                       closeHeight)];
        [self.closeBtn setBackgroundImage:self.closeBtnImage forState:UIControlStateNormal];
        [self.closeBtn addTarget:self
                          action:@selector(closeButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.closeBtn];

        self.infoLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(GrowingTKSizeFrom750(32),
                                                      0,
                                                      viewSize.width - GrowingTKSizeFrom750(32 + 16) - closeWidth,
                                                      viewSize.height)];
        self.infoLabel.backgroundColor = [UIColor clearColor];
        self.infoLabel.textColor = [UIColor growingtk_colorWithHex:@"EBEBF599"];
        self.infoLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        self.infoLabel.numberOfLines = 0;
        [self.view addSubview:self.infoLabel];

        NSString *string = @"测试测试测试测试测试\n测试测试测试测试测试\n测试测试测试测试测试\n测试测试测试测试测试\n测"
                           @"试测试测试测试测试\n测试测试测试测试测试\n";

        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineSpacing = GrowingTKSizeFrom750(12);

        style.lineBreakMode = NSLineBreakByTruncatingTail;

        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        [attrString addAttributes:@{
            NSParagraphStyleAttributeName: style,
            NSFontAttributeName: [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)],
            NSForegroundColorAttributeName: [UIColor growingtk_black_2]
        }
                            range:NSMakeRange(0, string.length)];
        self.infoLabel.attributedText = attrString;
    });
}

#pragma mark - Action

- (void)closeButtonAction:(UIButton *)sender {
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                   });
}

#pragma mark - Dark Mode

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self.closeBtn setImage:self.closeBtnImage forState:UIControlStateNormal];
        }
    }
}

- (UIImage *)closeBtnImage {
    if (@available(iOS 13.0, *)) {
        return UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
                   ? [UIImage growingtk_imageNamed:@"growingtk_close_gray"]
                   : [UIImage growingtk_imageNamed:@"growingtk_close_gray"];
    } else {
        return [UIImage growingtk_imageNamed:@"growingtk_close_gray"];
    }
}

@end
