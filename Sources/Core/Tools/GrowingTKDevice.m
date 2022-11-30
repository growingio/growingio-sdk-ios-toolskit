//
//  GrowingTKDevice.m
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

//参考：
//[List of iPhones](https://www.theiphonewiki.com/wiki/List_of_iPhones)
//[adamawolf/Apple_mobile_device_types.txt](https://gist.github.com/adamawolf/3048717)
//[DeviceKit](https://github.com/devicekit/DeviceKit/blob/master/Source/Device.generated.swift)

#import "GrowingTKDevice.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#define IOS_CELLULAR @"pdp_ip0"
#define IOS_WIFI @"en0"
#define IOS_VPN @"utun0"
#define IP_ADDR_IPv4 @"ipv4"
#define IP_ADDR_IPv6 @"ipv6"

@implementation GrowingTKDevice

+ (NSString *)deviceName {
    return [UIDevice currentDevice].name;
}

+ (NSString *)deviceSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (BOOL)isSimulator {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    return ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"] ||
            [platform isEqualToString:@"arm64"]);
}

+ (BOOL)isiPad {
    NSString *deviceType = [UIDevice currentDevice].model;
    return [deviceType isEqualToString:@"iPad"];
}

+ (BOOL)isBangsScreen {
    NSString *platform = [self platform];
    return ([platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"] ||
            [platform isEqualToString:@"iPhone11,2"] || [platform isEqualToString:@"iPhone11,4"] ||
            [platform isEqualToString:@"iPhone11,6"] || [platform isEqualToString:@"iPhone11,8"] ||
            [platform isEqualToString:@"iPhone12,1"] || [platform isEqualToString:@"iPhone12,3"] ||
            [platform isEqualToString:@"iPhone12,5"] || [platform isEqualToString:@"iPhone13,1"] ||
            [platform isEqualToString:@"iPhone13,2"] || [platform isEqualToString:@"iPhone13,3"] ||
            [platform isEqualToString:@"iPhone13,4"] || [platform isEqualToString:@"iPhone14,5"] ||
            [platform isEqualToString:@"iPhone14,4"] || [platform isEqualToString:@"iPhone14,2"] ||
            [platform isEqualToString:@"iPhone14,3"]);
}

+ (NSString *)platform {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"] ||
        [platform isEqualToString:@"arm64"]) {
        NSString *simulatorModelID = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
        if (simulatorModelID && simulatorModelID.length > 0) {
            return simulatorModelID;
        } else {
            return @"iOS";
        }
    }
    return platform;
}

+ (NSString *)platformString {
    NSString *platform = [self platform];

    // iPhone
    if ([platform isEqualToString:@"iPhone3,1"] || [platform isEqualToString:@"iPhone3,2"] ||
        [platform isEqualToString:@"iPhone3,3"])
        return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])
        return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"])
        return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"])
        return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"])
        return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"])
        return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])
        return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])
        return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])
        return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])
        return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"] || [platform isEqualToString:@"iPhone9,3"])
        return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"] || [platform isEqualToString:@"iPhone9,4"])
        return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"] || [platform isEqualToString:@"iPhone10,4"])
        return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"] || [platform isEqualToString:@"iPhone10,5"])
        return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"])
        return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,2"])
        return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"])
        return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,8"])
        return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone12,1"])
        return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"])
        return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"])
        return @"iPhone 11 Pro Max";
    if ([platform isEqualToString:@"iPhone12,8"])
        return @"iPhone SE 2";
    if ([platform isEqualToString:@"iPhone13,1"])
        return @"iPhone 12 Mini";
    if ([platform isEqualToString:@"iPhone13,2"])
        return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"])
        return @"iPhone 12 Pro";
    if ([platform isEqualToString:@"iPhone13,4"])
        return @"iPhone 12 Pro Max";
    if ([platform isEqualToString:@"iPhone14,4"])
        return @"iPhone 13 Mini";
    if ([platform isEqualToString:@"iPhone14,5"])
        return @"iPhone 13";
    if ([platform isEqualToString:@"iPhone14,2"])
        return @"iPhone 13 Pro";
    if ([platform isEqualToString:@"iPhone14,3"])
        return @"iPhone 13 Pro Max";

    // iPad
    if ([platform isEqualToString:@"iPad2,1"] || [platform isEqualToString:@"iPad2,2"] ||
        [platform isEqualToString:@"iPad2,3"] || [platform isEqualToString:@"iPad2,4"])
        return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"] || [platform isEqualToString:@"iPad2,6"] ||
        [platform isEqualToString:@"iPad2,7"])
        return @"iPad Mini";
    if ([platform isEqualToString:@"iPad3,1"] || [platform isEqualToString:@"iPad3,2"] ||
        [platform isEqualToString:@"iPad3,3"])
        return @"iPad (3rd generation)";
    if ([platform isEqualToString:@"iPad3,4"] || [platform isEqualToString:@"iPad3,5"] ||
        [platform isEqualToString:@"iPad3,6"])
        return @"iPad (4th generation)";
    if ([platform isEqualToString:@"iPad4,1"] || [platform isEqualToString:@"iPad4,2"] ||
        [platform isEqualToString:@"iPad4,3"])
        return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"] || [platform isEqualToString:@"iPad4,5"] ||
        [platform isEqualToString:@"iPad4,6"])
        return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,7"] || [platform isEqualToString:@"iPad4,8"] ||
        [platform isEqualToString:@"iPad4,9"])
        return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad5,1"] || [platform isEqualToString:@"iPad5,2"])
        return @"iPad Mini 4";
    if ([platform isEqualToString:@"iPad5,3"] || [platform isEqualToString:@"iPad5,4"])
        return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad6,3"] || [platform isEqualToString:@"iPad6,4"])
        return @"iPad Pro (9.7-inch)";
    if ([platform isEqualToString:@"iPad6,7"] || [platform isEqualToString:@"iPad6,8"])
        return @"iPad Pro (12.9-inch)";
    if ([platform isEqualToString:@"iPad6,11"] || [platform isEqualToString:@"iPad6,12"])
        return @"iPad (5th generation)";
    if ([platform isEqualToString:@"iPad7,1"] || [platform isEqualToString:@"iPad7,2"])
        return @"iPad Pro (12.9-inch) (2nd generation)";
    if ([platform isEqualToString:@"iPad7,3"] || [platform isEqualToString:@"iPad7,4"])
        return @"iPad Pro (10.5-inch)";
    if ([platform isEqualToString:@"iPad7,5"] || [platform isEqualToString:@"iPad7,6"])
        return @"iPad (6th generation)";
    if ([platform isEqualToString:@"iPad7,11"] || [platform isEqualToString:@"iPad7,12"])
        return @"iPad (7th generation)";
    if ([platform isEqualToString:@"iPad8,1"] || [platform isEqualToString:@"iPad8,2"] ||
        [platform isEqualToString:@"iPad8,3"] || [platform isEqualToString:@"iPad8,4"])
        return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,5"] || [platform isEqualToString:@"iPad8,6"] ||
        [platform isEqualToString:@"iPad8,7"] || [platform isEqualToString:@"iPad8,8"])
        return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([platform isEqualToString:@"iPad8,9"] || [platform isEqualToString:@"iPad8,10"])
        return @"iPad Pro (11-inch) (2nd generation)";
    if ([platform isEqualToString:@"iPad8,11"] || [platform isEqualToString:@"iPad8,12"])
        return @"iPad Pro (12.9-inch) (4th generation)";
    if ([platform isEqualToString:@"iPad11,1"] || [platform isEqualToString:@"iPad11,2"])
        return @"iPad Mini (5th generation)";
    if ([platform isEqualToString:@"iPad11,3"] || [platform isEqualToString:@"iPad11,4"])
        return @"iPad Air (3rd generation)";
    if ([platform isEqualToString:@"iPad11,6"] || [platform isEqualToString:@"iPad11,7"])
        return @"iPad (8th generation)";
    if ([platform isEqualToString:@"iPad13,1"] || [platform isEqualToString:@"iPad13,2"])
        return @"iPad Air (4th generation)";
    if ([platform isEqualToString:@"iPad13,4"] || [platform isEqualToString:@"iPad13,5"] ||
        [platform isEqualToString:@"iPad13,6"] || [platform isEqualToString:@"iPad13,7"])
        return @"iPad Pro (11-inch) (3rd generation)";
    if ([platform isEqualToString:@"iPad13,8"] || [platform isEqualToString:@"iPad13,9"] ||
        [platform isEqualToString:@"iPad13,10"] || [platform isEqualToString:@"iPad13,11"])
        return @"iPad Pro (12.9-inch) (5th generation)";
    if ([platform isEqualToString:@"iPad12,1"] || [platform isEqualToString:@"iPad12,2"])
        return @"iPad (9th generation)";
    if ([platform isEqualToString:@"iPad14,1"] || [platform isEqualToString:@"iPad14,2"])
        return @"iPad Mini (6th generation)";

    return platform;
}

@end

@implementation GrowingTKDevice (IP)

+ (NSString *)IPv4Address {
    return [self searchIPAddress:@[
        /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/
        IOS_WIFI @"/" IP_ADDR_IPv4,
        IOS_WIFI @"/" IP_ADDR_IPv6,
        IOS_CELLULAR @"/" IP_ADDR_IPv4,
        IOS_CELLULAR @"/" IP_ADDR_IPv6
    ]];
}

+ (NSString *)IPv6Address {
    return [self searchIPAddress:@[
        /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/
        IOS_WIFI @"/" IP_ADDR_IPv6,
        IOS_WIFI @"/" IP_ADDR_IPv4,
        IOS_CELLULAR @"/" IP_ADDR_IPv6,
        IOS_CELLULAR @"/" IP_ADDR_IPv4
    ]];
}

+ (NSString *)searchIPAddress:(NSArray *)searchArray {
    NSDictionary *addresses = [self getIPAddresses];
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        if (address) {
            *stop = YES;
        }
    }];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];

    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if (!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for (interface = interfaces; interface; interface = interface->ifa_next) {
            if (!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */) {
                continue;  // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in *)interface->ifa_addr;
            char addrBuf[MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)];
            if (addr && (addr->sin_family == AF_INET || addr->sin_family == AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if (addr->sin_family == AF_INET) {
                    if (inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6 *)interface->ifa_addr;
                    if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
