//
//  UIView+GrowingTK.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/12.
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

#import "UIView+GrowingTK.h"
#import "NSObject+GrowingTKSwizzle.h"
#import "GrowingTKSDKUtil.h"

#pragma mark - Position

#define GrowingTK_SCREEN_SCALE ([[UIScreen mainScreen] scale])
#define GrowingTK_PIXEL_INTEGRAL(pointValue) (round(pointValue * GrowingTK_SCREEN_SCALE) / GrowingTK_SCREEN_SCALE)

@implementation UIView (GrowingTK)

#pragma mark Swizzle

+ (void)load {
#ifdef DEBUG
    [self growingtk_swizzleMethod:@selector(didMoveToSuperview)
                       withMethod:@selector(growingtk_didMoveToSuperview)
                            error:nil];
#endif
}

- (void)growingtk_didMoveToSuperview {
    NSString *prefix = @"GrowingTK";
    if ([NSStringFromClass(self.growingtk_viewController.class) hasPrefix:prefix]
        || [NSStringFromClass(self.growingtk_viewController.navigationController.class) hasPrefix:prefix]
        || [NSStringFromClass(self.growingtk_viewController.presentingViewController.class) hasPrefix:prefix]
        || [NSStringFromClass(self.window.class) hasPrefix:prefix]) {
        [GrowingTKSDKUtil.sharedInstance ignoreView:self];
    }
    
    [self growingtk_didMoveToSuperview];
}

#pragma mark Setter

- (void)setGrowingtk_x:(CGFloat)x {
    self.frame = CGRectMake(GrowingTK_PIXEL_INTEGRAL(x), self.growingtk_y, self.growingtk_width, self.growingtk_height);
}

- (void)setGrowingtk_y:(CGFloat)y {
    self.frame = CGRectMake(self.growingtk_x, GrowingTK_PIXEL_INTEGRAL(y), self.growingtk_width, self.growingtk_height);
}

- (void)setGrowingtk_width:(CGFloat)width {
    self.frame = CGRectMake(self.growingtk_x, self.growingtk_y, GrowingTK_PIXEL_INTEGRAL(width), self.growingtk_height);
}

- (void)setGrowingtk_height:(CGFloat)height {
    self.frame = CGRectMake(self.growingtk_x, self.growingtk_y, self.growingtk_width, GrowingTK_PIXEL_INTEGRAL(height));
}

- (void)setGrowingtk_origin:(CGPoint)origin {
    self.growingtk_x = origin.x;
    self.growingtk_y = origin.y;
}

- (void)setGrowingtk_size:(CGSize)size {
    self.growingtk_width = size.width;
    self.growingtk_height = size.height;
}

- (void)setGrowingtk_right:(CGFloat)right {
    self.growingtk_x = right - self.growingtk_width;
}

- (void)setGrowingtk_bottom:(CGFloat)bottom {
    self.growingtk_y = bottom - self.growingtk_height;
}

- (void)setGrowingtk_left:(CGFloat)left {
    self.growingtk_x = left;
}

- (void)setGrowingtk_top:(CGFloat)top {
    self.growingtk_y = top;
}

- (void)setGrowingtk_centerX:(CGFloat)centerX {
    self.center = CGPointMake(GrowingTK_PIXEL_INTEGRAL(centerX), self.center.y);
}

- (void)setGrowingtk_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, GrowingTK_PIXEL_INTEGRAL(centerY));
}

#pragma mark Getter

- (CGFloat)growingtk_x {
    return self.frame.origin.x;
}

- (CGFloat)growingtk_y {
    return self.frame.origin.y;
}

- (CGFloat)growingtk_width {
    return self.frame.size.width;
}

- (CGFloat)growingtk_height {
    return self.frame.size.height;
}

- (CGPoint)growingtk_origin {
    return CGPointMake(self.growingtk_x, self.growingtk_y);
}

- (CGSize)growingtk_size {
    return CGSizeMake(self.growingtk_width, self.growingtk_height);
}

- (CGFloat)growingtk_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)growingtk_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)growingtk_left {
    return self.growingtk_x;
}

- (CGFloat)growingtk_top {
    return self.growingtk_y;
}

- (CGFloat)growingtk_centerX {
    return self.center.x;
}

- (CGFloat)growingtk_centerY {
    return self.center.y;
}

- (UIViewController *)growingtk_viewController {
    for (UIView *next = self.superview; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (UILayoutGuide *)growingtk_safeAreaLayoutGuide {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaLayoutGuide;
    }
    return self.layoutMarginsGuide;
}

- (UIEdgeInsets)growingtk_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

@end

#pragma mark - Toast

// *****************************************
// Toast: https://github.com/scalessec/Toast
// *****************************************
//  Copyright (c) 2011-2017 Charles Scalesse.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Positions
NSString *GrowingTKToastPositionTop = @"GrowingTKToastPositionTop";
NSString *GrowingTKToastPositionCenter = @"GrowingTKToastPositionCenter";
NSString *GrowingTKToastPositionBottom = @"GrowingTKToastPositionBottom";

// Keys for values associated with toast views
static const NSString *GrowingTKToastTimerKey = @"GrowingTKToastTimerKey";
static const NSString *GrowingTKToastDurationKey = @"GrowingTKToastDurationKey";
static const NSString *GrowingTKToastPositionKey = @"GrowingTKToastPositionKey";
static const NSString *GrowingTKToastCompletionKey = @"GrowingTKToastCompletionKey";

// Keys for values associated with self
static const NSString *GrowingTKToastActiveKey = @"GrowingTKToastActiveKey";
static const NSString *GrowingTKToastActivityViewKey = @"GrowingTKToastActivityViewKey";
static const NSString *GrowingTKToastQueueKey = @"GrowingTKToastQueueKey";

@interface UIView (GrowingTKToastPrivate)

/**
 These private methods are being prefixed with "growingtk_" to reduce the likelihood of non-obvious
 naming conflicts with other UIView methods.

 @discussion Should the public API also use the growingtk_ prefix? Technically it should, but it
 results in code that is less legible. The current public method names seem unlikely to cause
 conflicts so I think we should favor the cleaner API for now.
 */
- (void)growingtk_private_showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position;
- (void)growingtk_private_hideToast:(UIView *)toast;
- (void)growingtk_private_hideToast:(UIView *)toast fromTap:(BOOL)fromTap;
- (void)growingtk_private_toastTimerDidFinish:(NSTimer *)timer;
- (void)growingtk_private_handleToastTapped:(UITapGestureRecognizer *)recognizer;
- (CGPoint)growingtk_private_centerPointForPosition:(id)position withToast:(UIView *)toast;
- (NSMutableArray *)growingtk_private_toastQueue;

@end

@implementation UIView (GrowingTKToast)

#pragma mark - Make Toast Methods

- (void)growingtk_makeToast:(NSString *)message {
    [self growingtk_makeToast:message
                     duration:[GrowingTKToastManager defaultDuration]
                     position:[GrowingTKToastManager defaultPosition]
                        style:nil];
}

- (void)growingtk_makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position {
    [self growingtk_makeToast:message duration:duration position:position style:nil];
}

- (void)growingtk_makeToast:(NSString *)message
                   duration:(NSTimeInterval)duration
                   position:(id)position
                      style:(nullable GrowingTKToastStyle *)style {
    UIView *toast = [self growingtk_toastViewForMessage:message title:nil image:nil style:style];
    [self growingtk_showToast:toast duration:duration position:position completion:nil];
}

- (void)growingtk_makeToast:(NSString *)message
                   duration:(NSTimeInterval)duration
                   position:(id)position
                      title:(NSString *)title
                      image:(UIImage *)image
                      style:(nullable GrowingTKToastStyle *)style
                 completion:(void (^_Nullable)(BOOL didTap))completion {
    UIView *toast = [self growingtk_toastViewForMessage:message title:title image:image style:style];
    [self growingtk_showToast:toast duration:duration position:position completion:completion];
}

#pragma mark - Show Toast Methods

- (void)growingtk_showToast:(UIView *)toast {
    [self growingtk_showToast:toast
                     duration:[GrowingTKToastManager defaultDuration]
                     position:[GrowingTKToastManager defaultPosition]
                   completion:nil];
}

- (void)growingtk_showToast:(UIView *)toast
                   duration:(NSTimeInterval)duration
                   position:(id)position
                 completion:(void (^_Nullable)(BOOL didTap))completion {
    // sanity
    if (toast == nil)
        return;

    // store the completion block on the toast view
    objc_setAssociatedObject(toast, &GrowingTKToastCompletionKey, completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if ([GrowingTKToastManager isQueueEnabled] && [self.growingtk_activeToasts count] > 0) {
        // we're about to queue this toast view so we need to store the duration and position as well
        objc_setAssociatedObject(toast, &GrowingTKToastDurationKey, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(toast, &GrowingTKToastPositionKey, position, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // enqueue
        [self.growingtk_private_toastQueue addObject:toast];
    } else {
        // present
        [self growingtk_private_showToast:toast duration:duration position:position];
    }
}

#pragma mark - Hide Toast Methods

- (void)growingtk_hideToast {
    [self growingtk_hideToast:[[self growingtk_activeToasts] firstObject]];
}

- (void)growingtk_hideToast:(UIView *)toast {
    // sanity
    if (!toast || ![[self growingtk_activeToasts] containsObject:toast])
        return;

    [self growingtk_private_hideToast:toast];
}

- (void)growingtk_hideAllToasts {
    [self growingtk_hideAllToasts:NO clearQueue:YES];
}

- (void)growingtk_hideAllToasts:(BOOL)includeActivity clearQueue:(BOOL)clearQueue {
    if (clearQueue) {
        [self growingtk_clearToastQueue];
    }

    for (UIView *toast in [self growingtk_activeToasts]) {
        [self growingtk_hideToast:toast];
    }

    if (includeActivity) {
        [self growingtk_hideToastActivity];
    }
}

- (void)growingtk_clearToastQueue {
    [[self growingtk_private_toastQueue] removeAllObjects];
}

#pragma mark - Private Show/Hide Methods

- (void)growingtk_private_showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position {
    toast.center = [self growingtk_private_centerPointForPosition:position withToast:toast];
    toast.alpha = 0.0;

    if ([GrowingTKToastManager isTapToDismissEnabled]) {
        UITapGestureRecognizer *recognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(growingtk_private_handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }

    [[self growingtk_activeToasts] addObject:toast];

    [self addSubview:toast];

    [UIView animateWithDuration:[[GrowingTKToastManager sharedStyle] fadeDuration]
        delay:0.0
        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
        animations:^{
            toast.alpha = 1.0;
        }
        completion:^(BOOL finished) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:duration
                                                     target:self
                                                   selector:@selector(growingtk_private_toastTimerDidFinish:)
                                                   userInfo:toast
                                                    repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            objc_setAssociatedObject(toast, &GrowingTKToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
}

- (void)growingtk_private_hideToast:(UIView *)toast {
    [self growingtk_private_hideToast:toast fromTap:NO];
}

- (void)growingtk_private_hideToast:(UIView *)toast fromTap:(BOOL)fromTap {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(toast, &GrowingTKToastTimerKey);
    [timer invalidate];

    [UIView animateWithDuration:[[GrowingTKToastManager sharedStyle] fadeDuration]
        delay:0.0
        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
        animations:^{
            toast.alpha = 0.0;
        }
        completion:^(BOOL finished) {
            [toast removeFromSuperview];

            // remove
            [[self growingtk_activeToasts] removeObject:toast];

            // execute the completion block, if necessary
            void (^completion)(BOOL didTap) = objc_getAssociatedObject(toast, &GrowingTKToastCompletionKey);
            if (completion) {
                completion(fromTap);
            }

            if ([self.growingtk_private_toastQueue count] > 0) {
                // dequeue
                UIView *nextToast = [[self growingtk_private_toastQueue] firstObject];
                [[self growingtk_private_toastQueue] removeObjectAtIndex:0];

                // present the next toast
                NSTimeInterval duration = [objc_getAssociatedObject(nextToast, &GrowingTKToastDurationKey) doubleValue];
                id position = objc_getAssociatedObject(nextToast, &GrowingTKToastPositionKey);
                [self growingtk_private_showToast:nextToast duration:duration position:position];
            }
        }];
}

#pragma mark - View Construction

- (UIView *)growingtk_toastViewForMessage:(NSString *)message
                                    title:(nullable NSString *)title
                                    image:(nullable UIImage *)image
                                    style:(nullable GrowingTKToastStyle *)style {
    // sanity
    if (message == nil && title == nil && image == nil)
        return nil;

    // default to the shared style
    if (style == nil) {
        style = [GrowingTKToastManager sharedStyle];
    }

    // dynamically build a toast view with any combination of message, title, & image
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;

    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                                    | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = style.cornerRadius;

    if (style.displayShadow) {
        wrapperView.layer.shadowColor = style.shadowColor.CGColor;
        wrapperView.layer.shadowOpacity = style.shadowOpacity;
        wrapperView.layer.shadowRadius = style.shadowRadius;
        wrapperView.layer.shadowOffset = style.shadowOffset;
    }

    wrapperView.backgroundColor = style.backgroundColor;

    if (image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame =
            CGRectMake(style.horizontalPadding, style.verticalPadding, style.imageSize.width, style.imageSize.height);
    }

    CGRect imageRect = CGRectZero;

    if (imageView != nil) {
        imageRect.origin.x = style.horizontalPadding;
        imageRect.origin.y = style.verticalPadding;
        imageRect.size.width = imageView.bounds.size.width;
        imageRect.size.height = imageView.bounds.size.height;
    }

    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = style.titleNumberOfLines;
        titleLabel.font = style.titleFont;
        titleLabel.textAlignment = style.titleAlignment;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = style.titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;

        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width,
                                         self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeTitle = [titleLabel sizeThatFits:maxSizeTitle];
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeTitle = CGSizeMake(MIN(maxSizeTitle.width, expectedSizeTitle.width),
                                       MIN(maxSizeTitle.height, expectedSizeTitle.height));
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }

    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = style.messageNumberOfLines;
        messageLabel.font = style.messageFont;
        messageLabel.textAlignment = style.messageAlignment;
        messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        messageLabel.textColor = style.messageColor;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;

        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width,
                                           self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeMessage = [messageLabel sizeThatFits:maxSizeMessage];
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeMessage = CGSizeMake(MIN(maxSizeMessage.width, expectedSizeMessage.width),
                                         MIN(maxSizeMessage.height, expectedSizeMessage.height));
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }

    CGRect titleRect = CGRectZero;

    if (titleLabel != nil) {
        titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        titleRect.origin.y = style.verticalPadding;
        titleRect.size.width = titleLabel.bounds.size.width;
        titleRect.size.height = titleLabel.bounds.size.height;
    }

    CGRect messageRect = CGRectZero;

    if (messageLabel != nil) {
        messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding;
        messageRect.size.width = messageLabel.bounds.size.width;
        messageRect.size.height = messageLabel.bounds.size.height;
    }

    CGFloat longerWidth = MAX(titleRect.size.width, messageRect.size.width);
    CGFloat longerX = MAX(titleRect.origin.x, messageRect.origin.x);

    // Wrapper width uses the longerWidth or the image width, whatever is larger. Same logic applies to the wrapper
    // height.
    CGFloat wrapperWidth = MAX((imageRect.size.width + (style.horizontalPadding * 2.0)),
                               (longerX + longerWidth + style.horizontalPadding));
    CGFloat wrapperHeight = MAX((messageRect.origin.y + messageRect.size.height + style.verticalPadding),
                                (imageRect.size.height + (style.verticalPadding * 2.0)));

    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);

    if (titleLabel != nil) {
        titleLabel.frame = titleRect;
        [wrapperView addSubview:titleLabel];
    }

    if (messageLabel != nil) {
        messageLabel.frame = messageRect;
        [wrapperView addSubview:messageLabel];
    }

    if (imageView != nil) {
        [wrapperView addSubview:imageView];
    }

    return wrapperView;
}

#pragma mark - Storage

- (NSMutableArray *)growingtk_activeToasts {
    NSMutableArray *growingtk_activeToasts = objc_getAssociatedObject(self, &GrowingTKToastActiveKey);
    if (growingtk_activeToasts == nil) {
        growingtk_activeToasts = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self,
                                 &GrowingTKToastActiveKey,
                                 growingtk_activeToasts,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return growingtk_activeToasts;
}

- (NSMutableArray *)growingtk_private_toastQueue {
    NSMutableArray *growingtk_private_toastQueue = objc_getAssociatedObject(self, &GrowingTKToastQueueKey);
    if (growingtk_private_toastQueue == nil) {
        growingtk_private_toastQueue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self,
                                 &GrowingTKToastQueueKey,
                                 growingtk_private_toastQueue,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return growingtk_private_toastQueue;
}

#pragma mark - Events

- (void)growingtk_private_toastTimerDidFinish:(NSTimer *)timer {
    [self growingtk_private_hideToast:(UIView *)timer.userInfo];
}

- (void)growingtk_private_handleToastTapped:(UITapGestureRecognizer *)recognizer {
    UIView *toast = recognizer.view;
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(toast, &GrowingTKToastTimerKey);
    [timer invalidate];

    [self growingtk_private_hideToast:toast fromTap:YES];
}

#pragma mark - Activity Methods

- (void)growingtk_makeToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &GrowingTKToastActivityViewKey);
    if (existingActivityView != nil)
        return;

    GrowingTKToastStyle *style = [GrowingTKToastManager sharedStyle];

    UIView *activityView =
        [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, style.activitySize.width, style.activitySize.height)];
    activityView.center = [self growingtk_private_centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = style.backgroundColor;
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                                     | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = style.cornerRadius;

    if (style.displayShadow) {
        activityView.layer.shadowColor = style.shadowColor.CGColor;
        activityView.layer.shadowOpacity = style.shadowOpacity;
        activityView.layer.shadowRadius = style.shadowRadius;
        activityView.layer.shadowOffset = style.shadowOffset;
    }

    UIActivityIndicatorView *activityIndicatorView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];

    // associate the activity view with self
    objc_setAssociatedObject(self, &GrowingTKToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addSubview:activityView];

    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)growingtk_hideToastActivity {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &GrowingTKToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[GrowingTKToastManager sharedStyle] fadeDuration]
            delay:0.0
            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
            animations:^{
                existingActivityView.alpha = 0.0;
            }
            completion:^(BOOL finished) {
                [existingActivityView removeFromSuperview];
                objc_setAssociatedObject(self, &GrowingTKToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }];
    }
}

#pragma mark - Helpers

- (CGPoint)growingtk_private_centerPointForPosition:(id)point withToast:(UIView *)toast {
    GrowingTKToastStyle *style = [GrowingTKToastManager sharedStyle];

    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInsets = self.safeAreaInsets;
    }

    CGFloat topPadding = style.verticalPadding + safeInsets.top;
    CGFloat bottomPadding = style.verticalPadding + safeInsets.bottom;

    if ([point isKindOfClass:[NSString class]]) {
        if ([point caseInsensitiveCompare:GrowingTKToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2.0, (toast.frame.size.height / 2.0) + topPadding);
        } else if ([point caseInsensitiveCompare:GrowingTKToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }

    // default to bottom
    return CGPointMake(self.bounds.size.width / 2.0,
                       (self.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding);
}

@end

@implementation GrowingTKToastStyle

#pragma mark - Constructors

- (instancetype)initWithDefaultStyle {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.titleColor = [UIColor whiteColor];
        self.messageColor = [UIColor whiteColor];
        self.maxWidthPercentage = 0.8;
        self.maxHeightPercentage = 0.8;
        self.horizontalPadding = 10.0;
        self.verticalPadding = 10.0;
        self.cornerRadius = 10.0;
        self.titleFont = [UIFont boldSystemFontOfSize:16.0];
        self.messageFont = [UIFont systemFontOfSize:16.0];
        self.titleAlignment = NSTextAlignmentLeft;
        self.messageAlignment = NSTextAlignmentLeft;
        self.titleNumberOfLines = 0;
        self.messageNumberOfLines = 0;
        self.displayShadow = NO;
        self.shadowOpacity = 0.8;
        self.shadowRadius = 6.0;
        self.shadowOffset = CGSizeMake(4.0, 4.0);
        self.imageSize = CGSizeMake(80.0, 80.0);
        self.activitySize = CGSizeMake(100.0, 100.0);
        self.fadeDuration = 0.2;
    }
    return self;
}

- (void)setMaxWidthPercentage:(CGFloat)maxWidthPercentage {
    _maxWidthPercentage = MAX(MIN(maxWidthPercentage, 1.0), 0.0);
}

- (void)setMaxHeightPercentage:(CGFloat)maxHeightPercentage {
    _maxHeightPercentage = MAX(MIN(maxHeightPercentage, 1.0), 0.0);
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

@end

@interface GrowingTKToastManager ()

@property (strong, nonatomic) GrowingTKToastStyle *sharedStyle;
@property (assign, nonatomic, getter=isTapToDismissEnabled) BOOL tapToDismissEnabled;
@property (assign, nonatomic, getter=isQueueEnabled) BOOL queueEnabled;
@property (assign, nonatomic) NSTimeInterval defaultDuration;
@property (strong, nonatomic) id defaultPosition;

@end

@implementation GrowingTKToastManager

#pragma mark - Constructors

+ (instancetype)sharedManager {
    static GrowingTKToastManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sharedStyle = [[GrowingTKToastStyle alloc] initWithDefaultStyle];
        self.tapToDismissEnabled = YES;
        self.queueEnabled = NO;
        self.defaultDuration = 1.0;
        self.defaultPosition = GrowingTKToastPositionCenter;
    }
    return self;
}

#pragma mark - Singleton Methods

+ (void)setSharedStyle:(GrowingTKToastStyle *)sharedStyle {
    [[self sharedManager] setSharedStyle:sharedStyle];
}

+ (GrowingTKToastStyle *)sharedStyle {
    return [[self sharedManager] sharedStyle];
}

+ (void)setTapToDismissEnabled:(BOOL)tapToDismissEnabled {
    [[self sharedManager] setTapToDismissEnabled:tapToDismissEnabled];
}

+ (BOOL)isTapToDismissEnabled {
    return [[self sharedManager] isTapToDismissEnabled];
}

+ (void)setQueueEnabled:(BOOL)queueEnabled {
    [[self sharedManager] setQueueEnabled:queueEnabled];
}

+ (BOOL)isQueueEnabled {
    return [[self sharedManager] isQueueEnabled];
}

+ (void)setDefaultDuration:(NSTimeInterval)duration {
    [[self sharedManager] setDefaultDuration:duration];
}

+ (NSTimeInterval)defaultDuration {
    return [[self sharedManager] defaultDuration];
}

+ (void)setDefaultPosition:(id)position {
    if ([position isKindOfClass:[NSString class]] || [position isKindOfClass:[NSValue class]]) {
        [[self sharedManager] setDefaultPosition:position];
    }
}

+ (id)defaultPosition {
    return [[self sharedManager] defaultPosition];
}

@end
