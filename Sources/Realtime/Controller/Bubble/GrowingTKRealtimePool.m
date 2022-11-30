//
//  GrowingTKRealtimePool.m
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

#import "GrowingTKRealtimePool.h"
#import "GrowingTKRealtimeEvent.h"
#import "GrowingTKDefine.h"

static long long const kPopupInterval = 500LL;

@interface GrowingTKRealtimePool ()

@property (nonatomic, strong) NSMutableArray<GrowingTKRealtimeEvent *> *lastBubbles;
@property (nonatomic, strong) dispatch_source_t popTimer;
@property (nonatomic, copy) void(^popup)(NSArray<GrowingTKRealtimeEvent *> *);

@end

@implementation GrowingTKRealtimePool

#pragma mark - Init

- (instancetype)initWithPopup:(void(^)(NSArray<GrowingTKRealtimeEvent *> *))popup {
    if (self = [super init]) {
        _popup = popup;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(realtimeEventNotification:)
                                                 name:GrowingTKRealtimeEventNotification
                                               object:nil];
    [self startTimer];
    return self;
}

#pragma mark - Timer

- (void)startTimer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_t queue = dispatch_queue_create("com.growing.toolskit.realtime.timer.popup", NULL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        self.popTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.popTimer,
                                  dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * kPopupInterval),
                                  NSEC_PER_MSEC * kPopupInterval,
                                  NSEC_PER_MSEC * kPopupInterval);
        dispatch_source_set_event_handler(self.popTimer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.popup && self.lastBubbles.count > 0) {
                    self.popup(self.lastBubbles.copy);
                    [self.lastBubbles removeAllObjects];
                }
            });
        });
        dispatch_resume(self.popTimer);
    });
}

#pragma mark - Notification

- (void)realtimeEventNotification:(NSNotification *)not {
    [self throwIntoPool:not.userInfo[@"event"]];
}

#pragma mark - Public Method

- (void)throwIntoPool:(GrowingTKRealtimeEvent *)event {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.popup && self.lastBubbles.count > 0) {
            GrowingTKRealtimeEvent *last = self.lastBubbles.lastObject;
            if (last.isCustomEvent != event.isCustomEvent // 无埋点与埋点分离
                || [last.globalSequenceId isEqualToNumber:@0]) { // 实时埋点开始提示
                self.popup(self.lastBubbles.copy);
                [self.lastBubbles removeAllObjects];
            }
        }
        
        [self.lastBubbles addObject:event];
    });
}

- (NSMutableArray<GrowingTKRealtimeEvent *> *)lastBubbles {
    if (!_lastBubbles) {
        _lastBubbles = [NSMutableArray array];
    }
    return _lastBubbles;
}

@end
