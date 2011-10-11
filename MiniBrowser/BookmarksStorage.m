//
//  BookmarksStorage.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarksStorage.h"

@interface BookmarksStorage()

@property (nonatomic, retain) NSArray *bookmarksList;
//@property (nonatomic, retain) NSDictionary *bookmarksDetails;

@end

@implementation BookmarksStorage

@synthesize sectionsCount = _sectionsCount;
@synthesize bookmarksList = _bookmarksList;

NSString *const savedBookmarks = @"savedBookmarks";

- (NSInteger)sectionsCount
{
    return 1;
}

- (NSArray *)bookmarksList
{
    if (!_bookmarksList) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        
        NSArray *tmpBookmarks = [defaults objectForKey:savedBookmarks];
        
        if (!tmpBookmarks) {
            _bookmarksList = [[NSArray alloc] init];
        } else {
            _bookmarksList = [tmpBookmarks retain];
        }
    }
    
    return _bookmarksList;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSInteger)bookmarksCount
{
    return self.bookmarksList.count;
}

- (void)addBookmark:(BookmarkItem *)bookmark
{
    NSMutableArray *mutBookmarks = [self.bookmarksList mutableCopy];
    [mutBookmarks release];
}

- (void)dealloc
{
    self.bookmarksList = nil;
    
    [super dealloc];
}

@end
