//  The MIT License (MIT)
//
//  Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  https://github.com/rentzsch/jrswizzle
//
//  NSObject+GrowingTKSwizzle.m
//  GrowingToolsKit
//
//  Created by YoloMao on 2021/9/1.
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

#import "NSObject+GrowingTKSwizzle.h"

#if TARGET_OS_IPHONE
    #import <objc/runtime.h>
    #import <objc/message.h>
#else
    #import <objc/objc-class.h>
#endif

#define GrowingTKSetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)    \
    if (ERROR_VAR) {    \
        NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
        *ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
                                         code:-1    \
                                     userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
    }
#define GrowingTKSetNSError(ERROR_VAR, FORMAT,...) GrowingTKSetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

@implementation NSObject (GrowingTKSwizzle)

+ (BOOL)growingtk_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError **)error_ {
#ifndef DEBUG
    return NO;
#endif
    
    Method origMethod = class_getInstanceMethod(self, origSel_);
    if (!origMethod) {
#if TARGET_OS_IPHONE
        GrowingTKSetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self class]);
#else
        GrowingTKSetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
#endif
        return NO;
    }

    Method altMethod = class_getInstanceMethod(self, altSel_);
    if (!altMethod) {
#if TARGET_OS_IPHONE
        GrowingTKSetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self class]);
#else
        GrowingTKSetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
#endif
        return NO;
    }

    class_addMethod(self,
                    origSel_,
                    class_getMethodImplementation(self, origSel_),
                    method_getTypeEncoding(origMethod));
    class_addMethod(self,
                    altSel_,
                    class_getMethodImplementation(self, altSel_),
                    method_getTypeEncoding(altMethod));

    method_exchangeImplementations(class_getInstanceMethod(self, origSel_), class_getInstanceMethod(self, altSel_));
    return YES;
}

+ (BOOL)growingtk_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError **)error_ {
#ifndef DEBUG
    return NO;
#endif
    
    return [object_getClass((id)self) growingtk_swizzleMethod:origSel_ withMethod:altSel_ error:error_];
}

+ (nullable NSInvocation *)growingtk_swizzleMethod:(SEL)origSel withBlock:(id)block error:(NSError **)error {
#ifndef DEBUG
    return nil;
#endif
    
    IMP blockIMP = imp_implementationWithBlock(block);
    NSString *blockSelectorString = [NSString stringWithFormat:@"_growingtk_block_%@_%p", NSStringFromSelector(origSel), block];
    SEL blockSel = sel_registerName([blockSelectorString cStringUsingEncoding:NSUTF8StringEncoding]);
    Method origSelMethod = class_getInstanceMethod(self, origSel);
    const char* origSelMethodArgs = method_getTypeEncoding(origSelMethod);
    class_addMethod(self, blockSel, blockIMP, origSelMethodArgs);

    NSMethodSignature *origSig = [NSMethodSignature signatureWithObjCTypes:origSelMethodArgs];
    NSInvocation *origInvocation = [NSInvocation invocationWithMethodSignature:origSig];
    origInvocation.selector = blockSel;

    [self growingtk_swizzleMethod:origSel withMethod:blockSel error:nil];

    return origInvocation;
}

+ (nullable NSInvocation *)growingtk_swizzleClassMethod:(SEL)origSel withBlock:(id)block error:(NSError **)error {
#ifndef DEBUG
    return nil;
#endif
    
    NSInvocation *invocation = [object_getClass((id)self) growingtk_swizzleMethod:origSel withBlock:block error:error];
    invocation.target = self;

    return invocation;
}

@end
