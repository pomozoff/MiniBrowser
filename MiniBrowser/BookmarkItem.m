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
@synthesize group = _group;
@synthesize itemId = _itemId;
@synthesize parentId = _parentId;

- (id)initWithName:(NSString *)name
               url:(NSString *)url
             group:(BOOL)isThisAGroup
          parentId:(NSString *)parentId
{
    self = [super init];
    if (self) {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        _itemId = (NSString *)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);

        _group = isThisAGroup;
        
        self.name = name;
        self.url = url;
        self.parentId = parentId;
    }
    
    return self;
}

- (id)init
{
    self = [self initWithName:@"" url:@"" group:NO parentId:nil];
    
    return self;
}
+ (NSDictionary *)itemAsDictionaryWithName:(NSString *)name
                                       url:(NSString *)url
                                     group:(BOOL)isThisAGroup
                                    parent:(NSString *)parentId
                                   content:(NSArray *)content
{
    NSArray *keys = [[NSArray alloc] initWithObjects:@"name", @"url", @"group", @"parent", @"content", nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:name, url, [NSNumber numberWithBool:isThisAGroup], parentId, content, nil];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    [objects release];
    [keys release];
    
    return [dictionary autorelease];
}

@end
