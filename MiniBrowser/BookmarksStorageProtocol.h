//
//  BookmarksStorageProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkItem.h"

@protocol BookmarksStorageProtocol <NSObject>

@property (nonatomic, readonly) NSInteger sectionsCount;
@property (nonatomic, readonly, retain) BookmarkItem *rootFolder;
@property (nonatomic, readonly, retain) BookmarkItem *historyFolder;

- (id)initWithPathToBundle:(NSString *)currentPathToBundle;

- (void)arrangeHistoryContentByDate;

- (NSInteger)bookmarksCountForParent:(BookmarkItem *)parentItem;
- (void)moveBookmarkAtPosition:(NSIndexPath *)fromIndexPath
                    toPosition:(NSIndexPath *)toIndexPath
                  insideFolder:(BookmarkItem *)folder;

- (BookmarkItem *)bookmarkById:(NSString *)itemId;
- (BookmarkItem *)bookmarkAtIndex:(NSIndexPath *)indexPath forParent:(BookmarkItem *)parentItem;

- (void)addBookmark:(BookmarkItem *)bookmark toFolder:(BookmarkItem *)bookmarkFolder;
- (void)moveBookmark:(BookmarkItem *)bookmark toFolder:(BookmarkItem *)bookmarkFolder;
- (void)deleteBookmark:(BookmarkItem *)bookmark;

- (NSArray *)bookmarkFoldersWithoutBranch:(BookmarkItem *)branchBookmark;

- (void)saveBookmarks;

@end
