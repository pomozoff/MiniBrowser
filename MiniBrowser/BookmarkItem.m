//
//  BookmarkItem.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarkItem.h"

@implementation BookmarkItem

@synthesize itemId = _itemId;
@synthesize group = _group;
@synthesize name = _name;
@synthesize url = _url;
@synthesize parentId = _parentId;
@synthesize content = _content;

- (NSArray *)content
{
    if (!_content) {
        _content = [[NSArray alloc] init];
    }
    
    return _content;
}

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

- (void)dealloc
{
    self.name = nil;
    self.url = nil;
    self.parentId = nil;
    self.content = nil;
    
    [super dealloc];
}

@end
