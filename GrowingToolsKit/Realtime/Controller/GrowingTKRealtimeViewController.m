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
#import "GrowingTKRealtimeListView.h"
#import "UIView+GrowingTK.h"

static CGFloat const kEventsViewMargin = 24.0f;
static CGFloat const kEventsViewWidth = 370.0f;

@interface GrowingTKRealtimeViewController ()

@property (nonatomic, strong) GrowingTKRealtimeListView *eventsView;

@property (nonatomic, strong) NSLayoutConstraint *eventsViewBottomConstraint;
@property (nonatomic, assign) BOOL resetEventsViewConstraintsAfterKeyBoardHide;

@end

@implementation GrowingTKRealtimeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Public Method

- (void)start {
    [self.eventsView start];
}

#pragma mark - Private Method

- (void)initUI {
    self.view.backgroundColor = UIColor.clearColor;

    [self.view addSubview:self.eventsView];

    CGFloat eventsViewMargin = GrowingTKSizeFrom750(kEventsViewMargin);
    CGFloat eventsViewWidth = GrowingTKSizeFrom750(kEventsViewWidth);
    self.eventsViewBottomConstraint = [self.eventsView.bottomAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.bottomAnchor
                                                                                   constant:-eventsViewMargin];
    [NSLayoutConstraint activateConstraints:@[
        self.eventsViewBottomConstraint,
        [self.eventsView.trailingAnchor constraintEqualToAnchor:self.view.growingtk_safeAreaLayoutGuide.trailingAnchor],
        [self.eventsView.widthAnchor constraintEqualToConstant:eventsViewWidth]
    ]];
}

#pragma mark - Action

- (void)eventsViewPan:(UIPanGestureRecognizer *)sender {
    UIView *panView = sender.view;

    if (!panView.hidden) {
        CGPoint offsetPoint = [sender translationInView:panView];
        [sender setTranslation:CGPointZero inView:panView];
        CGFloat constant = self.eventsViewBottomConstraint.constant;
        constant += offsetPoint.y;
        CGFloat min = -self.view.growingtk_safeAreaLayoutGuide.layoutFrame.size.height + GrowingTKSizeFrom750(100);
        CGFloat max = -GrowingTKSizeFrom750(kEventsViewMargin);
        if (constant < max && constant > min) {
            self.eventsViewBottomConstraint.constant = constant;
            [self.eventsView setNeedsUpdateConstraints];
        }
    }
}

#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)not {
    CGRect keyBoardFrame = [[not userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect viewFrame = [self.eventsView convertRect:self.eventsView.bounds toView:self.eventsView.window];
    
    if (CGRectIntersectsRect(keyBoardFrame, viewFrame)) {
        CGFloat eventsViewMargin = GrowingTKSizeFrom750(kEventsViewMargin);
        CGFloat keyBoardHeight = [[not userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
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
    self.eventsViewBottomConstraint.constant = -eventsViewMargin;
    [self.eventsView setNeedsUpdateConstraints];
    
    CGFloat duration = [[not userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Getter & Setter

- (GrowingTKRealtimeListView *)eventsView {
    if (!_eventsView) {
        _eventsView = [[GrowingTKRealtimeListView alloc] initWithFrame:CGRectZero];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(eventsViewPan:)];
        [_eventsView addGestureRecognizer:pan];
        _eventsView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _eventsView;
}

@end
