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
@synthesize groupsTreeList = _groupsTreeList;
@synthesize rootItem = _rootItem;

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
{
    if (!bookmarkGroup.group) {
        return;
    }
    
    for (BookmarkItem *bookmark in bookmarkGroup.content) {
        if (!bookmark.group) {
            continue;
        }
        
        if (bookmark == excludeItem) {
            continue;
        }
        
        if (!bookmark.permanent && bookmark != excludeItemParent) {
            [treeList addObject:bookmark];
        }
        
        [self generateGroupsTreeList:treeList
                   fromBookmarkGroup:bookmark
                       excludeBranch:excludeItem
                 excludeBranchParent:excludeItemParent];
    }
}

- (NSArray *)groupsTreeList
{
    if (!_groupsTreeList) {
        NSMutableArray *treeList = [[NSMutableArray alloc] init];
        
        [treeList addObject:self.rootItem];
        [self generateGroupsTreeList:treeList
                   fromBookmarkGroup:self.rootItem
                       excludeBranch:nil
                 excludeBranchParent:nil];
        _groupsTreeList = [[NSArray arrayWithArray:treeList] retain];
        
        [treeList release];
    }
    
    return _groupsTreeList;
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
    [self addBookmark:bookmark toGroup:groupBookmark];
    [bookmark release];
    
    bookmark.parentId = groupBookmark.itemId;
    [bookmark.delegateBookmark bookmarkGroupChangedTo:groupBookmark];
}

- (NSArray *)bookmarkGroupsWithoutBranch:(BookmarkItem *)branchBookmark
{
    NSMutableArray *mutableList = [[NSMutableArray alloc] init];
    BookmarkItem *branchBookmarkParent = [self bookmarkById:branchBookmark.parentId];
    
    [self generateGroupsTreeList:mutableList
               fromBookmarkGroup:self.rootItem
                   excludeBranch:branchBookmark
             excludeBranchParent:branchBookmarkParent];
    NSArray *resultList = [[NSArray arrayWithArray:mutableList] retain];
    
    [mutableList release];
     
    return [resultList autorelease];
}

- (void)dealloc
{
    [_rootItem release];
    _rootItem = nil;
    [_groupsTreeList release];
    _groupsTreeList = nil;
    
    self.bookmarksTree = nil;
    self.bookmarksList = nil;
    
    [super dealloc];
}

@end
