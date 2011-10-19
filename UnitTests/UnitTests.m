//
//  UnitTests.m
//  UnitTests
//
//  Created by Антон Помозов on 19.10.11.
//  Copyright 2011 Штрих-М. All rights reserved.
//

#import "UnitTests.h"
#import "BookmarkItem.h"

@interface UnitTests()

@property (nonatomic, retain) BookmarkItem *bookmark;
@property (nonatomic, copy) NSDate *bookmarkDate;

@end

@implementation UnitTests

@synthesize bookmark = _bookmark;
@synthesize bookmarkDate = _bookmarkDate;

- (void)setUp
{
    [super setUp];

    NSString *bookmarkName = @"bookmark name";
    NSString *bookmarkUrl = @"http://url";
    self.bookmarkDate = [NSDate date];

    self.bookmark = [[BookmarkItem alloc] initWithName:bookmarkName
                                                   url:bookmarkUrl
                                                  date:self.bookmarkDate
                                                 group:NO
                                             permanent:NO];
}

- (void)tearDown
{
    self.bookmark = nil;
    self.bookmarkDate = nil;
    
    [super tearDown];
}

- (void)testExample
{
    STAssertEquals(self.bookmark.name, @"bookmark name", @"Invalid name for new bookmark");
}

@end
