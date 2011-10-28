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

- (NSDate *)convertDateToLocalTimeZoneFromTimeZone:(NSTimeZone *)sourceTimeZone
{
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    
    NSInteger gmtOffset = [localTimeZone secondsFromGMT];
    NSDate *currentLocalDate = [self dateByAddingTimeInterval:gmtOffset];
    
    return currentLocalDate;
}

+ (NSDate *)localDate
{
    NSDate *nowGmt = [NSDate date];
    
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentLocalDate = [nowGmt convertDateToLocalTimeZoneFromTimeZone:gmtTimeZone];
    
    return currentLocalDate;
}

- (NSDate *)convertDateFromGmtToLocal
{
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDate *currentLocalDate = [self convertDateToLocalTimeZoneFromTimeZone:gmtTimeZone];
    
    return currentLocalDate;
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

- (NSDate *)getStartOfAnHour
{
    NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:componentFlags fromDate:self];
    NSDate *beginOfAnHour = [calendar dateFromComponents:dateComponents];
    
    return beginOfAnHour;
}

- (NSDate *)getEndOfAnHour
{
    NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:componentFlags fromDate:self];
    dateComponents.minute = 59;
    dateComponents.second = 59;
    NSDate *enfOfAnHour = [calendar dateFromComponents:dateComponents];
    
    return enfOfAnHour;
}

@end
