//
//  BookmarkItem.h
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookmarkItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy, readonly) NSString *itemId;
@property (nonatomic, copy) NSString *parentId;

- (id)initWithName:(NSString *)name url:(NSString *)url parent:(NSString *)parentId;

@end
