//
//  GrowingTKTriangleView.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/26.
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

#import "GrowingTKTriangleView.h"

@implementation GrowingTKTriangleView

#pragma mark - Override

- (void)drawRect:(CGRect)rect {
    CGSize size = self.bounds.size;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, size.height)];
    [path addLineToPoint:CGPointMake(size.width / 2, 0)];
    [path addLineToPoint:CGPointMake(size.width, size.height)];
    [path closePath];

    [self.triangleColor setFill];
    [path fill];
}

#pragma mark - Setter & Getter

- (void)setTriangleColor:(UIColor*)triangleColor {
    _triangleColor = triangleColor;
    [self setNeedsDisplay];
}

@end
