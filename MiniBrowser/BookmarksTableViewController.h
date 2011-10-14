//
//  BookmarksTableViewController.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserControllerProtocol.h"
#import "BookmarksStorageProtocol.h"

@interface BookmarksTableViewController : UITableViewController <BookmarkItemDelegate>

@property (nonatomic, retain) id <BrowserControllerDelegate> delegateController;
@property (nonatomic, retain) id <BookmarksStorageProtocol> bookmarksStorage;

@end
