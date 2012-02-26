//
//  SearchEngineProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 09.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchEngineProtocol <NSObject>

@property (nonatomic, readonly, copy) NSString *name;

- (NSString *)searchUrlForText:(NSString *)text;

@end
