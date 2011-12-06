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
@synthesize isFolder = _folder;
@synthesize isPermanent = _permanent;
@synthesize name = _name;
@synthesize url = _url;
@synthesize parentId = _parentId;
@synthesize date = _date;
@synthesize content = _content;
@synthesize delegateController = _delegateBookmark;

- (NSArray *)content
{
    if (!_content) {
        _content = [[NSArray alloc] init];
    }
    
    return _content;
}

- (id)initWithName:(NSString *)name
               url:(NSString *)url
              date:(NSDate *)date
             folder:(BOOL)isFolder
         permanent:(BOOL)isThisPermanent
{
    self = [super init];
    if (self) {
        CFUUIDRef uuidObj = CFUUIDCreate(NULL);
        _itemId = (NSString *)CFUUIDCreateString(NULL, uuidObj);
        CFRelease(uuidObj);

        _folder = isFolder;
        _permanent = isThisPermanent;
        
        self.name = name;
        self.url = url;
        self.date = date;
    }
    
    return self;
}

- (id)init
{
    self = [self initWithName:@"" url:@"" date:[NSDate date] folder:NO permanent:NO];
    
    return self;
}
+ (NSDictionary *)itemAsDictionaryWithName:(NSString *)name
                                       url:(NSString *)url
                                     folder:(BOOL)isFolder
                                 permanent:(BOOL)isThisPermanent
                                    parent:(NSString *)parentId
                                   content:(NSArray *)content
{
    NSNumber *isFolderNumber = [NSNumber numberWithBool:isFolder];
    NSNumber *permanent = [NSNumber numberWithBool:isThisPermanent];

    NSArray *keys = [NSArray arrayWithObjects:@"name", @"url", @"date" @"folder", @"permanent", @"parent", @"content", nil];
    NSArray *objects = [NSArray arrayWithObjects:name, url, [NSDate date], isFolderNumber, permanent, parentId, content, nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:objects forKey:keys];
    
    return dictionary;
}

- (NSString *)description
{
    NSString *desription = [NSString stringWithFormat:@"Bookmark named \"%@\"\nurl: %@\ndate: %@\nfolder: %@\npermanent: %@\nid: %@\nparentId: %@\nsubitems count: %d",
                            self.name,
                            self.url,
                            self.date,
                            self.isFolder ? @"YES" : @"NO",
                            self.isPermanent ? @"YES" : @"NO",
                            self.itemId,
                            self.parentId,
                            self.content.count];
    return desription;
}

- (BOOL)isEqualToBookmark:(BookmarkItem *)bookmark
{
    BOOL result = (bookmark.isFolder == self.isFolder) &&
                  (bookmark.isPermanent == self.isPermanent) &&
                  [bookmark.name isEqualToString:self.name] && 
                  ((!self.url && !bookmark.url) || [bookmark.url isEqualToString:self.url]) &&
                  ((!self.parentId && !bookmark.parentId) || [bookmark.parentId isEqualToString:self.parentId]) &&
                  [bookmark.content isEqualToArray:self.content];
    
    return result;
}

- (void)dealloc
{
    if (_itemId) {
        [_itemId release];
    }
    _itemId = nil;
    
    self.name = nil;
    self.url = nil;
    self.parentId = nil;
    self.date = nil;
    self.content = nil;
    self.delegateController = nil;
    
    [super dealloc];
}

@end
