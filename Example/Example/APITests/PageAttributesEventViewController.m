//
//  PVarEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2018/6/5.
//  Copyright (C) 2018 Beijing Yishu Technology Co., Ltd.
//

#import "PageAttributesEventViewController.h"
#import "GIODataProcessOperation.h"
#import "GIOConstants.h"
@interface PageAttributesEventViewController ()

@property (nonatomic, strong) NSDictionary *pageAttributes;

@end

@implementation PageAttributesEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRandomPageAttributes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configRandomPageAttributes {
#if SDK3rd && Autotracker && !SDKCDP
    self.growingPageAttributes = [self getRandomAttributes];
#endif
}

- (IBAction)setPageAttributesBtnClick:(UIButton *)sender {
    [self configRandomPageAttributes];
}

- (IBAction)setPageAttributesOutRangeBtnClick:(UIButton *)sender {
    
    NSDictionary *pval = [GIOConstants getLargeDictionary];
#if SDK3rd && Autotracker && !SDKCDP
    self.growingPageAttributes = pval;
#endif
    NSLog(@"setPageVariable largeDic length is:%ld",pval.count);
}

- (NSDictionary *)getRandomAttributes {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    for (int i = 0; i < 3; i ++) {
        [attributes setObject:[self randomValue] forKey:[self randomKey]];
    }
    return attributes;
}

- (NSString *)randomKey {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:20];
    return [NSString stringWithFormat:@"k_%@", [GIODataProcessOperation randomStringWithLength:l]];
}

- (NSString *)randomValue {
    int l = [GIODataProcessOperation getRandomLengthFrom:5 to:30];
    return [NSString stringWithFormat:@"v_%@", [GIODataProcessOperation randomStringWithLength:l]];
}


@end
