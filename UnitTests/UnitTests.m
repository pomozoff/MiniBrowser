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

- (void)test1AddNewBookmark
{
    // New bookmark
    NSDate *currentDate = [NSDate date];
    BookmarkItem *newBookmark = [[BookmarkItem alloc] initWithName:@"test bookmark"
                                                               url:@"http://test.com"
                                                              date:currentDate
                                                            folder:NO
                                                         permanent:NO];
    
    // Add new bookmark to list
    BookmarkItem *rootBookmark = self.bookmarksStorage.rootFolder;
    [self.bookmarksStorage addBookmark:newBookmark toFolder:rootBookmark];
    
    // Check parentId property
    STAssertEqualObjects(newBookmark.parentId, rootBookmark.itemId, @"Wrong parentId property value in just created bookmark");
    
    // New bookmark must be in list
    BookmarkItem *itemFromList = [self.bookmarksStorage bookmarkById:newBookmark.itemId];
    STAssertNotNil(itemFromList, @"Just created bookmark not found in bookmarks list");
    
    // Move bookmark to new folder
    BookmarkItem *newFolder = [[BookmarkItem alloc] initWithName:@"test folder"
                                                             url:@""
                                                            date:currentDate
                                                          folder:YES
                                                       permanent:NO];
    [self.bookmarksStorage moveBookmark:newBookmark toFolder:newFolder];
    
    // Moved bookmark still must be in list
    BookmarkItem *movedItemFromList = [self.bookmarksStorage bookmarkById:newBookmark.itemId];
    STAssertNotNil(movedItemFromList, @"Moved bookmark not found in bookmarks list");
    
    // Check new parentId property
    STAssertEqualObjects(newBookmark.parentId, newFolder.itemId, @"Wrong parentId property value in moved bookmark");
}

- (void)test2CompareTwoBookmarks
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
    
    //    for (BookmarkItem *historyItem in historyBookmarks) {
    //        NSLog([NSString stringWithFormat:@"%@", historyItem]);
    //    }
    
    //    [self.bookmarksStorage arrangeHistoryContentByDate];
    //    STAssertFalse(historyFolder.content.count != 2, @"History Folder must contract to two folders");
}

@end
