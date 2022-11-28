//
//  GrowingTKRealtimeListView.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/8/16.
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

#import "GrowingTKRealtimeListView.h"
#import "GrowingTKRealtimeEvent.h"
#import "GrowingTKRealtimeBubble.h"
#import "GrowingTKRealtimeSingleBubble.h"
#import "GrowingTKRealtimeMutiBubble.h"
#import "GrowingTKRealtimePool.h"
#import "GrowingTKDefine.h"

static NSUInteger const kMaxRealtimeEventsCount = 6;
static CGFloat const kAnimationTimeInterval = 0.2f;
static long long const kfadedTimerInterval = 500LL;
static long long const kfadedInterval = 3000LL;

@interface GrowingTKRealtimeListView ()

@property (nonatomic, strong) GrowingTKRealtimePool *pool;
@property (nonatomic, strong) NSMutableArray<id <GrowingTKRealtimeBubble>> *bubbles;
@property (nonatomic, strong) NSLayoutConstraint *lastBubbleBottomConstraint;
@property (nonatomic, strong) dispatch_source_t fadedTimer;

@end

@implementation GrowingTKRealtimeListView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;

        __weak typeof(self) weakSelf = self;
        self.pool = [[GrowingTKRealtimePool alloc] initWithPopup:^(NSArray<GrowingTKRealtimeEvent *> * _Nonnull events) {
            __strong typeof(weakSelf) self = weakSelf;
            if (events && events.count > 0) {
                CGRect defaultFrame = CGRectMake(UIScreen.mainScreen.bounds.size.width, self.bounds.size.height + 100, 0, 0);
                if (events.count > 1) {
                    // 多个 event 短时间内触发
                    GrowingTKRealtimeMutiBubble *bubble = [[GrowingTKRealtimeMutiBubble alloc] init];
                    bubble.frame = defaultFrame;
                    [self addBubble:bubble];
                    [bubble configWithEvents:events];
                } else {
                    // 单个 event
                    GrowingTKRealtimeSingleBubble *bubble = [[GrowingTKRealtimeSingleBubble alloc] init];
                    bubble.frame = defaultFrame;
                    [self addBubble:bubble];
                    [bubble configWithEvent:events.firstObject];
                }
            }
        }];

        [self startTimer];
    }
    return self;
}

#pragma mark - Public Methods

- (void)start {
    GrowingTKRealtimeEvent *start = [[GrowingTKRealtimeEvent alloc] init];
    start.eventType = @"START";
    start.globalSequenceId = @0;
    start.detail = GrowingTKLocalizedString(@"实时事件检测开始");
    start.timestamp = @(NSDate.date.timeIntervalSince1970 * 1000LL);
    
    GrowingTKRealtimeSingleBubble *bubble = [[GrowingTKRealtimeSingleBubble alloc] init];
    bubble.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width, self.bounds.size.height + 100, 0, 0);
    [self addBubble:bubble];
    [bubble configWithEvent:start];
}

#pragma mark - Private Methods

- (void)addBubble:(id <GrowingTKRealtimeBubble>)bubble {
    if (self.bubbles.count >= kMaxRealtimeEventsCount) {
        [self deleteBubble:self.bubbles.firstObject];
    }
    
    UIView *bubbleView = (UIView *)bubble;
    [self addSubview:bubbleView];
    
    id <GrowingTKRealtimeBubble> lastBubble = self.bubbles.lastObject;
    if (lastBubble) {
        if (self.lastBubbleBottomConstraint) {
            [NSLayoutConstraint deactivateConstraints:@[self.lastBubbleBottomConstraint]];
        }
        [NSLayoutConstraint activateConstraints:@[[bubbleView.topAnchor constraintEqualToAnchor:((UIView *)lastBubble).bottomAnchor
                                                                                       constant:GrowingTKSizeFrom750(12)]]];
    }
    
    [self.bubbles addObject:bubble];
    self.lastBubbleBottomConstraint = [bubbleView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        self.lastBubbleBottomConstraint,
        [bubbleView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor],
        [bubbleView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
    
    [UIView animateWithDuration:kAnimationTimeInterval delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)deleteBubble:(id <GrowingTKRealtimeBubble>)bubble {
    UIView *bubbleView = (UIView *)bubble;
    [UIView animateWithDuration:kAnimationTimeInterval delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        bubbleView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [bubbleView removeFromSuperview];
    }];
    [self.bubbles removeObject:bubble];
}

- (void)dismissOutdatedBubble {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.bubbles.count; i++) {
            id <GrowingTKRealtimeBubble> bubble = self.bubbles[i];
            GrowingTKRealtimeEvent *event = bubble.event;
            if ((NSDate.date.timeIntervalSince1970 * 1000LL - event.timestamp.doubleValue) > kfadedInterval) {
                [self deleteBubble:bubble];
                break;
            }
        }
    });
}

#pragma mark - Timer

- (void)startTimer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_t queue = dispatch_queue_create("com.growing.toolskit.realtime.timer", NULL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        self.fadedTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.fadedTimer,
                                  dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * kfadedTimerInterval),
                                  NSEC_PER_MSEC * kfadedTimerInterval,
                                  NSEC_PER_MSEC * kfadedTimerInterval);
        dispatch_source_set_event_handler(self.fadedTimer, ^{
            [self dismissOutdatedBubble];
        });
        dispatch_resume(self.fadedTimer);
    });
}

#pragma mark - Getter & Setter

- (NSMutableArray<id <GrowingTKRealtimeBubble>> *)bubbles {
    if (!_bubbles) {
        _bubbles = [NSMutableArray array];
    }
    return _bubbles;
}

@end
