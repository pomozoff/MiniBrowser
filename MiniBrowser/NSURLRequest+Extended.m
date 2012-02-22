//
//  NSURLRequest+Extended.m
//  MiniBrowser
//
//  Created by Антон Помозов on 22.02.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import "NSURLRequest+Extended.h"
#import <objc/runtime.h>

static char const * const isModifiedKey = "IsModified";

@implementation NSURLRequest (Extended)

@dynamic isModified;

- (BOOL)isModified
{
    id object = objc_getAssociatedObject(self, isModifiedKey);
    BOOL result = [object boolValue];
    
    return result;
}

- (void)setisModified:(BOOL)isModifiedValue
{
    NSNumber *object = [NSNumber numberWithBool:isModifiedValue];
    objc_setAssociatedObject(self, isModifiedKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
