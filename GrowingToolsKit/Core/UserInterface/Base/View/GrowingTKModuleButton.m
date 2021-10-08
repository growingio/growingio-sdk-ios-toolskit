//
//  GrowingTKModuleButton.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/9.
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

#import "GrowingTKModuleButton.h"
#import "GrowingTKDefine.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"

#define MODULE_BUTTON_CONTAINER_PADDING 7.0f
#define MODULE_BUTTON_IMAGE_PADDING_PLUGINS 5.0f
#define MODULE_BUTTON_IMAGE_PADDING_CHECKSELF 3.0f

#define MODULE_BUTTON_IMAGE_PLUGINS [UIImage growingtk_imageNamed:@"growingtk_plugins"]
#define MODULE_BUTTON_IMAGE_CHECKSELF [UIImage growingtk_imageNamed:@"growingtk_logo"]

@interface GrowingTKModuleButton ()

@property (nonatomic, strong) UIImageView *kImageView;

@end

@implementation GrowingTKModuleButton

+ (instancetype)moduleButtonWithType:(GrowingTKModule)module {
    CGFloat sideLength = ENTRY_SIDELENGTH;
    CGFloat padding = MODULE_BUTTON_CONTAINER_PADDING;
    CGFloat containViewSideLength = sideLength - padding * 2;
    CGFloat imagePadding =
        module == GrowingTKModulePlugins ? MODULE_BUTTON_IMAGE_PADDING_PLUGINS : MODULE_BUTTON_IMAGE_PADDING_CHECKSELF;

    GrowingTKModuleButton *button = [GrowingTKModuleButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, sideLength, sideLength);
    button.backgroundColor = UIColor.growingtk_primaryBackgroundColor;
    button.layer.cornerRadius = sideLength / 2;
    button.layer.masksToBounds = YES;

    UIView *view =
        [[UIView alloc] initWithFrame:CGRectMake(padding, padding, containViewSideLength, containViewSideLength)];
    view.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;
    view.layer.cornerRadius = containViewSideLength / 2;
    view.layer.masksToBounds = YES;
    view.userInteractionEnabled = NO;
    [button addSubview:view];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imagePadding,
                                                                           imagePadding,
                                                                           containViewSideLength - imagePadding * 2,
                                                                           containViewSideLength - imagePadding * 2)];
    imageView.image = module == GrowingTKModulePlugins ? MODULE_BUTTON_IMAGE_PLUGINS : MODULE_BUTTON_IMAGE_CHECKSELF;
    [view addSubview:imageView];
    button.kImageView = imageView;

    return button;
}

- (void)toggle:(GrowingTKModule)module {
    CGFloat sideLength = ENTRY_SIDELENGTH;
    CGFloat padding = MODULE_BUTTON_CONTAINER_PADDING;
    CGFloat containViewSideLength = sideLength - padding * 2;
    CGFloat imagePadding = MODULE_BUTTON_IMAGE_PADDING_PLUGINS;
    UIImage *image = MODULE_BUTTON_IMAGE_PLUGINS;

    switch (module) {
        case GrowingTKModulePlugins: {
            imagePadding = MODULE_BUTTON_IMAGE_PADDING_PLUGINS;
            image = MODULE_BUTTON_IMAGE_PLUGINS;
        } break;
        case GrowingTKModuleCheckSelf: {
            imagePadding = MODULE_BUTTON_IMAGE_PADDING_CHECKSELF;
            image = MODULE_BUTTON_IMAGE_CHECKSELF;
        } break;
        default:
            break;
    }

    self.kImageView.frame = CGRectMake(imagePadding,
                                       imagePadding,
                                       containViewSideLength - imagePadding * 2,
                                       containViewSideLength - imagePadding * 2);
    self.kImageView.image = image;
}

@end
