//
//  GrowingTKNetFlowPlugin.m
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

#import "GrowingTKNetFlowPlugin.h"
#import "GrowingTKUtil.h"
#import "GrowingTKSDKUtil.h"
#import "GrowingTKURLProtocol.h"
#import "GrowingTKDataTaskInfo.h"
#import "GrowingTKDatabase+Request.h"
#import "GrowingTKRequestPersistence.h"
#import "GrowingTKNetFlowViewController.h"

@interface GrowingTKNetFlowPlugin () <NSURLSessionDataDelegate>

@property (atomic, strong, readonly) NSURLSession *session;
@property (atomic, strong, readonly) NSMutableDictionary *taskInfoByTaskID;
@property (atomic, strong, readonly) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) GrowingTKDatabase *db;

@property (nonatomic, assign, readwrite) NSTimeInterval pluginStartTimestamp;
@property (nonatomic, assign, readwrite) NSUInteger requestCount;
@property (nonatomic, assign, readwrite) double totalUploadFlow;
@property (nonatomic, assign, readwrite) NSUInteger requestFailedCount;

@end

@implementation GrowingTKNetFlowPlugin

#pragma mark - Init

+ (instancetype)plugin {
    static GrowingTKNetFlowPlugin *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrowingTKNetFlowPlugin alloc] init];
        instance->_db = [GrowingTKDatabase database];
        [instance->_db createRequestsTable];
        [instance->_db cleanExpiredRequestIfNeeded];

        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
        configuration.protocolClasses = @[GrowingTKURLProtocol.class];
        instance->_sessionDelegateQueue = [[NSOperationQueue alloc] init];
        instance->_sessionDelegateQueue.maxConcurrentOperationCount = 1;
        instance->_sessionDelegateQueue.name = @"GrowingTKURLSessionDemux";
        instance->_session = [NSURLSession sessionWithConfiguration:configuration
                                                           delegate:instance
                                                      delegateQueue:instance->_sessionDelegateQueue];
        instance->_session.sessionDescription = @"GrowingTKURLSessionDemux";

        instance->_taskInfoByTaskID = [NSMutableDictionary dictionary];

        instance->_pluginStartTimestamp = [[NSDate date] timeIntervalSince1970] * 1000LL;
        instance->_requestCount = 0;
        instance->_totalUploadFlow = 0.0f;
        instance->_requestFailedCount = 0;
        [NSURLProtocol registerClass:GrowingTKURLProtocol.class];
        
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(clearAllRequests)
                                                     name:GrowingTKClearAllRequestsNotification
                                                   object:nil];
    });
    return instance;
}

#pragma mark - GrowingTKPluginProtocol

- (NSString *)name {
    return GrowingTKLocalizedString(@"网络记录");
}

- (NSString *)icon {
    return @"growingtk_netFlow";
}

- (NSString *)pluginName {
    return @"GrowingTKNetFlowPlugin";
}

- (NSString *)atModule {
    return GrowingTKDefaultModuleName();
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%@", self.atModule, self.name, self.pluginName];
}

- (void)pluginDidLoad {
    GrowingTKSDKUtil *sdk = GrowingTKSDKUtil.sharedInstance;
    if (sdk.isIntegrated) {
        GrowingTKNetFlowViewController *controller = [[GrowingTKNetFlowViewController alloc] init];
        [GrowingTKHomeWindow openPlugin:controller];
    } else {
        GrowingTKBaseViewController *controller =
            (GrowingTKBaseViewController *)GrowingTKUtil.topViewControllerForHomeWindow;
        [controller showToast:GrowingTKLocalizedString(@"未集成SDK，请参考帮助文档进行集成")];
    }
}

#pragma mark - GrowingTKRequest

- (void)insertRequest:(GrowingTKRequestPersistence *)request {
    [self.db insertRequest:request];
    self.requestCount++;
    if (!(request.statusCode.intValue >= 200 && request.statusCode.intValue < 300)) {
        self.requestFailedCount ++;
    }
    self.totalUploadFlow += request.uploadFlow.doubleValue;
}

- (BOOL)clearAllRequests {
    self.requestCount = 0;
    self.totalUploadFlow = 0.0f;
    self.requestFailedCount = 0;
    return [self.db clearAllRequests];
}

- (NSArray<GrowingTKRequestPersistence *> *)getRequestsWithRequestTimeEarlyThan:(double)requestTime
                                                                       pageSize:(NSUInteger)pageSize {
    return [self.db getRequestsWithRequestTimeEarlyThan:requestTime pageSize:pageSize];
}

#pragma mark - URLSessionDataTask

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                     delegate:(id<NSURLSessionDataDelegate>)delegate
                                        modes:(NSArray *)modes {
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    GrowingTKDataTaskInfo *taskInfo = [[GrowingTKDataTaskInfo alloc] initWithTask:task delegate:delegate modes:modes];
    @synchronized(self) {
        self.taskInfoByTaskID[@(task.taskIdentifier)] = taskInfo;
    }
    return task;
}

- (GrowingTKDataTaskInfo *)taskInfoForTask:(NSURLSessionTask *)task {
    GrowingTKDataTaskInfo *result;
    @synchronized(self) {
        result = self.taskInfoByTaskID[@(task.taskIdentifier)];
    }
    return result;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
                          task:(NSURLSessionTask *)task
    willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                    newRequest:(NSURLRequest *)newRequest
             completionHandler:(void (^)(NSURLRequest *))completionHandler {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:task];
    if ([taskInfo.delegate
            respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session
                                      task:task
                willPerformHTTPRedirection:response
                                newRequest:newRequest
                         completionHandler:completionHandler];
        }];
    } else {
        completionHandler(newRequest);
    }
}

- (void)URLSession:(NSURLSession *)session
                   task:(NSURLSessionTask *)task
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
      completionHandler:
          (void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:task];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session
                                     task:task
                      didReceiveChallenge:challenge
                        completionHandler:completionHandler];
        }];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSession:(NSURLSession *)session
                 task:(NSURLSessionTask *)task
    needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:task];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:needNewBodyStream:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session task:task needNewBodyStream:completionHandler];
        }];
    } else {
        completionHandler(nil);
    }
}

- (void)URLSession:(NSURLSession *)session
                        task:(NSURLSessionTask *)task
             didSendBodyData:(int64_t)bytesSent
              totalBytesSent:(int64_t)totalBytesSent
    totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:task];
    if ([taskInfo.delegate
            respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session
                                     task:task
                          didSendBodyData:bytesSent
                           totalBytesSent:totalBytesSent
                 totalBytesExpectedToSend:totalBytesExpectedToSend];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:task];
    @synchronized(self) {
        [self.taskInfoByTaskID removeObjectForKey:@(taskInfo.task.taskIdentifier)];
    }
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session task:task didCompleteWithError:error];
            [taskInfo invalidate];
        }];
    } else {
        [taskInfo invalidate];
    }
}

- (void)URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:dataTask];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session
                                 dataTask:dataTask
                       didReceiveResponse:response
                        completionHandler:completionHandler];
        }];
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session
                 dataTask:(NSURLSessionDataTask *)dataTask
    didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:dataTask];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didBecomeDownloadTask:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:dataTask];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session dataTask:dataTask didReceiveData:data];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session
             dataTask:(NSURLSessionDataTask *)dataTask
    willCacheResponse:(NSCachedURLResponse *)proposedResponse
    completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    GrowingTKDataTaskInfo *taskInfo;

    taskInfo = [self taskInfoForTask:dataTask];
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
        [taskInfo performBlock:^{
            [taskInfo.delegate URLSession:session
                                 dataTask:dataTask
                        willCacheResponse:proposedResponse
                        completionHandler:completionHandler];
        }];
    } else {
        completionHandler(proposedResponse);
    }
}

@end
