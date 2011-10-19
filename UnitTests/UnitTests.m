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

- (void)testBookmarkStorageLoadingBookmarksTreePermanentPlist
{
    BookmarkItem *rootItem = self.bookmarksStorage.rootItem;
    
    STAssertNotNil(self.bookmarksStorage, @"Bookmark's Storage didn't initialized");
    STAssertNotNil(rootItem, @"Root item didn't initialized");
    STAssertEquals(rootItem.name, @"Bookmarks", @"Invalid root item's name");
    STAssertFalse(rootItem.content.count == 0, @"Root item is empty");
}

@end
