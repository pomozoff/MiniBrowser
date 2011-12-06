//
//  SettingsControllerProtocol.h
//  MiniBrowser
//
//  Created by Антон Помозов on 09.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchEngine.h"

@protocol SettingsControllerProtocol <NSObject>

@property (nonatomic, retain) SearchEngine *currentSearchEngine;

@end
