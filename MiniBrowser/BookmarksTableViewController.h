//
//  BookmarksTableViewController.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarksTableViewControllerProtocol.h"

@interface BookmarksTableViewController : UITableViewController <UIPopoverControllerDelegate>

@property (nonatomic, retain) id <BookmarksTableViewControllerDelegate> delegateController;

@end
