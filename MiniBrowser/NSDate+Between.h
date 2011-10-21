//
//  NSDate+Between.h
//  MiniBrowser
//
//  Created by Антон Помозов on 21.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Between)

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

@end
