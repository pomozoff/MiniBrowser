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
@synthesize historyGroup = _historyGroup;

@synthesize bookmarksTree = _bookmarksTree;
@synthesize bookmarksList = _bookmarksList;

NSString *const savedBookmarks = @"savedBookmarks";

- (NSInteger)sectionsCount
{
    return 1;
}

- (void)generateBookmarksList:(NSMutableDictionary *)list
                     fromTree:(NSArray *)tree
                       parent:(BookmarkItem *)parentItem
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
        
        if (permanent && [name isEqualToString:@"History"]) {
            [_historyGroup release];
            _historyGroup = [item retain];
        }
        
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

- (void)generateGroupsTreeList:(NSMutableArray *)treeList
             fromBookmarkGroup:(BookmarkItem *)bookmarkGroup
                 excludeBranch:(BookmarkItem *)excludeItem
           excludeBranchParent:(BookmarkItem *)excludeItemParent
                  currentLevel:(NSInteger)level
{
    if (!bookmarkGroup.isGroup) {
        return;
    }
    
    for (BookmarkItem *bookmark in bookmarkGroup.content) {
        if (!bookmark.isGroup) {
            continue;
        }
        
        if (bookmark == excludeItem) {
            continue;
        }
        
        if (!bookmark.isPermanent && bookmark != excludeItemParent) {
            NSArray *keys = [NSArray arrayWithObjects:@"bookmark", @"level", nil];
            NSArray *objects = [NSArray arrayWithObjects:bookmark, [NSNumber numberWithInt:level], nil];
            
            NSDictionary *bookmarkGroup = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            [treeList addObject:bookmarkGroup];
            level++;
        }
        
        [self generateGroupsTreeList:treeList
                   fromBookmarkGroup:bookmark
                       excludeBranch:excludeItem
                 excludeBranchParent:excludeItemParent
                        currentLevel:level];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BookmarkItem *)bookmarkById:(NSString *)itemId
{
    BookmarkItem *item = [self.bookmarksList objectForKey:itemId];
    BookmarkItem *resultItem = item ? item : self.rootItem;
    
    return resultItem;
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
    
    bookmark.parentId = bookmarkGroup.itemId;
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
    
    BookmarkItem *parentItem = [self bookmarkById:bookmark.parentId];
    
    [self removeBookmark:bookmark fromGroup:parentItem];
}

- (void)moveBookmarkAtPosition:(NSIndexPath *)fromIndexPath toPosition:(NSIndexPath *)toIndexPath insideGroup:(BookmarkItem *)group
{
    NSMutableArray *content = [group.content mutableCopy];
    
    [content exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    group.content = content;
    
    [content release];
}

- (void)moveBookmark:(BookmarkItem *)bookmark toGroup:(BookmarkItem *)groupBookmark
{
    BookmarkItem *currentParent = [self bookmarkById:bookmark.parentId];
    
    [bookmark retain];
    [self removeBookmark:bookmark fromGroup:currentParent];
    [bookmark.delegateBookmark reloadBookmarksForGroup:currentParent];

    [self addBookmark:bookmark toGroup:groupBookmark];
    [bookmark release];
    
    bookmark.parentId = groupBookmark.itemId;
    bookmark.delegateBookmark = groupBookmark.delegateBookmark;
    [bookmark.delegateBookmark reloadBookmarksForGroup:groupBookmark];
}

- (NSArray *)bookmarkGroupsWithoutBranch:(BookmarkItem *)branchBookmark
{
    NSMutableArray *mutableList = [[NSMutableArray alloc] init];
    BookmarkItem *branchBookmarkParent = [self bookmarkById:branchBookmark.parentId];
    NSInteger level = 0;
    
    if (branchBookmarkParent != self.rootItem) {
        NSArray *keys = [NSArray arrayWithObjects:@"bookmark", @"level", nil];
        NSArray *objects = [NSArray arrayWithObjects:self.rootItem, [NSNumber numberWithInt:level], nil];
        
        NSDictionary *bookmarkGroup = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        [mutableList addObject:bookmarkGroup];
        level++;
    }
    
    [self generateGroupsTreeList:mutableList
               fromBookmarkGroup:self.rootItem
                   excludeBranch:branchBookmark
             excludeBranchParent:branchBookmarkParent
                    currentLevel:level];
    
    NSArray *resultList = [[NSArray arrayWithArray:mutableList] retain];
    [mutableList release];
     
    return [resultList autorelease];
}

#define HISTORY_LIST_CPACITY 50
- (void)addHistoryBookmark:(BookmarkItem *)bookmark
{
    if (!self.rootItem) { // Bookmark control couldn't initialize
        return;
    }

    bookmark.parentId = self.historyGroup.itemId;
    if (self.historyGroup.content.count > 0) {
        BookmarkItem *lastBookmark = [self.historyGroup.content objectAtIndex:0];
        if ([bookmark isEqualToBookmark:lastBookmark]) {
            return;
        }
    }
    
    NSMutableArray *tmpHistory = [self.historyGroup.content mutableCopy];
    
    [tmpHistory insertObject:bookmark atIndex:0];
    if (HISTORY_LIST_CPACITY < self.historyGroup.content.count) {
        [tmpHistory removeObjectsInRange:NSMakeRange(HISTORY_LIST_CPACITY, self.historyGroup.content.count - HISTORY_LIST_CPACITY)];
    }
    self.historyGroup.content = tmpHistory;
    
    [tmpHistory release];

    [bookmark.delegateBookmark reloadBookmarksForGroup:self.historyGroup];
}

- (void)dealloc
{
    [_rootItem release];
    _rootItem = nil;
    [_historyGroup release];
    _historyGroup = nil;
    
    self.bookmarksTree = nil;
    self.bookmarksList = nil;
    
    [super dealloc];
}

@end
