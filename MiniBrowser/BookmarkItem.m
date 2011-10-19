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
@synthesize isGroup = _group;
@synthesize isPermanent = _permanent;
@synthesize name = _name;
@synthesize url = _url;
@synthesize parentId = _parentId;
@synthesize date = _date;
@synthesize content = _content;
@synthesize delegateBookmark = _delegateBookmark;

+ (NSString *)historyFolderName
{
    return @"History";
}

- (void)prepareHistoryContent:(NSArray *)itemContent
{
    if (self.isPermanent && self.isGroup && [self.name isEqualToString:[BookmarkItem historyFolderName]]) {
        for (BookmarkItem *historyBookmark in itemContent) {
            
        }
    }
}

- (NSArray *)content
{
    if (!_content) {
        _content = [[NSArray alloc] init];
    }
    
    [self prepareHistoryContent:_content];
    
    return _content;
}

- (id)initWithName:(NSString *)name
               url:(NSString *)url
              date:(NSDate *)date
             group:(BOOL)isThisAGroup
         permanent:(BOOL)isThisPermanent
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
        self.date = date;
    }
    
    return self;
}

- (id)init
{
    self = [self initWithName:@"" url:@"" date:[NSDate date] group:NO permanent:NO];
    
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
    NSString *desription = [NSString stringWithFormat:@"Bookmark named \"%@\"\nurl: %@\ngroup: %@\npermanent: %@\nid: %@\nparentId: %@\nsubitems count: %d", self.name, self.url, self.isGroup ? @"YES" : @"NO", self.isPermanent ? @"YES" : @"NO", self.itemId, self.parentId, self.content.count];
    return desription;
}

- (BOOL)isEqualToBookmark:(BookmarkItem *)bookmark
{
    BOOL result = (bookmark.isGroup == self.isGroup) &&
                  (bookmark.isPermanent == self.isPermanent) &&
                  [bookmark.name isEqualToString:self.name] && 
                  [bookmark.url isEqualToString:self.url] &&
                  ((!self.parentId && !bookmark.parentId) || [bookmark.parentId isEqualToString:self.parentId]) &&
                  [bookmark.content isEqualToArray:self.content];
    
    return result;
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
