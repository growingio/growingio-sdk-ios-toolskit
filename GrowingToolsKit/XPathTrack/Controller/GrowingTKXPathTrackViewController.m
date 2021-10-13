//
//  GrowingTKXPathTrackViewController.m
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

#import "GrowingTKXPathTrackViewController.h"
#import "GrowingTKXPathTrackPlugin.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "UIView+GrowingTK.h"
#import "GrowingTKNodeHelper.h"
#import "GrowingTKViewNode.h"
#import "GrowingTKUtil.h"
#import "GrowingTKNode.h"
#import "WKWebView+GrowingTKNode.h"
#import "GrowingTKMagnifierView.h"

static CGFloat const kInfoViewMargin = 24.0f;
#define CIRCLE_SIZE GrowingTKSizeFrom750(100)
#define MASK_BORDER_COLOR [UIColor growingtk_colorWithHex:@"0xFF4824" alpha:0.9f]
#define MASK_BACKGROUND_COLOR [UIColor growingtk_colorWithHex:@"0xFF4824" alpha:0.3f]

@interface GrowingTKXPathTrackViewController ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) GrowingTKMagnifierView *magnifierView;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) NSLayoutConstraint *infoViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *infoViewLeadingConstraint;
@property (nonatomic, assign) BOOL resetInfoViewConstraintsAfterKeyBoardHide;

@property (nonatomic, strong) UIView *latestMaskedView;

@end

@implementation GrowingTKXPathTrackViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewNodeInfoNotification:)
                                                 name:GrowingTKWebViewNodeInfoNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.circleView.center = self.view.center;
    });
}

#pragma mark - Private Method

- (void)initUI {
    self.view.backgroundColor = UIColor.clearColor;

    [self.view addSubview:self.infoView];
    [self.infoView addSubview:self.closeBtn];
    [self.infoView addSubview:self.infoLabel];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.circleView];

    CGFloat infoViewMargin = GrowingTKSizeFrom750(kInfoViewMargin);
    self.infoViewBottomConstraint = [self.infoView.bottomAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.bottomAnchor
                                                                            constant:-infoViewMargin];
    self.infoViewLeadingConstraint = [self.infoView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                                                 constant:infoViewMargin];

    [NSLayoutConstraint activateConstraints:@[
        self.infoViewBottomConstraint,
        self.infoViewLeadingConstraint,
        [self.infoView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-infoViewMargin * 2],
    ]];

    CGFloat closeBtnMargin = GrowingTKSizeFrom750(12);
    CGFloat closeBtnSideLength = GrowingTKSizeFrom750(44);
    [NSLayoutConstraint activateConstraints:@[
        [self.closeBtn.topAnchor constraintEqualToAnchor:self.infoView.topAnchor constant:closeBtnMargin],
        [self.closeBtn.trailingAnchor constraintEqualToAnchor:self.infoView.trailingAnchor constant:-closeBtnMargin],
        [self.closeBtn.heightAnchor constraintEqualToConstant:closeBtnSideLength],
        [self.closeBtn.widthAnchor constraintEqualToConstant:closeBtnSideLength]
    ]];

    CGFloat infoLabelMargin = GrowingTKSizeFrom750(24);
    [NSLayoutConstraint activateConstraints:@[
        [self.infoLabel.topAnchor constraintEqualToAnchor:self.infoView.topAnchor constant:infoLabelMargin],
        [self.infoLabel.bottomAnchor constraintEqualToAnchor:self.infoView.bottomAnchor constant:-infoLabelMargin],
        [self.infoLabel.leadingAnchor constraintEqualToAnchor:self.infoView.leadingAnchor constant:infoLabelMargin],
        [self.infoLabel.trailingAnchor constraintEqualToAnchor:self.infoView.trailingAnchor constant:-infoLabelMargin]
    ]];
}

- (void)reset {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat infoViewMargin = GrowingTKSizeFrom750(kInfoViewMargin);
        self.infoViewBottomConstraint.constant = -infoViewMargin;
        self.infoViewLeadingConstraint.constant = infoViewMargin;
        
        [self resetInfoLabelText:@"请拖动中间的圆点选择控件"];
        self.circleView.center = self.view.center;
        self.maskView.frame = CGRectZero;
    });
}

- (void)resetCircleViewFrame {
    CGFloat circleSize = CIRCLE_SIZE;
    CGFloat padding = GrowingTKSizeFrom750(6);
    CGRect bounds = self.view.bounds;
    CGRect frame = self.circleView.frame;

    frame.origin.x = MAX(bounds.origin.x + padding, frame.origin.x);
    frame.origin.y = MAX(bounds.origin.y + padding, frame.origin.y);
    frame.origin.x = MIN(bounds.origin.x + bounds.size.width - padding - circleSize, frame.origin.x);
    frame.origin.y = MIN(bounds.origin.y + bounds.size.height - padding - circleSize, frame.origin.y);

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.circleView.frame = frame;
                     }];
    
}

- (void)resetInfoLabelText:(NSString *)text {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = GrowingTKSizeFrom750(8);
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSMutableAttributedString *attrString =
        [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName: style}];
    self.infoLabel.attributedText = attrString;
}

- (void)updateMask:(UIView *)view {
    if (!view) {
        self.maskView.frame = CGRectZero;
        if ([self.latestMaskedView isKindOfClass:[WKWebView class]]
            && ((id<GrowingTKNode>)self.latestMaskedView).growingtk_hybrid) {
            WKWebView *webView = (WKWebView *)self.latestMaskedView;
            [webView growingtk_nodeUpdateMask:NO point:CGPointZero];
        }
        self.latestMaskedView = nil;
        [self removeMagnifier];
        return;
    }
    
    self.latestMaskedView = view;
    id <GrowingTKNode>node = (id<GrowingTKNode>)view;
    UIColor * borderColor = MASK_BORDER_COLOR;
    UIColor * backgroundColor = MASK_BACKGROUND_COLOR;

    if ([node isKindOfClass:[WKWebView class]] && node.growingtk_hybrid) {
        // WebView
        WKWebView *webView = (WKWebView *)node;
        [webView growingtk_nodeUpdateMask:YES point:self.circleView.center];
    }else {
        self.maskView.frame = node.growingNodeFrame;
        self.maskView.layer.borderColor = borderColor.CGColor;
        self.maskView.backgroundColor = backgroundColor;
        [self showMagnifierWithView:view point:self.circleView.center];
    }
}

- (void)showMagnifierWithView:(UIView *)view point:(CGPoint)point {
    if (!self.magnifierView) {
        self.magnifierView = [[GrowingTKMagnifierView alloc] initWithView:view point:point];
        [self.view addSubview:self.magnifierView];
    }else {
        [self.magnifierView refreshWithView:view point:point];
    }
}

- (void)removeMagnifier {
    self.magnifierView.frame = CGRectZero;
}

#pragma mark - Action

- (void)circleViewPan:(UIPanGestureRecognizer *)sender {
    UIView *panView = sender.view;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            self.circleView.alpha = 0.2f;
        } break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [sender translationInView:panView];
            [sender setTranslation:CGPointZero inView:panView];
            panView.center = CGPointMake(panView.center.x + translation.x, panView.center.y + translation.y);
            
            UIView *view = [GrowingTKUtil.keyWindow hitTest:panView.center withEvent:nil];
            view = [GrowingTKNodeHelper realHitView:view point:panView.center];

            if (view) {
                [self updateMask:view];
            }else {
                [self updateMask:nil];
            }
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (self.latestMaskedView) {
                if ([self.latestMaskedView isKindOfClass:[WKWebView class]]
                    && ((id<GrowingTKNode>)self.latestMaskedView).growingtk_hybrid) {
                    WKWebView *webView = (WKWebView *)self.latestMaskedView;
                    [webView growingtk_nodeUpdateInfo];
                }else {
                    GrowingTKViewNode *node = [[GrowingTKViewNode alloc] initWithView:self.latestMaskedView];
                    [self resetInfoLabelText:node.toString];
                }
            }
            
            [self resetCircleViewFrame];
            self.circleView.alpha = 1.0f;
            [self updateMask:nil];
        }

        default:
            break;
    }
}

- (void)infoViewPan:(UIPanGestureRecognizer *)sender {
    UIView *panView = sender.view;

    if (!panView.hidden) {
        CGPoint offsetPoint = [sender translationInView:panView];
        [sender setTranslation:CGPointZero inView:panView];
        self.infoViewLeadingConstraint.constant += offsetPoint.x;
        self.infoViewBottomConstraint.constant += offsetPoint.y;
        [self.infoView setNeedsUpdateConstraints];
    }
}

- (void)closeButtonAction:(UIButton *)sender {
    [GrowingTKXPathTrackPlugin.plugin hideTrackView];
}

#pragma mark - Notification

- (void)webViewNodeInfoNotification:(NSNotification *)not {
    NSString *info = not.userInfo[@"info"];
    [self resetInfoLabelText:info];
}

- (void)keyboardWillShow:(NSNotification *)not {
    CGRect keyBoardFrame = [[not userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect viewFrame = [self.infoView convertRect:self.infoView.bounds toView:self.infoView.window];
    
    if (CGRectIntersectsRect(keyBoardFrame, viewFrame)) {
        CGFloat infoViewMargin = GrowingTKSizeFrom750(kInfoViewMargin);
        CGFloat keyBoardHeight = [[not userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        self.infoViewLeadingConstraint.constant = infoViewMargin;
        self.infoViewBottomConstraint.constant = -(keyBoardHeight + infoViewMargin - self.view.growingtk_safeAreaInsets.bottom);
        [self.infoView setNeedsUpdateConstraints];
        
        CGFloat duration = [[not userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
        
        self.resetInfoViewConstraintsAfterKeyBoardHide = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)not {
    if (!self.resetInfoViewConstraintsAfterKeyBoardHide) {
        return;
    }
    self.resetInfoViewConstraintsAfterKeyBoardHide = NO;
    
    CGFloat infoViewMargin = GrowingTKSizeFrom750(kInfoViewMargin);
    self.infoViewLeadingConstraint.constant = infoViewMargin;
    self.infoViewBottomConstraint.constant = -infoViewMargin;
    [self.infoView setNeedsUpdateConstraints];
    
    CGFloat duration = [[not userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Getter & Setter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.layer.borderWidth = 1;
        _maskView.layer.borderColor = MASK_BORDER_COLOR.CGColor;
        _maskView.backgroundColor = MASK_BACKGROUND_COLOR;
        _maskView.layer.cornerRadius = 5.0f;
        _maskView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _maskView;
}

- (UIView *)circleView {
    if (!_circleView) {
        CGFloat circleSize = CIRCLE_SIZE;
        CGFloat padding = GrowingTKSizeFrom750(12);
        CGFloat contentSize = CIRCLE_SIZE - padding * 2;
        _circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, circleSize, circleSize)];
        _circleView.layer.cornerRadius = circleSize / 2.0f;
        _circleView.backgroundColor = [UIColor growingtk_colorWithHex:@"FF4824" alpha:0.3f];

        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(padding, padding, contentSize, contentSize)];
        contentView.layer.cornerRadius = contentSize / 2.0f;
        contentView.backgroundColor = [UIColor growingtk_primaryBackgroundColor];
        [_circleView addSubview:contentView];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(circleViewPan:)];
        [_circleView addGestureRecognizer:pan];
    }
    return _circleView;
}

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [[UIView alloc] initWithFrame:CGRectZero];
        _infoView.backgroundColor = [UIColor growingtk_colorWithHex:@"0x000000" alpha:0.5f];
        _infoView.layer.cornerRadius = GrowingTKSizeFrom750(8);
        _infoView.layer.borderWidth = 1.0f;
        _infoView.layer.borderColor = [UIColor growingtk_colorWithHex:@"0x999999" alpha:0.2].CGColor;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(infoViewPan:)];
        [_infoView addGestureRecognizer:pan];
        _infoView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _infoView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_closeBtn setBackgroundImage:[UIImage growingtk_imageNamed:@"growingtk_close_gray"]
                             forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _closeBtn;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        _infoLabel.numberOfLines = 0;
        _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _infoLabel;
}

@end
