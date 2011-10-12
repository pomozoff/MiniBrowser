//
//  BookmarksTableViewControllerProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 12.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BookmarksTableViewControllerDelegate <NSObject>

- (void)closePopupsAndLoadUrl:(NSString *)url;

@end
