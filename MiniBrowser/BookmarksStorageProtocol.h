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

- (NSInteger)bookmarksCount;
- (void)addBookmark:(BookmarkItem *)bookmark toGroup:(NSString *)groupId;

- (NSArray *)treeOfTheBookmarks;

@end
