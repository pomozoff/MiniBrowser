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

- (NSInteger)bookmarksCountForParent:(BookmarkItem *)parentItem;
- (BookmarkItem *)bookmarkAtIndex:(NSIndexPath *)indexPath forParent:(BookmarkItem *)parentItem;

- (void)insertBookmark:(BookmarkItem *)bookmark;
- (void)deleteBookmark:(BookmarkItem *)bookmark;
- (void)moveBookmarkAtPosition:(NSIndexPath *)fromIndexPath toPosition:(NSIndexPath *)toIndexPath insideGroup:(BookmarkItem *)group;

- (BookmarkItem *)bookmarkById:(NSString *)itemId;
- (void)moveBookmark:(BookmarkItem *)bookmark toGroup:(BookmarkItem *)groupBookmark;

@end
