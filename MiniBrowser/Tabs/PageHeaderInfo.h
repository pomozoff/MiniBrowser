//
//  PageHeaderInfo.h
//  MiniBrowser
//
//  Created by Антон Помозов on 15.12.11.
//  Copyright (c) 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PageHeaderInfo <NSObject>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
