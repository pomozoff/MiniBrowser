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

- (void)testBookmarkStorageLoadingBookmarksTreePermanentPlistAndArrangeIt
{
    STAssertNotNil(self.bookmarksStorage, @"Bookmark's Storage didn't initialized");

    BookmarkItem *rootItem = self.bookmarksStorage.rootItem;
    STAssertNotNil(rootItem, @"Root item didn't initialized");
    STAssertEqualObjects(rootItem.name, @"Bookmarks", @"Invalid root item name");
    
    NSArray *rootBookmarks = rootItem.content;
    STAssertFalse(rootBookmarks.count < 1, @"Root item is empty - permananet bookmarks didn't loaded");
    
    BookmarkItem *historyFolder = [rootBookmarks objectAtIndex:0];
    STAssertNotNil(historyFolder, @"History Folder is absent");
    STAssertEqualObjects(historyFolder.name, @"History", @"Invalid History Folder name");
    
    NSArray *historyBookmarks = historyFolder.content;
    STAssertFalse(historyBookmarks.count < 1, @"History Folder is empty - permananet bookmarks didn't loaded");
    
//    for (BookmarkItem *historyItem in historyBookmarks) {
//        NSLog([NSString stringWithFormat:@"%@", historyItem]);
//    }
    
    [self.bookmarksStorage arrangeHistoryContentByDate:historyFolder];
}

- (void)testCompareTwoBookmarks
{
    NSDate *currentDate = [NSDate date];
    BookmarkItem *firstBookmark = [[BookmarkItem alloc] initWithName:@"first"
                                                                 url:@""
                                                                date:currentDate
                                                               group:NO
                                                           permanent:NO];

    BookmarkItem *secondBookmark = [[BookmarkItem alloc] initWithName:@"first"
                                                                  url:@""
                                                                 date:currentDate
                                                                group:NO
                                                            permanent:NO];
    STAssertTrue([firstBookmark isEqualToBookmark:secondBookmark], @"Same both bookmarks are not identical");
    
    secondBookmark.date = [NSDate dateWithTimeInterval:-100 sinceDate:currentDate];
    STAssertTrue([firstBookmark isEqualToBookmark:secondBookmark], @"Bookmarks with different date must be identical");
    
    firstBookmark.url = [secondBookmark.url stringByAppendingString:@"1"];
    STAssertFalse([firstBookmark isEqualToBookmark:secondBookmark], @"Bookmarks with different url must be different");

    [secondBookmark release];
    [firstBookmark release];
}

@end
