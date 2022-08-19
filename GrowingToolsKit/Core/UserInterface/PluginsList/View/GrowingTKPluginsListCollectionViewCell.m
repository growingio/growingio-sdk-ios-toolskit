//
//  GrowingTKHomeCollectionViewCell.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/16.
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

#import "GrowingTKPluginsListCollectionViewCell.h"
#import "GrowingTKDefine.h"
#import "UIView+GrowingTK.h"
#import "UIImage+GrowingTK.h"
#import "UIColor+GrowingTK.h"

@interface GrowingTKPluginsListCollectionViewCell ()

@property (nonatomic, strong) UIView *icon;
@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *name;

@end

@implementation GrowingTKPluginsListCollectionViewCell

- (UIView *)icon {
    if (!_icon) {
        CGFloat size = GrowingTKSizeFrom750(80);
        _icon = [[UIView alloc] initWithFrame:CGRectMake((self.growingtk_width - size) / 2.0, 4, size, size)];
        _icon.backgroundColor = UIColor.growingtk_secondaryBackgroundColor;
        _icon.layer.cornerRadius = size / 2.0f;
        _icon.layer.masksToBounds = YES;
    }

    return _icon;
}

- (UIImageView *)iconImage {
    if (!_iconImage) {
        CGFloat size = GrowingTKSizeFrom750(80);
        CGFloat margin = 6.0f;
        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, size - margin * 2, size - margin * 2)];
        _iconImage.contentMode = UIViewContentModeScaleAspectFit;
    }

    return _iconImage;
}

- (UILabel *)name {
    if (!_name) {
        CGFloat height = GrowingTKSizeFrom750(32);
        _name = [[UILabel alloc]
            initWithFrame:CGRectMake(0, self.growingtk_height - height - 4, self.growingtk_width, height)];
        _name.textAlignment = NSTextAlignmentCenter;
        _name.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        _name.adjustsFontSizeToFitWidth = YES;
        _name.textColor = UIColor.growingtk_labelColor;
    }

    return _name;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.growingtk_white_1;
        [self addSubview:self.icon];
        [self addSubview:self.name];
        [self.icon addSubview:self.iconImage];
    }
    return self;
}

- (void)update:(NSString *)image name:(NSString *)name isSelected:(BOOL)isSelected {
    self.iconImage.image = [UIImage growingtk_imageNamed:image];
    self.name.text = name;
    self.icon.backgroundColor = isSelected ? UIColor.growingtk_tertiaryBackgroundColor : UIColor.growingtk_secondaryBackgroundColor;
}

@end
