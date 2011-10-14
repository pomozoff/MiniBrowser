//
//  BookmarkGroupsTableViewController.h
//  MiniBrowser
//
//  Created by Антон Помозов on 14.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarkItem.h"

@interface BookmarkGroupsTableViewController : UITableViewController

@property (nonatomic, retain) BookmarkItem *bookmarkParent;

@end
