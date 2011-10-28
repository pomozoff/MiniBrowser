//
//  UnitTests.m
//  UnitTests
//
//  Created by Антон Помозов on 19.10.11.
//  Copyright 2011 Штрих-М. All rights reserved.
//

#import "UnitTests.h"
#import "BookmarksStorage.h"
#import "NSDate+Extended.h"

@interface UnitTests()

@property (nonatomic, retain) BookmarksStorage *bookmarksStorage;

@end

@implementation UnitTests

@synthesize bookmarksStorage = _bookmarksStorage;

- (BookmarksStorage *)bookmarksStorage
{
    if (!_bookmarksStorage) {
        NSString *testsBundlePath = [[NSBundle bundleForClass:[UnitTests class]] bundlePath];
        _bookmarksStorage = [[BookmarksStorage alloc] initWithPathToBundle:testsBundlePath];
    }
    
    return _bookmarksStorage;
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    self.bookmarksStorage = nil;
    
    [super tearDown];
}

- (void)test0TestExtendedDateMeyhods
{
    NSDate *now = [NSDate date];
    NSDate *startOfAnHour = [now getStartOfAnHour];
    NSDate *endOfAnHour = [now getEndOfAnHour];
    NSDate *expectedDate = [startOfAnHour dateByAddingTimeInterval:(60*60 - 1)];
    STAssertEqualObjects(endOfAnHour, expectedDate, @"The end jo an hour is not equals expected");
}

- (void)test1CompareTwoBookmarks
{
    NSDate *currentDate = [NSDate date];
    BookmarkItem *firstBookmark = [[BookmarkItem alloc] initWithName:@"first"
                                                                 url:@""
                                                                date:currentDate
                                                              folder:NO
                                                           permanent:NO];
    
    BookmarkItem *secondBookmark = [[BookmarkItem alloc] initWithName:@"first"
                                                                  url:@""
                                                                 date:currentDate
                                                               folder:NO
                                                            permanent:NO];
    STAssertTrue([firstBookmark isEqualToBookmark:secondBookmark], @"Same both bookmarks are not identical");
    
    secondBookmark.date = [NSDate dateWithTimeInterval:-100 sinceDate:currentDate];
    STAssertTrue([firstBookmark isEqualToBookmark:secondBookmark], @"Bookmarks with different date must be identical");
    
    firstBookmark.url = [secondBookmark.url stringByAppendingString:@"1"];
    STAssertFalse([firstBookmark isEqualToBookmark:secondBookmark], @"Bookmarks with different url must be different");
    
    [secondBookmark release];
    [firstBookmark release];
}

- (void)test2BookmarksManipulation
{
    BookmarkItem *rootBookmark = self.bookmarksStorage.rootFolder;
    
    // Try add nil to folder
    NSInteger count = rootBookmark.content.count;
    [self.bookmarksStorage addBookmark:nil toFolder:rootBookmark];
    STAssertTrue(count == rootBookmark.content.count, @"The nil just has been added to bookmark's folder");

    // New bookmark
    NSDate *currentDate = [NSDate date];
    BookmarkItem *newBookmark = [[BookmarkItem alloc] initWithName:@"test bookmark"
                                                               url:@"http://test.com"
                                                              date:currentDate
                                                            folder:NO
                                                         permanent:NO];
    
    // Try add bookmark to nil
    [self.bookmarksStorage addBookmark:newBookmark toFolder:nil];
    
    // New bookmark must be in general bookmarks list
    BookmarkItem *itemFromGeneralList = [self.bookmarksStorage bookmarkById:newBookmark.itemId];
    STAssertNotNil(itemFromGeneralList, @"Just created bookmark not found in general bookmark's list");
    
    // Add new bookmark to list
    [self.bookmarksStorage addBookmark:newBookmark toFolder:rootBookmark];
    
    // Check parentId property
    STAssertEqualObjects(newBookmark.parentId, rootBookmark.itemId, @"Wrong parentId property value in just created bookmark");
    
    // New bookmark must be in current folder's list
    NSArray *bookmarksListNamedById = [rootBookmark.content filteredArrayUsingPredicate:
                                       [NSPredicate predicateWithFormat:@"(itemId == %@)", newBookmark.itemId]];

    STAssertTrue(bookmarksListNamedById.count == 1, @"Count of the found bookmarks must be one, instead of %d", bookmarksListNamedById.count);
    
    BookmarkItem *itemFromFolderList = [bookmarksListNamedById objectAtIndex:0];
    STAssertEqualObjects(itemFromFolderList, newBookmark, @"Just created bookmark not found in folder's list, found: %@", itemFromFolderList);
    
    // Move bookmark to new folder
    BookmarkItem *newFolder = [[BookmarkItem alloc] initWithName:@"test folder"
                                                             url:@""
                                                            date:currentDate
                                                          folder:YES
                                                       permanent:NO];
    [self.bookmarksStorage moveBookmark:newBookmark toFolder:newFolder];
    
    // Moved bookmark still must be in list
    BookmarkItem *sameItemFromList = [self.bookmarksStorage bookmarkById:newBookmark.itemId];
    STAssertNotNil(sameItemFromList, @"Moved bookmark not found in bookmarks list");
    
    // Check new parentId property
    STAssertEqualObjects(newBookmark.parentId, newFolder.itemId, @"Wrong parentId property value in just moved bookmark");
 
    [newBookmark release];
    [newFolder release];
}

- (void)test3BookmarkStorageLoadingBookmarksTreePermanentPlistAndArrangeIt
{
    // Check init Bookmark's Storage
    STAssertNotNil(self.bookmarksStorage, @"Bookmark's Storage didn't initialized");
    
    // Check init Root Folder and it's name
    BookmarkItem *rootFolder = self.bookmarksStorage.rootFolder;
    STAssertNotNil(rootFolder, @"Root item didn't initialized");
    STAssertEqualObjects(rootFolder.name, @"Bookmarks", @"Invalid root item name");
    
    // Check loaded bookmarks from BookmarkTreePermanent.plist
    NSArray *rootBookmarks = rootFolder.content;
    STAssertFalse(rootBookmarks.count < 1, @"Root item is empty - permananet bookmarks didn't loaded");
    
    // Check History Folder presence
    BookmarkItem *historyFolder = [rootBookmarks objectAtIndex:0];
    STAssertNotNil(historyFolder, @"History Folder is absent");
    STAssertEqualObjects(historyFolder.name, @"History", @"Invalid History Folder name");
    
    // Check history bookmarks loaded from BookmarkTreePermanent.plist
    NSArray *historyBookmarks = historyFolder.content;
    STAssertFalse(historyBookmarks.count < 1, @"History Folder is empty - permananet bookmarks didn't loaded");
    
    // Get first bookmark in history folder
    BookmarkItem *firstInHistoryFolder = [historyBookmarks objectAtIndex:0];
    NSDate *firstBookmarkDate = firstInHistoryFolder.date;
    
    // Prepare date formatter date (to string conversion)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEEE, MMM d";
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    
    // Check History Folder rearranged itself by dates
    [self.bookmarksStorage arrangeHistoryContentByDate];
    STAssertFalse(historyFolder.content.count != 3, @"History Folder now must contains three sub-folders, instead %d", historyFolder.content.count);

    // Check only sub-folders must stay in History Folders
    BookmarkItem *firstSubFolder = [[historyFolder.content objectAtIndex:0] retain];
    STAssertTrue(firstSubFolder.isFolder, @"The first item in History Folder isn't folder");

    // Check the first folder's date same with first history bookmark
    NSString *expectedName = [dateFormatter stringFromDate:firstBookmarkDate];//@"Monday, Oct 17";
    STAssertEqualObjects(firstSubFolder.name, expectedName, @"The first sub-folder in arranged History Folder has wrong name");
    
    // Check for clearing History Folder
    [self.bookmarksStorage clearFolder:historyFolder];
    STAssertTrue(historyFolder.content.count == 0, @"History Folder didn't cleared");
    
    // Check the first sub-folder in History Folder contains any items
    STAssertTrue(firstSubFolder.content.count == 0, @"The first sub-folder in History Folder still contains items");
    [firstSubFolder release];
    
    // Check presence of the first sub-folder in general bookmark's list
    BookmarkItem *itemFromGeneralList = [self.bookmarksStorage bookmarkById:firstSubFolder.itemId];
    STAssertEqualObjects(itemFromGeneralList, self.bookmarksStorage.rootFolder, @"The first sub-folder in History Folder still presence in general bookmark's list");
}

@end
