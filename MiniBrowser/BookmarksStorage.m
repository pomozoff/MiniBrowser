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
@synthesize rootItem = _rootItem;

@synthesize bookmarksTree = _bookmarksTree;
@synthesize bookmarksList = _bookmarksList;

NSString *const savedBookmarks = @"savedBookmarks";

- (NSInteger)sectionsCount
{
    return 1;
}

- (void)generateBookmarksList:(NSMutableDictionary *)list fromTree:(NSArray *)tree parent:(BookmarkItem *)parentItem
{
    for (NSDictionary *subItem in tree) {
        NSString *itemId = [subItem objectForKey:@"id"];
        NSString *name = [subItem objectForKey:@"name"];
        NSString *url = [subItem objectForKey:@"url"];
        BOOL group = [[subItem objectForKey:@"group"] boolValue];
        NSString *parentId = parentItem.itemId;
        
        BookmarkItem *item = [[BookmarkItem alloc] initWithName:name url:url group:group parentId:parentId];
        [list setObject:item forKey:itemId];
        
        NSArray *content = [subItem objectForKey:@"content"];
        [self generateBookmarksList:list fromTree:content parent:item];
        
        NSMutableArray *parentContent = [parentItem.content mutableCopy];
        [parentContent addObject:item];
        parentItem.content = parentContent;
        [parentContent release];
        
        [item release];
    }
}

- (BookmarkItem *)rootItem
{
    if (!_rootItem) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        
        NSDictionary *bookmarksPreloaded;// = [defaults objectForKey:savedBookmarks];

        //*************** PRELOADED DATA ***************
        NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *userDefaultsValuesPath = [mainBundlePath stringByAppendingPathComponent:@"BookmarkTreeSample.plist"];
        NSDictionary *tmpSavePref = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
        bookmarksPreloaded = [tmpSavePref objectForKey:@"Bookmarks"];
        //**********************************************
        
        NSArray *tmpBookmarks = [bookmarksPreloaded objectForKey:@"content"];
        
        if (!tmpBookmarks) {
            _rootItem = [[BookmarkItem alloc] initWithName:@"Bookmarks" url:@"" group:YES parentId:nil];
            NSArray *tmpArray = [[NSArray alloc] init];
            self.bookmarksTree = tmpArray;
            [tmpArray release];
        } else {
            NSString *name = [bookmarksPreloaded objectForKey:@"name"];
            NSString *url = [bookmarksPreloaded objectForKey:@"url"];
            BOOL group = [[bookmarksPreloaded objectForKey:@"group"] boolValue];
            
            _rootItem = [[BookmarkItem alloc] initWithName:name url:url group:group parentId:nil];
            self.bookmarksTree = tmpBookmarks;
        }
        
        // Init map ID -> BookmarkItem
        NSMutableDictionary *tmpList = [[NSMutableDictionary alloc] init];
        [self generateBookmarksList:tmpList fromTree:self.bookmarksTree parent:_rootItem];
        self.bookmarksList = tmpList;
        [tmpList release];
}
    
    return _rootItem;
}

/*
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

- (NSDictionary *)bookmarksList
{
    if (!_bookmarksList) {
        NSMutableDictionary *tmpList = [[NSMutableDictionary alloc] init];
        [self generateBookmarksList:tmpList fromTree:self.bookmarksTree parent:self.rootItem];
        
        _bookmarksList = tmpList;
        [tmpList release];
    }
    
    return _bookmarksList;
}
*/

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSInteger)bookmarksCountForParent:(BookmarkItem *)parentItem
{
    return parentItem.content.count;
}

- (BookmarkItem *)bookmarkAtIndex:(NSIndexPath *)indexPath forParent:(BookmarkItem *)parentItem
{
    BookmarkItem *item = [parentItem.content objectAtIndex:indexPath.row];
    return item;
}

- (void)addBookmark:(BookmarkItem *)bookmark
{
    NSMutableDictionary *tmpList = [self.bookmarksList mutableCopy];
    
    [tmpList setObject:bookmark forKey:bookmark.itemId];
    
    self.bookmarksList = tmpList;
    [tmpList release];
    
    BookmarkItem *parentItem = [self.bookmarksList objectForKey:bookmark.parentId];
    NSMutableArray *tmpContent = [parentItem.content mutableCopy];
    
    [tmpContent addObject:bookmark];
    parentItem.content = tmpContent;
    
    [tmpContent release];
}

- (void)moveBookmarkAtPosition:(NSIndexPath *)fromIndexPath toPosition:(NSIndexPath *)toIndexPath insideGroup:(BookmarkItem *)group
{
    NSMutableArray *content = [group.content mutableCopy];
    
    [content exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    group.content = content;
    
    [content release];
}

- (NSArray *)treeOfTheBookmarks
{
    return nil;
}

- (void)dealloc
{
    [_rootItem release];
    _rootItem = nil;
    
    self.bookmarksTree = nil;
    self.bookmarksList = nil;
    
    [super dealloc];
}

@end
