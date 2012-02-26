//
//  UIWebView+Extended.m
//  MiniBrowser
//
//  Created by Антон Помозов on 23.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "UIWebView+Extended.h"
#import <objc/runtime.h>

static char const * const isThreadedKey = "IsThreaded";
static char const * const webViewIdKey = "WebViewID";

@implementation UIWebView (Extended)

@dynamic isThreaded;
@dynamic webViewId;

- (BOOL)isThreaded
{
    id object = objc_getAssociatedObject(self, isThreadedKey);
    BOOL result = [object boolValue];
    
    return result;
}

- (void)setIsThreaded:(BOOL)isThreadedValue
{
    NSNumber *object = [NSNumber numberWithBool:isThreadedValue];
    objc_setAssociatedObject(self, isThreadedKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)generateUuidString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // transfer ownership of the string
    // to the autorelease pool
    [uuidString autorelease];
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

- (NSString *)webViewId
{
    id object = objc_getAssociatedObject(self, webViewIdKey);
    NSString *webViewId = (NSString *)object;
    
    if (!webViewId) {
        webViewId = [self generateUuidString];
        objc_setAssociatedObject(self, webViewIdKey, webViewId, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return webViewId;
}

@end
