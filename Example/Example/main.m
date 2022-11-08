//
//  main.m
//  GrowingExample
//
//  Created by GrowingIO on 08/04/2020.
//  Copyright (c) 2020 GrowingIO. All rights reserved.
//

@import UIKit;
#import "AppDelegate.h"

int main(int argc, char * argv[])
{
#if defined(SDKAPM)
#if defined(SDK2nd)
    // SDK 2.0 GrowingAspectModeSubClass 与 GrowingAPM SDK 不兼容
    [Growing setAspectMode:GrowingAspectModeDynamicSwizzling];
#endif
#endif
    
#if defined(SDKAPMMODULE)
    [GrowingAPM setupMonitors];
#endif
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
