//
//  NSDate+Extended.h
//  MiniBrowser
//
//  Created by Антон Помозов on 21.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extended)

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
+ (NSDate *)localDate;

- (NSDate *)getEndOfAMinute;
- (NSDate *)getStartOfAMinute;
- (NSDate *)getStartOfAnHour;
- (NSDate *)getEndOfAnHour;
- (NSDate *)getStartOfTheDay;
- (NSDate *)getEndOfTheDay;
- (NSDate *)convertDateToLocalTimeZoneFromTimeZone:(NSTimeZone *)sourceTimeZone;
- (NSDate *)convertDateFromGmtToLocal;

@end
