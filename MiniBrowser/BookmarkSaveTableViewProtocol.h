//
//  BookmarkSaveTableViewProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 14.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkItem.h"

@protocol BookmarkSaveTableViewProtocol <NSObject>

- (void)moveBookmarkToGroup:(BookmarkItem *)groupBookmark;

@end
