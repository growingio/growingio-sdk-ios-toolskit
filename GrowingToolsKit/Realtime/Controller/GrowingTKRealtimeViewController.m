//
//  GrowingTKRealtimeViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/8/3.
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

#import "GrowingTKRealtimeViewController.h"
#import "GrowingTKRealtimePlugin.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"
#import "UIView+GrowingTK.h"

static CGFloat const kEventsViewMargin = 24.0f;
static CGFloat const kEventsViewHeight = 320.0f;
static CGFloat const kFullEventDetailMinWidth = 300.0f;

@interface GrowingTKRealtimeViewController ()

@property (nonatomic, strong) NSMutableArray <NSString *>*realtimeEventsArray;
@property (nonatomic, strong) UIView *eventsView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UITextView *eventsTextView;
@property (nonatomic, strong) UIImageView *dragView;

@property (nonatomic, assign, getter=isShowFullEventDetail) BOOL showFullEventDetail; // 是否显示详细的事件

@property (nonatomic, strong) NSLayoutConstraint *eventsViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *eventsViewLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *eventsViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *eventsViewWidthConstraint;
@property (nonatomic, assign) BOOL resetEventsViewConstraintsAfterKeyBoardHide;

@end

@implementation GrowingTKRealtimeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(realtimeEventNotification:)
                                                 name:GrowingTKRealtimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Private Method

- (void)initUI {
    self.view.backgroundColor = UIColor.clearColor;

    [self.view addSubview:self.eventsView];
    [self.eventsView addSubview:self.eventsTextView];
    [self.eventsView addSubview:self.closeBtn];
    [self.eventsView addSubview:self.dragView];

    CGFloat eventsViewMargin = GrowingTKSizeFrom750(kEventsViewMargin);
    CGFloat eventsViewHeight = GrowingTKSizeFrom750(kEventsViewHeight);
    self.eventsViewBottomConstraint = [self.eventsView.bottomAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.bottomAnchor
                                                                            constant:-eventsViewMargin];
    self.eventsViewLeadingConstraint = [self.eventsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                                                 constant:eventsViewMargin];
    self.eventsViewWidthConstraint = [self.eventsView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-eventsViewMargin * 2];
    self.eventsViewHeightConstraint = [self.eventsView.heightAnchor constraintEqualToConstant:eventsViewHeight];
    [NSLayoutConstraint activateConstraints:@[
        self.eventsViewBottomConstraint,
        self.eventsViewLeadingConstraint,
        self.eventsViewWidthConstraint,
        self.eventsViewHeightConstraint
    ]];

    CGFloat closeBtnMargin = GrowingTKSizeFrom750(12);
    CGFloat closeBtnSideLength = GrowingTKSizeFrom750(44);
    [NSLayoutConstraint activateConstraints:@[
        [self.closeBtn.topAnchor constraintEqualToAnchor:self.eventsView.topAnchor constant:closeBtnMargin],
        [self.closeBtn.trailingAnchor constraintEqualToAnchor:self.eventsView.trailingAnchor constant:-closeBtnMargin],
        [self.closeBtn.heightAnchor constraintEqualToConstant:closeBtnSideLength],
        [self.closeBtn.widthAnchor constraintEqualToConstant:closeBtnSideLength]
    ]];

    CGFloat eventsTextViewMargin = GrowingTKSizeFrom750(8);
    [NSLayoutConstraint activateConstraints:@[
        [self.eventsTextView.topAnchor constraintEqualToAnchor:self.eventsView.topAnchor constant:eventsTextViewMargin],
        [self.eventsTextView.bottomAnchor constraintEqualToAnchor:self.eventsView.bottomAnchor constant:-eventsTextViewMargin],
        [self.eventsTextView.leadingAnchor constraintEqualToAnchor:self.eventsView.leadingAnchor constant:eventsTextViewMargin],
        [self.eventsTextView.trailingAnchor constraintEqualToAnchor:self.eventsView.trailingAnchor constant:-eventsTextViewMargin]
    ]];
    
    CGFloat dragViewSideLength = GrowingTKSizeFrom750(60);
    [NSLayoutConstraint activateConstraints:@[
        [self.dragView.bottomAnchor constraintEqualToAnchor:self.eventsView.bottomAnchor],
        [self.dragView.trailingAnchor constraintEqualToAnchor:self.eventsView.trailingAnchor],
        [self.dragView.heightAnchor constraintEqualToConstant:dragViewSideLength],
        [self.dragView.widthAnchor constraintEqualToConstant:dragViewSideLength]
    ]];
}

- (void)reset {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat eventsViewMargin = GrowingTKSizeFrom750(kEventsViewMargin);
        CGFloat eventsViewHeight = GrowingTKSizeFrom750(kEventsViewHeight);
        self.eventsViewBottomConstraint.constant = -eventsViewMargin;
        self.eventsViewLeadingConstraint.constant = eventsViewMargin;
        self.eventsViewWidthConstraint.constant = -eventsViewMargin * 2;
        self.eventsViewHeightConstraint.constant = eventsViewHeight;
        self.showFullEventDetail = YES;
        [self resetRealtimeEvents];
    });
}

- (void)resetRealtimeEvents {
    if (self.isShowFullEventDetail) {
        [self showRealtimeEventsWithText:[self.realtimeEventsArray componentsJoinedByString:@"\n"]];
    } else {
        NSMutableArray *eventsArray = [NSMutableArray array];
        [self.realtimeEventsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [eventsArray addObject:[obj substringToIndex:[obj rangeOfString:@"]"].location + 1]];
        }];
        [self showRealtimeEventsWithText:[eventsArray componentsJoinedByString:@"\n"]];
    }
}

- (void)showRealtimeEventsWithText:(NSString *)text {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = GrowingTKSizeFrom750(8);
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSMutableAttributedString *attrString =
    [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName: style,
                                                                        NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.eventsTextView.attributedText = attrString;
}

#pragma mark - Action

- (void)eventsViewPan:(UIPanGestureRecognizer *)sender {
    UIView *panView = sender.view;

    if (!panView.hidden) {
        CGPoint offsetPoint = [sender translationInView:panView];
        [sender setTranslation:CGPointZero inView:panView];
        self.eventsViewLeadingConstraint.constant += offsetPoint.x;
        self.eventsViewBottomConstraint.constant += offsetPoint.y;
        [self.eventsView setNeedsUpdateConstraints];
    }
}

- (void)dragViewPan:(UIPanGestureRecognizer *)sender {
    UIView *panView = sender.view;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            self.eventsView.alpha = 0.5f;
        } break;
        case UIGestureRecognizerStateChanged: {
            CGPoint offsetPoint = [sender translationInView:panView];
            [sender setTranslation:CGPointZero inView:panView];
            self.eventsViewWidthConstraint.constant += offsetPoint.x;
            self.eventsViewHeightConstraint.constant += offsetPoint.y;
            self.eventsViewBottomConstraint.constant += offsetPoint.y;
            [self.eventsView setNeedsUpdateConstraints];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.eventsView.alpha = 1.0f;
            CGFloat fullEventDetailMinWidth = GrowingTKSizeFrom750(kFullEventDetailMinWidth);
            self.showFullEventDetail = (self.eventsView.growingtk_width > fullEventDetailMinWidth);
            [self resetRealtimeEvents];
        } break;
        default:
            break;
    }
}

- (void)closeButtonAction:(UIButton *)sender {
    [GrowingTKRealtimePlugin.plugin hideRealtimeWindow];
}

#pragma mark - Notification

- (void)realtimeEventNotification:(NSNotification *)not {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *info = [NSString stringWithFormat:@"[%@ - %@]", not.userInfo[@"gesid"], not.userInfo[@"eventType"]];
        NSString *detail = not.userInfo[@"detail"];
        if (detail.length > 0) {
            info = [info stringByAppendingFormat:@" %@", detail];
        }
        
        [self.realtimeEventsArray insertObject:info atIndex:0];
        if (self.realtimeEventsArray.count > 50) {
            [self.realtimeEventsArray removeObjectsInRange:NSMakeRange(49, self.realtimeEventsArray.count - 50)];
        }
        [self resetRealtimeEvents];
    });
}

- (void)keyboardWillShow:(NSNotification *)not {
    CGRect keyBoardFrame = [[not userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect viewFrame = [self.eventsView convertRect:self.eventsView.bounds toView:self.eventsView.window];
    
    if (CGRectIntersectsRect(keyBoardFrame, viewFrame)) {
        CGFloat eventsViewMargin = GrowingTKSizeFrom750(kEventsViewMargin);
        CGFloat keyBoardHeight = [[not userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        self.eventsViewLeadingConstraint.constant = eventsViewMargin;
        self.eventsViewBottomConstraint.constant = -(keyBoardHeight + eventsViewMargin - self.view.growingtk_safeAreaInsets.bottom);
        [self.eventsView setNeedsUpdateConstraints];
        
        CGFloat duration = [[not userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
        
        self.resetEventsViewConstraintsAfterKeyBoardHide = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)not {
    if (!self.resetEventsViewConstraintsAfterKeyBoardHide) {
        return;
    }
    self.resetEventsViewConstraintsAfterKeyBoardHide = NO;
    
    CGFloat eventsViewMargin = GrowingTKSizeFrom750(kEventsViewMargin);
    self.eventsViewLeadingConstraint.constant = eventsViewMargin;
    self.eventsViewBottomConstraint.constant = -eventsViewMargin;
    [self.eventsView setNeedsUpdateConstraints];
    
    CGFloat duration = [[not userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Getter & Setter

- (UIView *)eventsView {
    if (!_eventsView) {
        _eventsView = [[UIView alloc] initWithFrame:CGRectZero];
        _eventsView.backgroundColor = [UIColor growingtk_colorWithHex:@"#000000" alpha:0.5f];
        _eventsView.layer.cornerRadius = GrowingTKSizeFrom750(8);
        _eventsView.layer.borderWidth = 1.0f;
        _eventsView.layer.borderColor = [UIColor growingtk_colorWithHex:@"#999999" alpha:0.2f].CGColor;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(eventsViewPan:)];
        [_eventsView addGestureRecognizer:pan];
        _eventsView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _eventsView;
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

- (UITextView *)eventsTextView {
    if (!_eventsTextView) {
        _eventsTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _eventsTextView.backgroundColor = [UIColor clearColor];
        _eventsTextView.textColor = [UIColor whiteColor];
        _eventsTextView.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        _eventsTextView.userInteractionEnabled = NO;
        _eventsTextView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _eventsTextView;
}

- (UIImageView *)dragView {
    if (!_dragView) {
        _dragView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _dragView.image = [UIImage growingtk_imageNamed:@"growingtk_zoom"];
        _dragView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(dragViewPan:)];
        [_dragView addGestureRecognizer:pan];
        _dragView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _dragView;
}

- (NSMutableArray<NSString *> *)realtimeEventsArray {
    if (!_realtimeEventsArray) {
        _realtimeEventsArray = [NSMutableArray array];
    }
    return _realtimeEventsArray;
}

@end
