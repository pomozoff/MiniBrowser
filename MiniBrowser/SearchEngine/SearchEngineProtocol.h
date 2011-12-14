//
//  SearchEngineProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 09.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchEngineProtocol <NSObject>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, copy) NSString *searchUrl;

- (NSURL *)searchUrlForText:(NSString *)text;

@end