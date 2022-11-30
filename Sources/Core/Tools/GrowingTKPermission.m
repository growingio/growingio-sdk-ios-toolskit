//
//  GrowingTKPermission.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/8/17.
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

#import "GrowingTKPermission.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>
#import <CoreTelephony/CTCellularData.h>

@implementation GrowingTKPermission

static CTCellularData *cellularData;

+ (void)startListenToNetworkPermissionDidUpdate:(void(^)(GrowingTKAuthorizationStatus status))didUpdateBlock {
    if (!didUpdateBlock) {
        return;
    }
    
    if (!cellularData) {
        cellularData = [[CTCellularData alloc] init];
    }
    
    cellularData.cellularDataRestrictionDidUpdateNotifier =  ^(CTCellularDataRestrictedState state) {
        GrowingTKAuthorizationStatus result = GrowingTKAuthorizationStatusNotDetermined;
        switch (state) {
            case kCTCellularDataRestrictedStateUnknown:
                result = GrowingTKAuthorizationStatusNotDetermined;
                break;
            case kCTCellularDataRestricted:
                result = GrowingTKAuthorizationStatusRestricted;
                break;
            case kCTCellularDataNotRestricted:
                result = GrowingTKAuthorizationStatusAuthorized;
                break;
            default:
                break;
        }
        if (didUpdateBlock) {
            didUpdateBlock(result);
        }
    };
}

+ (void)stopListenToNetworkPermission {
    cellularData.cellularDataRestrictionDidUpdateNotifier = nil;
    cellularData = nil;
}

+ (GrowingTKAuthorizationStatus)locationPermission {
    GrowingTKAuthorizationStatus result = GrowingTKAuthorizationStatusNotDetermined;
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
                result = GrowingTKAuthorizationStatusNotDetermined;
                break;
            case kCLAuthorizationStatusRestricted:
                result = GrowingTKAuthorizationStatusRestricted;
                break;
            case kCLAuthorizationStatusDenied:
                result = GrowingTKAuthorizationStatusDenied;
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                result = GrowingTKAuthorizationStatusAlways;
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                result = GrowingTKAuthorizationStatusWhenInUse;
                break;
            default:
                break;
        }
    } else {
        // Users disable location services by toggling the Location Services switch in Settings > Privacy.
        result = GrowingTKAuthorizationStatusDisabled;
    }
    return result;
}

+ (GrowingTKAuthorizationStatus)pushPermission {
    return UIApplication.sharedApplication.currentUserNotificationSettings.types == UIUserNotificationTypeNone
               ? GrowingTKAuthorizationStatusDenied
               : GrowingTKAuthorizationStatusAuthorized;
}

+ (GrowingTKAuthorizationStatus)cameraPermission {
    GrowingTKAuthorizationStatus result = GrowingTKAuthorizationStatusNotDetermined;
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            result = GrowingTKAuthorizationStatusNotDetermined;
            break;
        case AVAuthorizationStatusRestricted:
            result = GrowingTKAuthorizationStatusRestricted;
            break;
        case AVAuthorizationStatusDenied:
            result = GrowingTKAuthorizationStatusDenied;
            break;
        case AVAuthorizationStatusAuthorized:
            result = GrowingTKAuthorizationStatusAuthorized;
            break;
        default:
            break;
    }
    return result;
}

+ (GrowingTKAuthorizationStatus)audioPermission {
    GrowingTKAuthorizationStatus result = GrowingTKAuthorizationStatusNotDetermined;
    NSString *mediaType = AVMediaTypeAudio;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            result = GrowingTKAuthorizationStatusNotDetermined;
            break;
        case AVAuthorizationStatusRestricted:
            result = GrowingTKAuthorizationStatusRestricted;
            break;
        case AVAuthorizationStatusDenied:
            result = GrowingTKAuthorizationStatusDenied;
            break;
        case AVAuthorizationStatusAuthorized:
            result = GrowingTKAuthorizationStatusAuthorized;
            break;
        default:
            break;
    }
    return result;
}

+ (GrowingTKAuthorizationStatus)photoPermission {
    GrowingTKAuthorizationStatus result = GrowingTKAuthorizationStatusNotDetermined;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
            result = GrowingTKAuthorizationStatusNotDetermined;
            break;
        case PHAuthorizationStatusRestricted:
            result = GrowingTKAuthorizationStatusRestricted;
            break;
        case PHAuthorizationStatusDenied:
            result = GrowingTKAuthorizationStatusDenied;
            break;
        case PHAuthorizationStatusAuthorized:
            result = GrowingTKAuthorizationStatusAuthorized;
            break;
        default:
            break;
    }
    return result;
}

+ (GrowingTKAuthorizationStatus)contactsPermission {
    GrowingTKAuthorizationStatus result = GrowingTKAuthorizationStatusNotDetermined;
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusNotDetermined:
            result = GrowingTKAuthorizationStatusNotDetermined;
            break;
        case CNAuthorizationStatusRestricted:
            result = GrowingTKAuthorizationStatusRestricted;
            break;
        case CNAuthorizationStatusDenied:
            result = GrowingTKAuthorizationStatusDenied;
            break;
        case CNAuthorizationStatusAuthorized:
            result = GrowingTKAuthorizationStatusAuthorized;
            break;
        default:
            break;
    }
    return result;
}

+ (GrowingTKAuthorizationStatus)calendarPermission {
    GrowingTKAuthorizationStatus result = GrowingTKAuthorizationStatusNotDetermined;
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
            result = GrowingTKAuthorizationStatusNotDetermined;
            break;
        case EKAuthorizationStatusRestricted:
            result = GrowingTKAuthorizationStatusRestricted;
            break;
        case EKAuthorizationStatusDenied:
            result = GrowingTKAuthorizationStatusDenied;
            break;
        case EKAuthorizationStatusAuthorized:
            result = GrowingTKAuthorizationStatusAuthorized;
            break;
        default:
            break;
    }
    return result;
}

+ (GrowingTKAuthorizationStatus)notesPermission {
    GrowingTKAuthorizationStatus result = GrowingTKAuthorizationStatusNotDetermined;
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
            result = GrowingTKAuthorizationStatusNotDetermined;
            break;
        case EKAuthorizationStatusRestricted:
            result = GrowingTKAuthorizationStatusRestricted;
            break;
        case EKAuthorizationStatusDenied:
            result = GrowingTKAuthorizationStatusDenied;
            break;
        case EKAuthorizationStatusAuthorized:
            result = GrowingTKAuthorizationStatusAuthorized;
            break;
        default:
            break;
    }
    return result;
}

@end
