//
//  GrowingTKRequestPersistence.m
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

#import "GrowingTKRequestPersistence.h"
#import "GrowingTKUtil.h"
#import "GrowingTKDateUtil.h"
#import "GrowingTKRequestUtil.h"
#import "GrowingTKNetFlowPlugin.h"

@interface GrowingTKRequestPersistence ()

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) NSURLResponse *response;
@property (nonatomic, copy) NSData *responseData;
@property (nonatomic, copy, readwrite) NSString *rawJsonString;

@end

@implementation GrowingTKRequestPersistence

#pragma mark - Init

+ (void)dealWithRequest:(NSURLRequest *)request
               response:(NSURLResponse *)response
           responseData:(NSData *)responseData
              startTime:(NSTimeInterval)startTime
         completedBlock:(void(^)(GrowingTKRequestPersistence *))completedBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        GrowingTKRequestPersistence *persistence = [[GrowingTKRequestPersistence alloc] init];
        persistence->_request = request;
        persistence->_response = response;
        persistence->_responseData = responseData;
        persistence->_startTimestamp = startTime;
        
        persistence->_url = request.URL.absoluteString;
        persistence->_method = request.HTTPMethod;
        persistence->_requestHeader = request.allHTTPHeaderFields;
        persistence->_startTime = [GrowingTKDateUtil.sharedInstance timeStringFromTimestamp:startTime];
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        persistence->_statusCode = [NSString stringWithFormat:@"%d",(int)httpResponse.statusCode];
        persistence->_mineType = httpResponse.MIMEType;
        persistence->_endTimestamp = [[NSDate date] timeIntervalSince1970];
        persistence->_totalDuration = [NSString stringWithFormat:@"%f", persistence->_endTimestamp - persistence->_startTimestamp];
        persistence->_responseBody = [GrowingTKUtil convertJsonFromData:responseData] ?: @"";
        persistence->_responseHeader = httpResponse.allHeaderFields;
        persistence->_downFlow = [NSString stringWithFormat:@"%lli", [GrowingTKRequestUtil responseLengthForResponse:httpResponse
                                                                                                        responseData:responseData]];
        
        persistence->_viewController = NSStringFromClass(GrowingTKUtil.topViewControllerForKeyWindow.class);
        
        NSData *httpBody = request.HTTPBody;
        GrowingTKStreamEventEndBlock block = ^(NSData *body) {
            if (persistence->_requestHeader[@"X-Crypt-Codec"]) {
                NSURLComponents *components = [[NSURLComponents alloc] initWithString:persistence->_url];
                unsigned long long timestamp = 0;
                for (NSURLQueryItem *item in components.queryItems) {
                    if ([item.name isEqualToString:@"stm"]) {
                        timestamp = item.value.longLongValue;
                        break;
                    }
                }
                body = [GrowingTKRequestUtil decryptData:body factor:timestamp & 0xFF];
            }
            if (persistence->_requestHeader[@"X-Compress-Codec"]) {
                body = [GrowingTKRequestUtil uncompressData:body];
            }
            persistence->_requestBody = [GrowingTKUtil convertJsonFromData:body] ?: @"";
            NSUInteger length = [GrowingTKRequestUtil headersLengthForRequest:persistence->_request] + body.length;
            persistence->_uploadFlow = [NSString stringWithFormat:@"%zi", length];
            [persistence generateJsonString];
            
            if (completedBlock) {
                completedBlock(persistence);
            }
        };
        if (!httpBody) {
            if ([request.HTTPMethod isEqualToString:@"POST"]) {
                GrowingTKNetFlowPlugin.plugin.streamEndBlock = block;
                NSInputStream *stream = request.HTTPBodyStream;
                [stream setDelegate:GrowingTKNetFlowPlugin.plugin];
                [stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                [stream open];
            }
        } else {
            block(httpBody);
        }
    });
}

- (instancetype)initWithRequestBody:(NSString *)requestBody
                       responseBody:(NSString *)responseBody
                         jsonString:(NSString *)jsonString {
    if (self = [super init]) {
        _requestBody = requestBody;
        _responseBody = responseBody;
        _rawJsonString = jsonString;
        
        NSData *jsonData = [_rawJsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        
        _url = dictionary[@"url"];
        _method = dictionary[@"method"];
        _requestHeader = dictionary[@"requestHeader"];
        _responseHeader = dictionary[@"responseHeader"];
        _statusCode = dictionary[@"statusCode"];
        _mineType = dictionary[@"mineType"];
        _startTime = dictionary[@"startTime"];
        _startTimestamp = ((NSNumber *)dictionary[@"startTimestamp"]).doubleValue;
        _endTimestamp = ((NSNumber *)dictionary[@"endTimestamp"]).doubleValue;
        _totalDuration = dictionary[@"totalDuration"];
        _uploadFlow = dictionary[@"uploadFlow"];
        _downFlow = dictionary[@"downFlow"];
        _viewController = dictionary[@"viewController"];
    }
    
    return self;
}

- (void)generateJsonString {
    NSDictionary *dictionary = @{
        @"url" : _url,
        @"method" : _method,
        @"requestHeader" : _requestHeader,
        @"responseHeader" : _responseHeader,
        @"statusCode" : _statusCode,
        @"mineType" : _mineType,
        @"startTime" : _startTime,
        @"startTimestamp" : @(_startTimestamp),
        @"endTimestamp" : @(_endTimestamp),
        @"totalDuration" : _totalDuration,
        @"uploadFlow" : _uploadFlow,
        @"downFlow" : _downFlow,
        @"viewController" : _viewController
    };
    _rawJsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictionary
                                                                                    options:NSJSONWritingPrettyPrinted
                                                                                      error:nil]
                                       encoding:NSUTF8StringEncoding];
}

#pragma mark - Getter & Setter

- (NSString *)status {
    switch (_statusCode.integerValue) {
        case 200:
            return @"OK";
        case 201:
            return @"Created";
        case 202:
            return @"Accepted";
        case 204:
            return @"No Content";
        case 300:
            return @"Multiple Choices";
        case 301:
            return @"Moved Permanently";
        case 302:
            return @"Found";
        case 303:
            return @"See Other";
        case 304:
            return @"Not Modified";
        case 307:
            return @"Temporary Redirect";
        case 400:
            return @"Bad Request";
        case 401:
            return @"Unauthorized";
        case 403:
            return @"Forbidden";
        case 404:
            return @"Not Found";
        case 405:
            return @"Method Not Allowed";
        case 409:
            return @"Conflict";
        case 412:
            return @"Precondition Failed";
        case 422:
            return @"UnProcessable Entity";
        case 500:
            return @"Server Error";
        case 502:
            return @"Bad Gateway";
        case 503:
            return @"Service Unavailable";
        default:
            return nil;
    }
}

@end
