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
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, copy) NSString *pathToBundle;

@end

@implementation BookmarksStorage

@synthesize sectionsCount = _sectionsCount;
@synthesize rootFolder = _rootFolder;
@synthesize historyFolder = _historyFolder;

@synthesize bookmarksList = _bookmarksList;
@synthesize dateFormatter = _dateFormatter;
@synthesize pathToBundle = _pathToBundle;

NSString *const savedBookmarks = @"savedBookmarks";
NSString *const historyFolderName = @"History";

- (NSInteger)sectionsCount
{
    return 1;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"EEEE, MMM d"];
    }
    return _dateFormatter;
}

- (NSDictionary *)copyBookmarksToDictionaryFromBookmark:(BookmarkItem *)bookmark
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result setObject:bookmark.name forKey:@"name"];
    [result setObject:bookmark.url forKey:@"url"];
    [result setObject:bookmark.date forKey:@"date"];
    [result setObject:(bookmark.isFolder ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]) forKey:@"folder"];
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
    NSDictionary *bookmarks = [self copyBookmarksToDictionaryFromBookmark:self.rootFolder];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:bookmarks forKey:savedBookmarks];
    [defaults synchronize];
    
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
        BOOL isFolder = [[subItem objectForKey:@"folder"] boolValue];
        BOOL permanent = [[subItem objectForKey:@"permanent"] boolValue];
        
        BookmarkItem *item = [[BookmarkItem alloc] initWithName:name
                                                            url:url
                                                           date:date
                                                         folder:isFolder
                                                      permanent:permanent];
        
        item.parentId = parentItem.itemId;
        [list setObject:item forKey:item.itemId];
        
        if (permanent && [name isEqualToString:historyFolderName]) {
            [_historyFolder release];
            _historyFolder = [item retain];
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

- (BookmarkItem *)rootFolder
{
    if (!_rootFolder) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        NSDictionary *bookmarksPreloaded = [defaults objectForKey:savedBookmarks];

        _rootFolder = [[BookmarkItem alloc] initWithName:@"Bookmarks" url:@"" date:[NSDate date] folder:YES permanent:YES];

        NSArray *tmpContent;
        if (bookmarksPreloaded && bookmarksPreloaded.count > 0) {
            tmpContent = [bookmarksPreloaded objectForKey:@"content"];
        } else {
            NSString *pathToPermanentBookmarks = [self.pathToBundle stringByAppendingPathComponent:@"BookmarkTreePermanent.plist"];
            NSDictionary *tmpSavePref = [NSDictionary dictionaryWithContentsOfFile:pathToPermanentBookmarks];
            bookmarksPreloaded = [tmpSavePref objectForKey:@"Bookmarks"];
            
            NSArray *tmpBookmarks = [bookmarksPreloaded objectForKey:@"content"];
            if (tmpBookmarks) {
                tmpContent = tmpBookmarks;
            } else {
                tmpContent = [NSArray array];
            }
        }
        
        // Init map ID -> BookmarkItem
        NSMutableDictionary *tmpList = [[NSMutableDictionary alloc] init];
        [self generateBookmarksList:tmpList fromTree:tmpContent parent:_rootFolder];
        self.bookmarksList = tmpList;
        [tmpList release];
    }
    
    return _rootFolder;
}

- (BookmarkItem *)historyFolder
{
    if (!_historyFolder && !self.rootFolder) {
        _historyFolder = nil;
    }
    
    return _historyFolder;
}

- (void)generateFoldersTreeList:(NSMutableArray *)treeList
                     fromFolder:(BookmarkItem *)fromFolder
                  excludeBranch:(BookmarkItem *)excludeItem
            excludeBranchParent:(BookmarkItem *)excludeItemParent
                   currentLevel:(NSInteger)level
{
    if (!fromFolder.isFolder) {
        return;
    }
    
    for (BookmarkItem *bookmark in fromFolder.content) {
        if (!bookmark.isFolder) {
            continue;
        }
        
        if (bookmark == excludeItem) {
            continue;
        }
        
        if (!bookmark.isPermanent && bookmark != excludeItemParent) {
            NSArray *keys = [NSArray arrayWithObjects:@"bookmark", @"level", nil];
            NSArray *objects = [NSArray arrayWithObjects:bookmark, [NSNumber numberWithInt:level], nil];
            
            NSDictionary *bookmarkFolder = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            [treeList addObject:bookmarkFolder];
            level++;
        }
        
        [self generateFoldersTreeList:treeList
                   fromFolder:bookmark
                       excludeBranch:excludeItem
                 excludeBranchParent:excludeItemParent
                        currentLevel:level];
    }
}

/*
- (NSString *)pathToBundle
{
    if (!_pathToBundle) {
        _pathToBundle = [[NSBundle mainBundle] bundlePath];
    }
    
    return _pathToBundle;
}
*/

- (id)initWithPathToBundle:(NSString *)currentPathToBundle
{
    self = [super init];
    if (self) {
        self.pathToBundle = currentPathToBundle;
    }
    
    return self;
}

- (id)init
{
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    self = [self initWithPathToBundle:mainBundlePath];
    
    return self;
}

- (BookmarkItem *)bookmarkById:(NSString *)itemId
{
    BookmarkItem *item = [self.bookmarksList objectForKey:itemId];
    BookmarkItem *resultItem = item ? item : self.rootFolder;
    
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
    if (![self.bookmarksList objectForKey:bookmark.itemId]) {
        NSMutableDictionary *tmpList = [self.bookmarksList mutableCopy];
        
        [tmpList setObject:bookmark forKey:bookmark.itemId];
        self.bookmarksList = tmpList;
        
        [tmpList release];
    }
}

- (void)addBookmark:(BookmarkItem *)bookmark toFolder:(BookmarkItem *)bookmarkFolder
{
    if (!bookmark) {
        return;
    }
    
    if (bookmark.parentId) {
        [NSException raise:@"Bookmark adding error" format:@"Bookmark is already present in bookmark's list"];
    }
    
    bookmark.parentId = bookmarkFolder.itemId;

    NSMutableArray *tmpContent = [bookmarkFolder.content mutableCopy];
    
    if (!bookmark.isFolder && [bookmarkFolder isEqualToBookmark:self.historyFolder]) {
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

    bookmarkFolder.content = tmpContent;
    
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

- (void)removeBookmark:(BookmarkItem *)bookmark fromFolder:(BookmarkItem *)bookmarkFolder
{
    bookmark.parentId = nil;
    
    NSMutableArray *tmpContent = [bookmarkFolder.content mutableCopy];
    
    [tmpContent removeObject:bookmark];
    bookmarkFolder.content = tmpContent;
    
    [tmpContent release];
}

- (void)deleteBookmark:(BookmarkItem *)bookmark
{
    BookmarkItem *parentItem = [self bookmarkById:bookmark.parentId];
    
    [self removeBookmark:bookmark fromFolder:parentItem];
    [self removeBookmarkFromList:bookmark];
}

- (void)moveBookmarkAtPosition:(NSIndexPath *)fromIndexPath toPosition:(NSIndexPath *)toIndexPath insideFolder:(BookmarkItem *)folder
{
    NSMutableArray *content = [folder.content mutableCopy];
    
    [content exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    folder.content = content;
    
    [content release];
}

- (void)moveBookmark:(BookmarkItem *)bookmark toFolder:(BookmarkItem *)bookmarkFolder
{
    BookmarkItem *currentParent = [self bookmarkById:bookmark.parentId];
    
    [bookmark retain];
    [self removeBookmark:bookmark fromFolder:currentParent];
    [bookmark.delegateController reloadBookmarksInFolder:currentParent];

    @try {
        [self addBookmark:bookmark toFolder:bookmarkFolder];
    }
    @catch (NSException *exception) {
        NSLog(@"Error moving bookmark: %@", exception.reason);
        [self addBookmark:bookmark toFolder:currentParent];
    }
    @finally {
        [bookmark release];
    }
    
    bookmark.delegateController = bookmarkFolder.delegateController;
    [bookmark.delegateController reloadBookmarksInFolder:bookmarkFolder];
}

- (void)clearFolder:(BookmarkItem *)folder
{
    if (!folder.isFolder) {
        return;
    }
    
    for (BookmarkItem *bookmarkItem in folder.content) {
        [self clearFolder:bookmarkItem];
        [self removeBookmarkFromList:bookmarkItem];
    }
    
    folder.content = [NSArray array];
}

- (NSArray *)bookmarkFoldersWithoutBranch:(BookmarkItem *)branchBookmark
{
    NSMutableArray *mutableList = [[NSMutableArray alloc] init];
    BookmarkItem *branchBookmarkParent = [self bookmarkById:branchBookmark.parentId];
    NSInteger level = 0;
    
    if (branchBookmarkParent != self.rootFolder) {
        NSArray *keys = [NSArray arrayWithObjects:@"bookmark", @"level", nil];
        NSArray *objects = [NSArray arrayWithObjects:self.rootFolder, [NSNumber numberWithInt:level], nil];
        
        NSDictionary *bookmarkFolder = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        [mutableList addObject:bookmarkFolder];
        level++;
    }
    
    [self generateFoldersTreeList:mutableList
               fromFolder:self.rootFolder
                   excludeBranch:branchBookmark
             excludeBranchParent:branchBookmarkParent
                    currentLevel:level];
    
    NSArray *resultList = [[NSArray arrayWithArray:mutableList] retain];
    [mutableList release];
     
    return [resultList autorelease];
}

#pragma mark - arrange History folder by date

- (NSDate *)convertDateToLocalTimeZone:(NSDate *)sourceDate fromTimeZone:(NSTimeZone *)sourceTimeZone
{
    NSTimeZone *localTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger gmtOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger localOffset = [localTimeZone secondsFromGMTForDate:sourceDate];
    
    NSTimeInterval interval = localOffset - gmtOffset;
    NSDate *currentLocalDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    return [currentLocalDate autorelease];
}

- (NSDate *)newStartOfTheDay:(NSDate *)date
{
    NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:componentFlags fromDate:date];
    NSDate *beginOfTheDay = [calendar dateFromComponents:dateComponents];
    
    return [beginOfTheDay retain];
}

- (NSDate *)newEndOfTheDay:(NSDate *)date
{
    NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:componentFlags fromDate:date];
    dateComponents.hour = 23;
    dateComponents.minute = 59;
    dateComponents.second = 59;
    NSDate *enfOfTheDay = [calendar dateFromComponents:dateComponents];
    
    return [enfOfTheDay retain];
}

- (void)arrangeHistoryContentByDate
{
    BookmarkItem *newFolder = nil;
    
    NSDate *currentDate = [NSDate date];
    NSDate *beginOfTheDay = [self newStartOfTheDay:currentDate];
    
    NSArray *localContent = [NSArray arrayWithArray:self.historyFolder.content];

    for (BookmarkItem *historyBookmark in localContent) {
        if (historyBookmark.isFolder) {
            continue;
        }
        
        if ([beginOfTheDay compare:historyBookmark.date] == NSOrderedDescending) {
            
            NSDate *endOfBookmarksDate = [self newEndOfTheDay:historyBookmark.date];
            NSDate *localBookmarksDate = [self convertDateToLocalTimeZone:historyBookmark.date
                                                             fromTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            
            NSString *newFolderName = [self.dateFormatter stringFromDate:localBookmarksDate];

            NSArray *foldersListNamedByDate = [self.historyFolder.content filteredArrayUsingPredicate:
                                                [NSPredicate predicateWithFormat:@"(name == %@)", newFolderName]];
            
            if (foldersListNamedByDate.count == 0) {
                newFolder = [[[BookmarkItem alloc] initWithName:newFolderName
                                                           url:@""
                                                          date:endOfBookmarksDate
                                                         folder:YES
                                                     permanent:YES] autorelease];
                
                [self addBookmark:newFolder toFolder:self.historyFolder];
            } else {
                newFolder = [foldersListNamedByDate objectAtIndex:0];
            }
            
            [endOfBookmarksDate release];
            [self moveBookmark:historyBookmark toFolder:newFolder];
        }
    }
    
    [beginOfTheDay release];
}

- (void)dealloc
{
    [_rootFolder release];
    _rootFolder = nil;
    [_historyFolder release];
    _historyFolder = nil;

    self.bookmarksList = nil;
    self.dateFormatter = nil;
    self.pathToBundle = nil;
    
    [super dealloc];
}

@end
