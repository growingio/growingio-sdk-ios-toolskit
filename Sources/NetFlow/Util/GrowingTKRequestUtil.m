//
//  GrowingTKRequestUtil.m
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

#import "GrowingTKRequestUtil.h"
#include "GrowingTKLZ4.h"
#import "GrowingTKUtil.h"

@implementation GrowingTKRequestUtil

+ (NSUInteger)headersLengthForRequest:(NSURLRequest *)request {
    NSDictionary<NSString *, NSString *> *headerFields = request.allHTTPHeaderFields;
    NSDictionary<NSString *, NSString *> *cookiesHeader = [self cookiesForRequest:request];
    if (cookiesHeader.count) {
        NSMutableDictionary *headerFieldsWithCookies = [NSMutableDictionary dictionaryWithDictionary:headerFields];
        [headerFieldsWithCookies addEntriesFromDictionary:cookiesHeader];
        headerFields = [headerFieldsWithCookies copy];
    }
    return [self headersLength:headerFields];
}

+ (NSUInteger)headersLength:(NSDictionary *)headers {
    NSUInteger headersLength = 0;
    if (headers) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:headers options:NSJSONWritingPrettyPrinted error:nil];
        headersLength = data.length;
    }
    return headersLength;
}

+ (NSDictionary<NSString *, NSString *> *)cookiesForRequest:(NSURLRequest *)request {
    NSDictionary<NSString *, NSString *> *cookiesHeader;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookiesForURL:request.URL];
    if (cookies.count) {
        cookiesHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    }
    return cookiesHeader;
}

+ (int64_t)responseLengthForResponse:(NSHTTPURLResponse *)response responseData:(NSData *)responseData {
    int64_t responseLength = 0;
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSDictionary<NSString *, NSString *> *headerFields = httpResponse.allHeaderFields;
        NSUInteger headersLength = [self headersLength:headerFields];

        int64_t contentLength = 0.;
        if (httpResponse.expectedContentLength != NSURLResponseUnknownLength) {
            contentLength = httpResponse.expectedContentLength;
        } else {
            contentLength = responseData.length;
        }

        responseLength = headersLength + contentLength;
    }
    return responseLength;
}

+ (NSData *)decryptData:(NSData *)data factor:(unsigned char)hint {
    NSMutableData *result = [[NSMutableData alloc] initWithLength:data.length];
    const unsigned char *p = data.bytes;
    unsigned char *q = result.mutableBytes;

    for (NSUInteger i = 0; i < data.length; i++, p++, q++) {
        *q = (*p ^ hint);
    }
    return result;
}

+ (NSData *)uncompressData:(NSData *)data {
    int maxOutputSize = 1024 * 1024;
    void *out_buff = malloc(maxOutputSize);
    int out_size = GROWTK_LZ4_uncompress_unknownOutputSize(data.bytes, out_buff, (int)data.length, maxOutputSize);
    if (out_size < 0) {
        free(out_buff);
        return data;
    }
    return [[NSData alloc] initWithBytesNoCopy:out_buff length:out_size freeWhenDone:YES];
}

+ (NSString *)convertProtobufDataToJSON:(NSData *)data {
    Class cls = NSClassFromString(@"GrowingPBEventV3List");
    if (!cls) {
        return @"";
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(@"parseFromData:error:");
    if ([cls respondsToSelector:selector]) {
        id list = [cls performSelector:selector withObject:data withObject:nil];
        if (list) {
            NSArray *array = [list valueForKey:@"valuesArray"];
            if (array.count > 0) {
                NSMutableArray *jsonArray = [NSMutableArray array];
                for (id protobuf in array) {
                    SEL toJsonObject = NSSelectorFromString(@"growingHelper_jsonObject");
                    if ([protobuf respondsToSelector:toJsonObject]) {
                        id jsonObject = [protobuf performSelector:toJsonObject];
                        if (jsonObject) {
                            [jsonArray addObject:jsonObject];
                        }
                    }
                }
                if ([NSJSONSerialization isValidJSONObject:jsonArray]) {
                    return [GrowingTKUtil convertJSONFromJSONObject:jsonArray];
                }
            }
        }
    }
#pragma clang diagnostic pop
    
    return @"";
}

@end
