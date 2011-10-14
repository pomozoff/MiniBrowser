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
@synthesize permanent = _permanent;
@synthesize name = _name;
@synthesize url = _url;
@synthesize parentId = _parentId;
@synthesize content = _content;
@synthesize delegateBookmark = _delegateBookmark;

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
         permanent:(BOOL)isThisPermanent
          parentId:(NSString *)parentId
{
    self = [super init];
    if (self) {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        _itemId = (NSString *)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);

        _group = isThisAGroup;
        _permanent = isThisPermanent;
        
        self.name = name;
        self.url = url;
        self.parentId = parentId;
    }
    
    return self;
}

- (id)init
{
    self = [self initWithName:@"" url:@"" group:NO permanent:NO parentId:nil];
    
    return self;
}
+ (NSDictionary *)itemAsDictionaryWithName:(NSString *)name
                                       url:(NSString *)url
                                     group:(BOOL)isThisAGroup
                                 permanent:(BOOL)isThisPermanent
                                    parent:(NSString *)parentId
                                   content:(NSArray *)content
{
    NSNumber *group = [NSNumber numberWithBool:isThisAGroup];
    NSNumber *permanent = [NSNumber numberWithBool:isThisPermanent];

    NSArray *keys = [[NSArray alloc] initWithObjects:@"name", @"url", @"group", @"permanent", @"parent", @"content", nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:name, url, group, permanent, parentId, content, nil];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    [objects release];
    [keys release];
    
    return [dictionary autorelease];
}

- (NSString *)description
{
    NSString *desription = [NSString stringWithFormat:@"Bookmark named \"%@\"\nurl: %@\ngroup: %@\npermanent: %@\nid: %@\nparentId: %@\nsubitems count: %d", self.name, self.url, self.group ? @"YES" : @"NO", self.permanent ? @"YES" : @"NO", self.itemId, self.parentId, self.content.count];
    return desription;
}

- (void)dealloc
{
    self.name = nil;
    self.url = nil;
    self.parentId = nil;
    self.content = nil;
    self.delegateBookmark = nil;
    
    [super dealloc];
}

@end
