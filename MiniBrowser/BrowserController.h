//
//  BrowserController.h
//  MiniBrowser
//
//  Created by Anton Pomozov on 05.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserController : UIViewController <UIWebViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIToolbar *navigationToolbar;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIBarItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarItem *bookmarkButton;
@property (nonatomic, retain) IBOutlet UITextField *urlField;
@property (nonatomic, retain) IBOutlet UILabel *urlLabel;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
