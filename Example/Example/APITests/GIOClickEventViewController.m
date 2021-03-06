//
//  GIOClickEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2020/2/26.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOClickEventViewController.h"
#import "AppDelegate.h"

@interface GIOClickEventViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIButton *sendEventButton;
@property (weak, nonatomic) IBOutlet UISwitch *trackEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *uploadEnabledSwitch;

@end

@implementation GIOClickEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if SDK3rd && Autotracker
     self.segmentControl.growingUniqueTag = @"language-selector";
#if !SDKCDP
     self.growingPageAttributes = @{@"greet": @"hello"};
#endif
    self.growingPageIgnorePolicy = GrowingIgnoreChildren;
    
   self.parentViewController.growingPageIgnorePolicy = GrowingIgnoreAll;
    [self.sendEventButton growingTrackImpression:@"hello_track_impression"];
    [self.view growingTrackImpression:@"self_view_imp_track" attributes:@{@"self_view_key": @"self_view_value"}];
#endif
    if ([UIApplication.sharedApplication.delegate isKindOfClass:AppDelegate.class]) {
        AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
//        [self.trackEnabledSwitch setOn:appDelegate.configuation.dataTrackEnabled animated:YES];
//        [self.uploadEnabledSwitch setOn:appDelegate.configuation.dataUploadEnabled animated:YES];
    }
}

- (IBAction)buttonClick:(UIButton *)sender {
    NSLog(@"func = %s, line = %d", __func__, __LINE__);
}

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    NSLog(@"func = %s, line = %d", __func__, __LINE__);
}

- (IBAction)singleTapHandle:(UITapGestureRecognizer *)sender {
    NSLog(@"func = %s, line = %d", __func__, __LINE__);
}

- (IBAction)doubleTapHandle:(UITapGestureRecognizer *)sender {
    NSLog(@"func = %s, line = %d", __func__, __LINE__);
}

- (IBAction)trackSwitchValueChange:(UISwitch *)sender {
//    [Growing setDataTrackEnabled:sender.isOn];
    NSLog(@"setDataTrackEnabled: %@", (sender.isOn ? @"YES" : @"NO"));
}

- (IBAction)uploadSwitchValueChange:(UISwitch *)sender {
//    [Growing setDataUploadEnabled:sender.isOn];
    NSLog(@"setDataUploadEnabled: %@", (sender.isOn ? @"YES" : @"NO"));
}

@end
