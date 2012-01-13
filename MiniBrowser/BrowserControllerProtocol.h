//
//  BrowserControllerProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 12.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkItem.h"

@class TabPageData;

@protocol BrowserControllerDelegate <NSObject>

@property (nonatomic, assign) BOOL isIPad;

- (void)closePopupsAndLoadUrl:(NSString *)url;
- (void)dismissPopoverActionAndCleanUp;
- (void)placeScreenshotOnPageViewFromPageData:(TabPageData *)pageData;
- (void)closePageAtIndex:(NSInteger)index;

@end
