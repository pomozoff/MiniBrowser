//
//  BookmarksStorage.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarksStorage.h"

@interface BookmarksStorage()

@property (nonatomic, retain) NSDictionary *bookmarksList;
@property (nonatomic, copy) NSString *bookmarkTreePlist;

@end

@implementation BookmarksStorage

@synthesize sectionsCount = _sectionsCount;
@synthesize rootItem = _rootItem;
@synthesize historyGroup = _historyGroup;

@synthesize bookmarksList = _bookmarksList;
@synthesize bookmarkTreePlist = _bookmarkTreePlist;

NSString *const savedBookmarks = @"savedBookmarks";
NSString *const historyFolderName = @"History";

- (NSInteger)sectionsCount
{
    return 1;
}

- (NSDictionary *)copyBookmarksToDictionaryFromBookmark:(BookmarkItem *)bookmark
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result setObject:bookmark.name forKey:@"name"];
    [result setObject:bookmark.url forKey:@"url"];
    [result setObject:bookmark.date forKey:@"date"];
    [result setObject:(bookmark.isGroup ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]) forKey:@"group"];
    [result setObject:(bookmark.isPermanent ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]) forKey:@"permanent"];
    
    NSMutableArray *tmpContent = [[NSMutableArray alloc] init];
    
    for (BookmarkItem *subBookmark in bookmark.content) {
        NSDictionary *contentItem = [self copyBookmarksToDictionaryFromBookmark:subBookmark];
        [tmpContent addObject:contentItem];
        [contentItem release];
    }
    
    [result setObject:tmpContent forKey:@"content"];
    [tmpContent release];
    
    return result;
}

- (void)saveBookmarks
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSDictionary *bookmarks = [self copyBookmarksToDictionaryFromBookmark:self.rootItem];
    [defaults setObject:bookmarks forKey:savedBookmarks];
    [bookmarks release];
}

- (void)generateBookmarksList:(NSMutableDictionary *)list
                     fromTree:(NSArray *)tree
                       parent:(BookmarkItem *)parentItem
{
    for (NSDictionary *subItem in tree) {
        NSString *name = [subItem objectForKey:@"name"];
        NSString *url = [subItem objectForKey:@"url"];
        NSDate *date = [subItem objectForKey:@"date"];
        BOOL group = [[subItem objectForKey:@"group"] boolValue];
        BOOL permanent = [[subItem objectForKey:@"permanent"] boolValue];
        
        BookmarkItem *item = [[BookmarkItem alloc] initWithName:name
                                                            url:url
                                                           date:date
                                                          group:group
                                                      permanent:permanent];
        
        item.parentId = parentItem.itemId;
        [list setObject:item forKey:item.itemId];
        
        if (permanent && [name isEqualToString:historyFolderName]) {
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
        NSDictionary *bookmarksPreloaded = [defaults objectForKey:savedBookmarks];

        _rootItem = [[BookmarkItem alloc] initWithName:@"Bookmarks" url:@"" date:[NSDate date] group:YES permanent:YES];

        NSArray *tmpContent;
        if (bookmarksPreloaded && bookmarksPreloaded.count > 0) {
            tmpContent = [bookmarksPreloaded objectForKey:@"content"];
        } else {
            //*************** DEBUG LOG DATA ***************
            NSLog(@"Main Bundle Path: %@", [[NSBundle mainBundle] bundlePath]);
            
            for (NSBundle *bundle in [NSBundle allBundles]) {
                NSLog(@"%@: %@", [bundle bundleIdentifier], 
                      [bundle pathForResource:@"fire" ofType:@"png"]);
            }
            //*************** PRELOADED DATA ***************
            NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
            NSString *userDefaultsValuesPath = [mainBundlePath stringByAppendingPathComponent:self.bookmarkTreePlist];
            NSDictionary *tmpSavePref = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
            bookmarksPreloaded = [tmpSavePref objectForKey:@"Bookmarks"];
            //**********************************************
            
            NSArray *tmpBookmarks = [bookmarksPreloaded objectForKey:@"content"];
            if (tmpBookmarks) {
                tmpContent = tmpBookmarks;
            } else {
                tmpContent = [NSArray array];
            }
        }
        
        // Init map ID -> BookmarkItem
        NSMutableDictionary *tmpList = [[NSMutableDictionary alloc] init];
        [self generateBookmarksList:tmpList fromTree:tmpContent parent:_rootItem];
        self.bookmarksList = tmpList;
        [tmpList release];
    }
    
    return _rootItem;
}

- (BookmarkItem *)historyGroup
{
    if (!_historyGroup && !self.rootItem) {
        _historyGroup = nil;
    }
    
    return _historyGroup;
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

/*
- (NSString *)bookmarkTreePlist
{
    if (!_bookmarkTreePlist) {
        _bookmarkTreePlist = @"BookmarkTreePermanent.plist";
    }
    
    return _bookmarkTreePlist;
}
*/

- (id)initWithBookmarksPlistName:(NSString *)plistName
{
    self = [super init];
    if (self) {
        self.bookmarkTreePlist = plistName;
    }
    
    return self;
}

- (id)init
{
    [self initWithBookmarksPlistName:@"BookmarkTreePermanent.plist"];
    
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

- (void)insertBookmarkToList:(BookmarkItem *)bookmark
{
    NSMutableDictionary *tmpList = [self.bookmarksList mutableCopy];
    
    [tmpList setObject:bookmark forKey:bookmark.itemId];
    self.bookmarksList = tmpList;
    
    [tmpList release];
}

- (void)addBookmark:(BookmarkItem *)bookmark toGroup:(BookmarkItem *)bookmarkGroup
{
    bookmark.parentId = bookmarkGroup.itemId;

    NSMutableArray *tmpContent = [bookmarkGroup.content mutableCopy];
    
    if ([bookmarkGroup isEqualToBookmark:self.historyGroup]) {
        BookmarkItem *firstBookmark = nil;
        if (tmpContent.count > 0) {
            firstBookmark = [tmpContent objectAtIndex:0];
        }
        
        if (firstBookmark && [bookmark isEqualToBookmark:firstBookmark]) {
            firstBookmark.date = bookmark.date;
        } else {
            [tmpContent insertObject:bookmark atIndex:0];
        }
    } else {
        [tmpContent addObject:bookmark];
    }

    bookmarkGroup.content = tmpContent;
    
    [tmpContent release];
    
    [self insertBookmarkToList:bookmark];
}

- (void)removeBookmarkFromList:(BookmarkItem *)bookmark
{
    NSMutableDictionary *tmpList = [self.bookmarksList mutableCopy];
    
    [tmpList removeObjectForKey:bookmark.itemId];
    self.bookmarksList = tmpList;
    
    [tmpList release];
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
    [self removeBookmarkFromList:bookmark];
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

- (void)dealloc
{
    [_rootItem release];
    _rootItem = nil;
    [_historyGroup release];
    _historyGroup = nil;

    self.bookmarksList = nil;
    self.bookmarkTreePlist = nil;
    
    [super dealloc];
}

@end
