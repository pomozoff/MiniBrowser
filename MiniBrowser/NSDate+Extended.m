//
//  NSDate+Extended.m
//  MiniBrowser
//
//  Created by Антон Помозов on 21.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "NSDate+Extended.h"

@implementation NSDate (Extended)

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending) 
        return NO;
    
    return YES;
}

- (NSDate *)getStartOfTheDay
{
    NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:componentFlags fromDate:self];
    NSDate *beginOfTheDay = [calendar dateFromComponents:dateComponents];
    
    return beginOfTheDay;
}

- (NSDate *)getEndOfTheDay
{
    NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:componentFlags fromDate:self];
    dateComponents.hour = 23;
    dateComponents.minute = 59;
    dateComponents.second = 59;
    NSDate *enfOfTheDay = [calendar dateFromComponents:dateComponents];
    
    return enfOfTheDay;
}

- (NSDate *)convertDateToLocalTimeZoneFromTimeZone:(NSTimeZone *)sourceTimeZone
{
    NSTimeZone *localTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger gmtOffset = [sourceTimeZone secondsFromGMTForDate:self];
    NSInteger localOffset = [localTimeZone secondsFromGMTForDate:self];
    
    NSTimeInterval interval = localOffset - gmtOffset;
    NSDate *currentLocalDate = [NSDate dateWithTimeInterval:interval sinceDate:self];
    
    return currentLocalDate;
}

- (NSDate *)convertDateToLocalFromGMT
{
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentLocalDate = [self convertDateToLocalTimeZoneFromTimeZone:gmtTimeZone];
    
    return currentLocalDate;
}

@end
