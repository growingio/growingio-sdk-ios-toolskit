//
//  GrowingTKURLProtocol.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/11/4.
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

#import "GrowingTKURLProtocol.h"
#import "GrowingTKNetFlowPlugin.h"
#import "GrowingTKRequestPersistence.h"
#import "GrowingTKSDKUtil.h"

// https://developer.apple.com/library/archive/samplecode/CustomHTTPProtocol/Listings/CustomHTTPProtocol_Core_Code_CustomHTTPProtocol_m.html

static NSString *const kGrowingTKProtocolKey = @"com.growingio.toolskit.CustomHTTPProtocol";

@interface GrowingTKURLProtocol () <NSURLSessionDataDelegate>

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSError *error;

@property (atomic, strong, readwrite) NSURLSessionDataTask *task;

@end

@implementation GrowingTKURLProtocol

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task {
    NSURLRequest *request = task.currentRequest;
    return request == nil ? NO : [self canInitWithRequest:request];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:kGrowingTKProtocolKey inRequest:request]) {
        return NO;
    }

    if (![request.URL.scheme.lowercaseString isEqualToString:@"http"]
        && ![request.URL.scheme.lowercaseString isEqualToString:@"https"]) {
        return NO;
    }
    
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    if (sdk.isSDK2ndGeneration) {
        return [request.URL.absoluteString containsString:sdk.dataCollectionServerHost]
        || [request.URL.absoluteString containsString:@"t.growingio.com"]/* activate */;
    } else {
        return [request.URL.absoluteString containsString:sdk.dataCollectionServerHost];
    }
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *recursiveRequest = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:kGrowingTKProtocolKey inRequest:recursiveRequest];

    NSMutableArray *modes = @[NSDefaultRunLoopMode].mutableCopy;
    NSString *currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if (currentMode && ![currentMode isEqual:NSDefaultRunLoopMode]) {
        [modes addObject:currentMode];
    }

    self.responseData = NSMutableData.data;
    self.startTime = NSDate.date.timeIntervalSince1970 * 1000LL;
    self.task = [GrowingTKNetFlowPlugin.plugin dataTaskWithRequest:recursiveRequest delegate:self modes:modes];
    [self.task resume];
}

- (void)stopLoading {
    [GrowingTKRequestPersistence dealWithRequest:self.request
                                        response:self.response
                                    responseData:self.responseData
                                           error:self.error
                                       startTime:self.startTime
                                  completedBlock:^(GrowingTKRequestPersistence *_Nonnull request) {
        [GrowingTKNetFlowPlugin.plugin insertRequest:request];
    }];
    
    if (self.task) {
        [self.task cancel];
        self.task = nil;
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    self.response = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        self.error = error;
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

@end
