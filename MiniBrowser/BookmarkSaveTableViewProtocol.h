//
//  BookmarkSaveTableViewProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 14.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkItem.h"
#import "BrowserControllerProtocol.h"

@protocol BookmarkSaveTableViewProtocol <NSObject>

@property (nonatomic, retain) id <BookmarksStorageProtocol> bookmarksStorage;
@property (nonatomic, retain) BookmarkItem *bookmark;
@property (nonatomic, retain) BookmarkItem *currentFolder;
@property (nonatomic, retain) UITableView *tableViewParent;
@property (nonatomic, retain) id <BrowserControllerDelegate> delegateBrowserController;

- (void)moveBookmarkToFolder:(BookmarkItem *)bookmarkFolder;

@end
