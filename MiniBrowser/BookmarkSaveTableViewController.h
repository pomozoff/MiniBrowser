//
//  BookmarkSaveTableViewController.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarkItem.h"

@interface BookmarkSaveTableViewController : UITableViewController <UIPopoverControllerDelegate,
                                                                    UITextFieldDelegate>

@property (nonatomic, retain) BookmarkItem *bookmark;

@end
