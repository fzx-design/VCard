//
//  NSDateAddition.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "NSDateAddition.h"

@implementation NSDate (NSDateAddition)

+ (NSDate *)dateFromStringRepresentation:(NSString *)dateString
{
    time_t timeStamp = 0;
	struct tm created;
	if (dateString) {
		if (strptime([dateString UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([dateString UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		timeStamp = mktime(&created);
	}
    
    NSDate *date = nil;
    
    if (timeStamp) {
        date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    }
    
    return date;
}

- (NSString *)stringRepresentation
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateStr = [formatter stringFromDate:self];
    return dateStr;
}

- (NSString *)customString
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:0];
    NSDate *today0am = [calendar dateFromComponents:components];  
    
    NSTimeInterval time = [today0am timeIntervalSinceDate:self];
    int days = ((int)time)/(3600*24);
    if (time < 0) {
        days = -1;
    }
    days++;
    
    NSString* dateStr;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH:mm" options:0 locale:[NSLocale currentLocale]]];
    NSString* timeStr = [dateFormatter stringFromDate:self];
    switch (days) {
        case 0:
            dateStr = [[NSString alloc] initWithFormat:@"今天 %@",timeStr];
            break;
        case 1:
            dateStr = [[NSString alloc] initWithFormat:@"昨天 %@",timeStr];
            break;
        case 2:
            dateStr = [[NSString alloc] initWithFormat:@"前天 %@",timeStr];
            break;
        case 3:
        case 4:
        case 5:
            dateStr = [[NSString alloc] initWithFormat:@"%d天前 %@", days, timeStr];
        default:
            dateStr = [self stringRepresentation];
            break;
    }
    
    return dateStr;
}

@end
