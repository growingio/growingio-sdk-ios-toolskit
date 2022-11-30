//
//  GrowingTKPluginsListViewController.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/6.
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

#import "GrowingTKPluginsListViewController.h"
#import "GrowingRealToolsKit.h"
#import "UIViewController+GrowingTK.h"
#import "UIColor+GrowingTK.h"

#import "GrowingTKPluginsListCollectionViewCell.h"
#import "GrowingTKPluginsListHeaderView.h"
#import "GrowingTKPluginsListFooterView.h"

#import "GrowingTKPluginProtocol.h"
#import "GrowingTKPluginManager.h"

static NSString *GrowingTKPluginsListCellID = @"GrowingTKPluginsListCellID";
static NSString *GrowingTKPluginsListHeaderID = @"GrowingTKPluginsListHeaderID";
static NSString *GrowingTKPluginsListFooterID = @"GrowingTKPluginsListFooterID";

@interface GrowingTKPluginsListViewController () <
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation GrowingTKPluginsListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = GrowingToolsKitName;

    self.dataSource = [GrowingTKPluginManager sharedInstance].dataArray.mutableCopy;
    [self.view addSubview:self.collectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(realtimeStatusNotification:)
                                                 name:GrowingTKRealtimeStatusNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.growingtk_fullscreen;
}

#pragma mark - Notification

- (void)realtimeStatusNotification:(NSNotification *)not {
    NSString *key = not.userInfo[@"key"];
    NSString *name = not.userInfo[@"name"];
    NSNumber *isSelected = not.userInfo[@"isSelected"];
    NSMutableArray *dataSourceM = [NSMutableArray arrayWithArray:self.dataSource];
    for (int i = 0; i < dataSourceM.count; i++) {
        NSMutableDictionary *sectionM = ((NSDictionary *)dataSourceM[i]).mutableCopy;
        NSMutableArray *pluginArrayM = ((NSArray *)sectionM[@"pluginArray"]).mutableCopy;
        
        BOOL haveFound = NO;
        for (int j = 0; j < pluginArrayM.count; j++) {
            NSMutableDictionary *item = ((NSDictionary *)pluginArrayM[j]).mutableCopy;
            if ([item[@"key"] isEqualToString:key]) {
                item[@"name"] = name;
                item[@"isSelected"] = isSelected;
                pluginArrayM[j] = item.copy;
                haveFound = YES;
                break;
            }
        }
        
        if (haveFound) {
            sectionM[@"pluginArray"] = pluginArrayM.copy;
            dataSourceM[i] = sectionM.copy;
            break;
        }
    }
    self.dataSource = dataSourceM.copy;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView DataSource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)self.dataSource[section][@"pluginArray"]).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GrowingTKPluginsListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GrowingTKPluginsListCellID
                                                                                      forIndexPath:indexPath];
    NSArray *pluginArray = self.dataSource[indexPath.section][@"pluginArray"];
    NSDictionary *item = pluginArray[indexPath.item];
    [cell update:item[@"icon"] name:item[@"name"] isSelected:((NSNumber *)item[@"isSelected"]).boolValue];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        GrowingTKPluginsListHeaderView *head =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                               withReuseIdentifier:GrowingTKPluginsListHeaderID
                                                      forIndexPath:indexPath];
        NSDictionary *dict = self.dataSource[indexPath.section];
        [head renderUIWithTitle:dict[@"moduleName"]];
        view = head;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        GrowingTKPluginsListFooterView *foot =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                               withReuseIdentifier:GrowingTKPluginsListFooterID
                                                      forIndexPath:indexPath];
        if (indexPath.section == (self.dataSource.count - 1)) {
            NSString *str = GrowingTKLocalizedString(@"当前版本");
            NSString *last = [NSString stringWithFormat:@"%@：V%@", str, [GrowingRealToolsKit version]];
            foot.title.text = last;
            foot.title.textColor = UIColor.growingtk_black_3;
            foot.title.textAlignment = NSTextAlignmentCenter;
            foot.title.font = [UIFont systemFontOfSize:GrowingTKSizeFrom750(24)];
        } else {
            foot.title.text = nil;
        }

        foot.backgroundColor = UIColor.growingtk_bg_2;
        view = foot;
    } else {
        view = [[UICollectionReusableView alloc] init];
    }

    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *pluginArray = self.dataSource[indexPath.section][@"pluginArray"];
    NSDictionary *itemData = pluginArray[indexPath.item];
    NSString *pluginName = itemData[@"pluginName"];
    if (pluginName) {
        Class pluginClass = NSClassFromString(pluginName);
        
        id<GrowingTKPluginProtocol> plugin;
        if ([pluginClass respondsToSelector:@selector(plugin)]) {
            plugin = [pluginClass plugin];
        } else {
            plugin = [[pluginClass alloc] init];
        }
        
        if ([plugin respondsToSelector:@selector(pluginDidLoad)]) {
            [plugin pluginDidLoad];
        } else if ([plugin respondsToSelector:@selector(pluginDidLoad:)]) {
            [plugin pluginDidLoad:itemData];
        }
    }
}

#pragma mark - UICollectionLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(GrowingTKSizeFrom750(160), GrowingTKSizeFrom750(136));
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(GrowingTKScreenWidth, GrowingTKSizeFrom750(88));
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(GrowingTKScreenWidth, GrowingTKSizeFrom750(section == (self.dataSource.count - 1) ? 80 : 24));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, GrowingTKSizeFrom750(24), GrowingTKSizeFrom750(24), GrowingTKSizeFrom750(24));
}

#pragma mark - Getter & Setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fl];
        _collectionView.backgroundColor = UIColor.growingtk_white_1;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[GrowingTKPluginsListCollectionViewCell class]
            forCellWithReuseIdentifier:GrowingTKPluginsListCellID];
        [_collectionView registerClass:[GrowingTKPluginsListHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:GrowingTKPluginsListHeaderID];
        [_collectionView registerClass:[GrowingTKPluginsListFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:GrowingTKPluginsListFooterID];
    }
    return _collectionView;
}

@end
