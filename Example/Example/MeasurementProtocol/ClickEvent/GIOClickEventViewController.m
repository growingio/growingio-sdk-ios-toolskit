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
#if defined(AUTOTRACKER)
#if !defined(SDKCDP) && defined(SDK3rd)
//    self.growingPageAttributes = @{@"greet": @"hello"};
#elif defined(SDK2nd)
    [Growing setPageVariable:@{@"greet": @"hello"} toViewController:self];
#endif
#endif
    
#if defined(AUTOTRACKER)
#if defined(SDK3rd)
//    self.growingPageIgnorePolicy = GrowingIgnoreSelf;
    self.segmentControl.growingUniqueTag = @"language-selector";
//    [self.sendEventButton growingTrackImpression:@"hello_track_impression"];
//    [self.view growingTrackImpression:@"self_view_imp_track" attributes:@{@"self_view_key": @"self_view_value"}];
#elif defined(SDK2nd)
    self.segmentControl.growingAttributesUniqueTag = @"language-selector";
    [self.sendEventButton growingImpTrack:@"hello_track_impression"];
    [self.view growingImpTrack:@"self_view_imp_track" withVariable:@{@"self_view_key": @"self_view_value"}];
#endif
#endif
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
