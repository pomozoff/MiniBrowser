//
//  SettingsControllerProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 09.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchEngineProtocol.h"

@protocol SettingsControllerProtocol <NSObject>

@property (nonatomic, retain) id<SearchEngineProtocol> currentSearchEngine;

@end
