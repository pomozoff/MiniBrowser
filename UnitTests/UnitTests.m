//
//  UnitTests.m
//  UnitTests
//
//  Created by Антон Помозов on 19.10.11.
//  Copyright 2011 Штрих-М. All rights reserved.
//

#import "UnitTests.h"
#import "BookmarksStorage.h"

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
    STAssertNotNil(self.bookmarksStorage, @"Bookmark's Storage didn't initialized");
    
    BookmarkItem *rootFolder = self.bookmarksStorage.rootFolder;
    STAssertNotNil(rootFolder, @"Root item didn't initialized");
    STAssertEqualObjects(rootFolder.name, @"Bookmarks", @"Invalid root item name");
    
    NSArray *rootBookmarks = rootFolder.content;
    STAssertFalse(rootBookmarks.count < 1, @"Root item is empty - permananet bookmarks didn't loaded");
    
    BookmarkItem *historyFolder = [rootBookmarks objectAtIndex:0];
    STAssertNotNil(historyFolder, @"History Folder is absent");
    STAssertEqualObjects(historyFolder.name, @"History", @"Invalid History Folder name");
    
    NSArray *historyBookmarks = historyFolder.content;
    STAssertFalse(historyBookmarks.count < 1, @"History Folder is empty - permananet bookmarks didn't loaded");
    
    [self.bookmarksStorage arrangeHistoryContentByDate];
    STAssertFalse(historyFolder.content.count != 2, @"History Folder now must contain two sub-folders");
}

@end
