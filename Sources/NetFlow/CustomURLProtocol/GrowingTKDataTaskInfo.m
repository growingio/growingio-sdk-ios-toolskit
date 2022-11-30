//
//  GrowingTKDataTaskInfo.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/4.
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

#import "GrowingTKDataTaskInfo.h"

@interface GrowingTKDataTaskInfo ()

@property (atomic, strong, readwrite) id<NSURLSessionDataDelegate> delegate;
@property (atomic, strong, readwrite) NSThread *thread;

@end

@implementation GrowingTKDataTaskInfo

- (instancetype)initWithTask:(NSURLSessionDataTask *)task
                    delegate:(id<NSURLSessionDataDelegate>)delegate
                       modes:(NSArray *)modes {
    if (self = [super init]) {
        self->_task = task;
        self->_delegate = delegate;
        self->_thread = [NSThread currentThread];
        self->_modes = [modes copy];
    }
    return self;
}

- (void)performBlock:(dispatch_block_t)block {
    [self performSelector:@selector(performBlockOnClientThread:)
                 onThread:self.thread
               withObject:[block copy]
            waitUntilDone:NO
                    modes:self.modes];
}

- (void)performBlockOnClientThread:(dispatch_block_t)block {
    block();
}

- (void)invalidate {
    self.delegate = nil;
    self.thread = nil;
}

@end
