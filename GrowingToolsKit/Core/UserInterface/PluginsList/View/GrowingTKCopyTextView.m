//
//  GrowingTKCopyTextView.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/16.
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

#import "GrowingTKCopyTextView.h"

@implementation GrowingTKCopyTextView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

#pragma mark - Private Method

- (void)setup {
    self.editable = NO;
    self.selectable = YES;
    self.inputView = UIView.new;
    self.inputAccessoryView = UIView.new;
}

#pragma mark - Action

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:) || action == @selector(selectAll:)) {
        return YES;
    }
    return NO;
}

@end
