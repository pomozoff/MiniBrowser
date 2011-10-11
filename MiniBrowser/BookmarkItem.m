//
//  BookmarkItem.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarkItem.h"

@implementation BookmarkItem

@synthesize name = _name;
@synthesize url = _url;
@synthesize itemId = _itemId;
@synthesize parentId = _parentId;

- (id)initWithName:(NSString *)name url:(NSString *)url parent:(NSString *)parentId
{
    self = [super init];
    if (self) {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        _itemId = (NSString *)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);

        self.name = name;
        self.url = url;
        self.parentId = parentId;
    }
    
    return self;
}

- (id)init
{
    self = [self initWithName:@"" url:@"" parent:nil];
    
    return self;
}

@end
