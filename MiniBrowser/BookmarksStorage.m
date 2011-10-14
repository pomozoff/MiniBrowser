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
        NSString *name = [subItem objectForKey:@"name"];
        NSString *url = [subItem objectForKey:@"url"];
        BOOL group = [[subItem objectForKey:@"group"] boolValue];
        BOOL permanent = [[subItem objectForKey:@"permanent"] boolValue];
        NSString *parentId = parentItem.itemId;
        
        BookmarkItem *item = [[BookmarkItem alloc] initWithName:name url:url group:group permanent:permanent parentId:parentId];
        
        NSString *itemId = item.itemId;
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
        NSString *userDefaultsValuesPath = [mainBundlePath stringByAppendingPathComponent:@"BookmarkTreePermanent.plist"];
        NSDictionary *tmpSavePref = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
        bookmarksPreloaded = [tmpSavePref objectForKey:@"Bookmarks"];
        //**********************************************
        
        NSArray *tmpBookmarks = [bookmarksPreloaded objectForKey:@"content"];
        
        if (!tmpBookmarks) {
            _rootItem = [[BookmarkItem alloc] initWithName:@"Bookmarks" url:@"" group:YES permanent:YES parentId:nil];
            NSArray *tmpArray = [[NSArray alloc] init];
            self.bookmarksTree = tmpArray;
            [tmpArray release];
        } else {
            NSString *name = [bookmarksPreloaded objectForKey:@"name"];
            NSString *url = [bookmarksPreloaded objectForKey:@"url"];
            BOOL group = [[bookmarksPreloaded objectForKey:@"group"] boolValue];
            BOOL permanent = [[bookmarksPreloaded objectForKey:@"permanent"] boolValue];
            
            _rootItem = [[BookmarkItem alloc] initWithName:name url:url group:group permanent:permanent parentId:nil];
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

- (void)addBookmark:(BookmarkItem *)bookmark toGroup:(BookmarkItem *)bookmarkGroup
{
    NSMutableArray *tmpContent = [bookmarkGroup.content mutableCopy];
    
    [tmpContent addObject:bookmark];
    bookmarkGroup.content = tmpContent;
    
    [tmpContent release];
}

- (void)insertBookmark:(BookmarkItem *)bookmark
{
    NSMutableDictionary *tmpList = [self.bookmarksList mutableCopy];
    
    [tmpList setObject:bookmark forKey:bookmark.itemId];
    
    self.bookmarksList = tmpList;
    [tmpList release];
    
    
    BookmarkItem *parentItem = [self.bookmarksList objectForKey:bookmark.parentId];
    [self addBookmark:bookmark toGroup:parentItem];
}

- (void)removeBookmark:(BookmarkItem *)bookmark fromGroup:(BookmarkItem *)bookmarkGroup
{
    NSMutableArray *tmpContent = [bookmarkGroup.content mutableCopy];
    
    [tmpContent removeObject:bookmark];
    bookmarkGroup.content = tmpContent;
    
    [tmpContent release];
}

- (void)deleteBookmark:(BookmarkItem *)bookmark
{
    NSMutableDictionary *tmpList = [self.bookmarksList mutableCopy];
    
    [tmpList removeObjectForKey:bookmark.itemId];
    
    self.bookmarksList = tmpList;
    [tmpList release];
    
    BookmarkItem *parentItem = [self.bookmarksList objectForKey:bookmark.parentId];
    
    [self removeBookmark:bookmark fromGroup:parentItem];
}

- (void)moveBookmarkAtPosition:(NSIndexPath *)fromIndexPath toPosition:(NSIndexPath *)toIndexPath insideGroup:(BookmarkItem *)group
{
    NSMutableArray *content = [group.content mutableCopy];
    
    [content exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    group.content = content;
    
    [content release];
}

- (BookmarkItem *)bookmarkById:(NSString *)itemId
{
    BookmarkItem *item = [self.bookmarksList objectForKey:itemId];
    BookmarkItem *resultItem = item ? item : self.rootItem;
    
    return resultItem;
}

- (void)moveBookmark:(BookmarkItem *)bookmark toGroup:(BookmarkItem *)groupBookmark
{
    BookmarkItem *currentParent = [self.bookmarksList objectForKey:bookmark.itemId];
    
    [bookmark retain];
    [self removeBookmark:bookmark fromGroup:currentParent];
    [self addBookmark:bookmark toGroup:groupBookmark];
    [bookmark release];
    
    bookmark.parentId = groupBookmark.itemId;
    [bookmark.delegateBookmark bookmarkGroupChangedTo:groupBookmark];
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
