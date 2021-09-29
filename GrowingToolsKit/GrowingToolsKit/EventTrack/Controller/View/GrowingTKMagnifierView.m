//
//  GrowingTKMagnifierView.m
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

#import "GrowingTKMagnifierView.h"
#import "GrowingTKTriangleView.h"
#import "GrowingTKDefine.h"
#import "GrowingTKUtil.h"
#import "UIView+GrowingTK.h"
#import "UIColor+GrowingTK.h"

typedef NS_ENUM(NSUInteger, GrowingTKMagnifierPosition) {
    GrowingTKMagnifierPositionLeft = 0,
    GrowingTKMagnifierPositionTop,
    GrowingTKMagnifierPositionRight,
    GrowingTKMagnifierPositionBottom
};

static CGFloat const kMagnifierViewWidth = 160.0f;
static CGFloat const kMagnifierViewHeight = 90.0f;
static CGFloat const kTriangleViewSideLength = 12.0f;

@interface GrowingTKMagnifierView ()

@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) GrowingTKTriangleView *triangleView;

@end

@implementation GrowingTKMagnifierView

#pragma mark - Init

- (instancetype)initWithView:(UIView *)view point:(CGPoint)point {
    if (self = [super init]) {
        self.layer.masksToBounds = YES;
        [self updateFrameWithView:view];

        self.contentImageView =
            [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                          0,
                                                          GrowingTKSizeFrom750(kMagnifierViewWidth),
                                                          GrowingTKSizeFrom750(kMagnifierViewHeight))];
        self.contentImageView.image = [self takeSnapshotWithTouchPoint:point];
        self.contentImageView.backgroundColor = UIColor.whiteColor;
        self.contentImageView.layer.cornerRadius = GrowingTKSizeFrom750(10.0f);
        self.contentImageView.layer.borderWidth = GrowingTKSizeFrom750(3.0f);
        self.contentImageView.layer.borderColor = UIColor.growingtk_primaryBackgroundColor.CGColor;
        self.contentImageView.layer.masksToBounds = YES;
        [self addSubview:self.contentImageView];

        self.triangleView =
            [[GrowingTKTriangleView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    GrowingTKSizeFrom750(kTriangleViewSideLength),
                                                                    GrowingTKSizeFrom750(kTriangleViewSideLength))];
        self.triangleView.backgroundColor = UIColor.clearColor;
        self.triangleView.triangleColor = UIColor.growingtk_primaryBackgroundColor;
        [self addSubview:self.triangleView];
    }
    return self;
}

#pragma mark - Public Method

- (void)refreshWithView:(UIView *)view point:(CGPoint)point {
    [self updateFrameWithView:view];
    self.contentImageView.image = [self takeSnapshotWithTouchPoint:point];
}

#pragma mark - Private Method

- (void)updateFrameWithView:(UIView *)view {
    GrowingTKMagnifierPosition position = [self positionForView:view];
    CGRect frame =
        CGRectMake(0, 0, GrowingTKSizeFrom750(kMagnifierViewWidth), GrowingTKSizeFrom750(kMagnifierViewHeight));
    CGRect viewFrame = [view convertRect:view.bounds toView:view.window];
    CGFloat padding = GrowingTKSizeFrom750(kTriangleViewSideLength);
    switch (position) {
        case GrowingTKMagnifierPositionLeft: {
            frame.size.width += padding;
            frame.origin.x = viewFrame.origin.x - frame.size.width - padding;
            frame.origin.y = viewFrame.origin.y + viewFrame.size.height / 2 - frame.size.height / 2;
        } break;
        case GrowingTKMagnifierPositionTop: {
            frame.size.height += padding;
            frame.origin.x = viewFrame.origin.x + viewFrame.size.width / 2 - frame.size.width / 2;
            frame.origin.y = viewFrame.origin.y - frame.size.height - padding;
        } break;
        case GrowingTKMagnifierPositionRight: {
            frame.size.width += padding;
            frame.origin.x = viewFrame.origin.x + viewFrame.size.width + padding;
            frame.origin.y = viewFrame.origin.y + viewFrame.size.height / 2 - frame.size.height / 2;
        } break;
        case GrowingTKMagnifierPositionBottom: {
            frame.size.height += padding;
            frame.origin.x = viewFrame.origin.x + viewFrame.size.width / 2 - frame.size.width / 2;
            frame.origin.y = viewFrame.origin.y + viewFrame.size.height + padding;
        } break;
        default:
            break;
    }

    self.frame = frame;

    // contentImageView
    switch (position) {
        case GrowingTKMagnifierPositionLeft: {
            self.contentImageView.growingtk_x = 0;
            self.contentImageView.growingtk_y = 0;
        } break;
        case GrowingTKMagnifierPositionTop: {
            self.contentImageView.growingtk_x = 0;
            self.contentImageView.growingtk_y = 0;
        } break;
        case GrowingTKMagnifierPositionRight: {
            self.contentImageView.growingtk_x = padding;
            self.contentImageView.growingtk_y = 0;
        } break;
        case GrowingTKMagnifierPositionBottom: {
            self.contentImageView.growingtk_x = 0;
            self.contentImageView.growingtk_y = padding;
        } break;
        default:
            break;
    }

    // triangleView
    self.triangleView.transform = CGAffineTransformMakeRotation(M_PI_2 + M_PI_2 * position);
    self.triangleView.center = self.contentImageView.center;
    switch (position) {
        case GrowingTKMagnifierPositionLeft: {
            self.triangleView.growingtk_x +=
                (self.contentImageView.growingtk_width + self.triangleView.growingtk_width) / 2;
        } break;
        case GrowingTKMagnifierPositionTop: {
            self.triangleView.growingtk_y +=
                (self.contentImageView.growingtk_height + self.triangleView.growingtk_height) / 2;
        } break;
        case GrowingTKMagnifierPositionRight: {
            self.triangleView.growingtk_x -=
                (self.contentImageView.growingtk_width + self.triangleView.growingtk_width) / 2;
        } break;
        case GrowingTKMagnifierPositionBottom: {
            self.triangleView.growingtk_y -=
                (self.contentImageView.growingtk_height + self.triangleView.growingtk_height) / 2;
        } break;
        default:
            break;
    }
}

- (GrowingTKMagnifierPosition)positionForView:(UIView *)view {
    GrowingTKMagnifierPosition position = GrowingTKMagnifierPositionTop;
    CGPoint point = [view convertPoint:view.center toView:view.window];
    CGFloat topPadding = point.y - view.frame.size.height / 2;
    if (topPadding < GrowingTKSizeFrom750(kMagnifierViewHeight)) {
        CGFloat leadingPadding = point.x - view.frame.size.width / 2;
        if (leadingPadding < GrowingTKSizeFrom750(kMagnifierViewWidth)) {
            CGFloat trailingPadding = GrowingTKScreenWidth - point.x - view.frame.size.width / 2;
            if (trailingPadding < GrowingTKSizeFrom750(kMagnifierViewWidth)) {
                position = GrowingTKMagnifierPositionBottom;
            } else {
                position = GrowingTKMagnifierPositionRight;
            }
        } else {
            position = GrowingTKMagnifierPositionLeft;
        }
    }
    return position;
}

- (UIImage *)takeSnapshotWithTouchPoint:(CGPoint)touchPoint {
    CGSize size = CGSizeMake(GrowingTKSizeFrom750(kMagnifierViewWidth), GrowingTKSizeFrom750(kMagnifierViewHeight));
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);

    [GrowingTKUtil.keyWindow
        drawViewHierarchyInRect:CGRectMake(-touchPoint.x + GrowingTKSizeFrom750(kMagnifierViewWidth) / 2,
                                           -touchPoint.y + GrowingTKSizeFrom750(kMagnifierViewHeight) / 2,
                                           UIScreen.mainScreen.bounds.size.width,
                                           UIScreen.mainScreen.bounds.size.height)
             afterScreenUpdates:NO];

    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *scaledSnapshot = [UIImage imageWithCGImage:snapshot.CGImage
                                                  scale:snapshot.scale / [UIScreen mainScreen].scale
                                            orientation:snapshot.imageOrientation];
    UIGraphicsEndImageContext();
    return scaledSnapshot;
}

@end
