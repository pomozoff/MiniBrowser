//
//  MiniBrowserAppDelegate.h
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserController.h"

#define TABS_AMOUNT_IPAD 9
#define TABS_AMOUNT_IPHONE 8

@interface MiniBrowserAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) BrowserController *browserController;
@property (nonatomic, copy) NSString *nibName;

@end
