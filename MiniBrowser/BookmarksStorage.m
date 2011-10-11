//
//  BookmarksStorage.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarksStorage.h"

@interface BookmarksStorage()

@property (nonatomic, retain) NSArray *bookmarksTree;
@property (nonatomic, retain) NSDictionary *bookmarksList;

@end

@implementation BookmarksStorage

@synthesize sectionsCount = _sectionsCount;

@synthesize bookmarksTree = _bookmarksTree;
@synthesize bookmarksList = _bookmarksList;

NSString *const savedBookmarks = @"savedBookmarks";

- (NSInteger)sectionsCount
{
    return 1;
}

- (NSArray *)bookmarksTree
{
    if (!_bookmarksTree) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        
        NSArray *tmpBookmarks = [defaults objectForKey:savedBookmarks];
        
        if (!tmpBookmarks) {
            _bookmarksTree = [[NSArray alloc] init];
        } else {
            _bookmarksTree = [tmpBookmarks retain];
        }
    }
    
    return _bookmarksTree;
}

- (void)generateBookmarksList:(NSMutableDictionary *)list fromTree:(NSArray *)tree
{
    for (NSDictionary *subItem in tree) {
        NSString *itemId = [subItem objectForKey:@"itemId"];
        NSString *name = [subItem objectForKey:@"name"];
        NSString *url = [subItem objectForKey:@"url"];
        BOOL group = [[subItem objectForKey:@"group"] boolValue];
        NSString *parentId = [subItem objectForKey:@"name"];
        
        BookmarkItem *item = [[BookmarkItem alloc] initWithName:name url:url group:group parentId:parentId];
        [list setObject:item forKey:itemId];
        [item release];
        
        NSArray *content = [subItem objectForKey:@"content"];
        [self generateBookmarksList:list fromTree:content];
    }
}

- (NSDictionary *)bookmarksList
{
    if (!_bookmarksList) {
        NSMutableDictionary *tmpList = [[NSMutableDictionary alloc] init];
        [self generateBookmarksList:tmpList fromTree:self.bookmarksTree];
        
        _bookmarksList = tmpList;
        [tmpList release];
    }
    
    return _bookmarksList;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSInteger)bookmarksCount
{
    return self.bookmarksTree.count;
}

- (void)addBookmark:(BookmarkItem *)bookmark toGroup:(NSString *)groupId
{
    NSMutableArray *mutBookmarks = [self.bookmarksTree mutableCopy];

    
    
    self.bookmarksTree = mutBookmarks;
    [mutBookmarks release];
}

- (NSArray *)treeOfTheBookmarks
{
    return nil;
}

- (void)dealloc
{
    self.bookmarksTree = nil;
    
    [super dealloc];
}

@end
