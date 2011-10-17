//
//  BookmarkSaveProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookmarkItem.h"

@protocol BookmarkSaveProtocol <NSObject>

@property (nonatomic, readonly) NSInteger sectionsCount;

- (NSInteger)numberOfRowsForSection:(NSInteger)section forBookmark:(BookmarkItem *)bookmark;

@end
