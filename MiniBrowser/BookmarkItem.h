//
//  BookmarkItem.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BookmarkItem;

@protocol BookmarkItemDelegate <NSObject>

- (void)reloadBookmarksForGroup:(BookmarkItem *)bookmarkGroup;

@end


@interface BookmarkItem : NSObject

@property (nonatomic, copy, readonly) NSString *itemId;
@property (nonatomic, readonly) BOOL isGroup;
@property (nonatomic, readonly) BOOL isPermanent;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, retain) NSArray *content;
@property (nonatomic, retain) id <BookmarkItemDelegate> delegateBookmark;

- (id)initWithName:(NSString *)name
               url:(NSString *)url
             group:(BOOL)isThisAGroup
         permanent:(BOOL)isThisPermanent
          parentId:(NSString *)parentId;

- (BOOL)isEqualToBookmark:(BookmarkItem *)bookmark;

@end
