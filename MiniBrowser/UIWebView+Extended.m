//
//  UIWebView+Extended.m
//  MiniBrowser
//
//  Created by Антон Помозов on 23.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import "UIWebView+Extended.h"
#import <objc/runtime.h>

static char const * const IsThreadedKey = "IsThreaded";

@implementation UIWebView (Extended)

@dynamic isThreaded;

- (BOOL)isThreaded
{
    id object = objc_getAssociatedObject(self, IsThreadedKey);
    BOOL result = [object boolValue];
    
    return result;
}

- (void)setIsThreaded:(BOOL)isThreadedValue
{
    NSNumber *object = [NSNumber numberWithBool:isThreadedValue];
    objc_setAssociatedObject(self, IsThreadedKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
