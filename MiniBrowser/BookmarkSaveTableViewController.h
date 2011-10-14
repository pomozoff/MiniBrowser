//
//  BookmarkSaveTableViewController.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarkItem.h"
#import "BookmarksStorageProtocol.h"

@interface BookmarkSaveTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, retain) BookmarkItem *bookmark;
@property (nonatomic, retain) id <BookmarksStorageProtocol> bookmarksStorage;
@property (nonatomic, retain) UITableView *tableViewParent;
@property (nonatomic, retain) NSIndexPath *indexPath;

@end
