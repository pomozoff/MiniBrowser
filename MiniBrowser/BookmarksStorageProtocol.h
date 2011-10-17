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
@property (nonatomic, readonly, retain) NSArray *groupsTreeList;
@property (nonatomic, readonly, retain) BookmarkItem *rootItem;
@property (nonatomic, readonly, retain) BookmarkItem *historyGroup;

- (NSInteger)bookmarksCountForParent:(BookmarkItem *)parentItem;
- (void)moveBookmarkAtPosition:(NSIndexPath *)fromIndexPath toPosition:(NSIndexPath *)toIndexPath insideGroup:(BookmarkItem *)group;

- (BookmarkItem *)bookmarkById:(NSString *)itemId;
- (BookmarkItem *)bookmarkAtIndex:(NSIndexPath *)indexPath forParent:(BookmarkItem *)parentItem;

- (void)addBookmark:(BookmarkItem *)bookmark toGroup:(BookmarkItem *)bookmarkGroup;
- (void)moveBookmark:(BookmarkItem *)bookmark toGroup:(BookmarkItem *)groupBookmark;
- (void)deleteBookmark:(BookmarkItem *)bookmark;

- (void)addHistoryBookmark:(BookmarkItem *)bookmark;

- (NSArray *)bookmarkGroupsWithoutBranch:(BookmarkItem *)branchBookmark;

@end
