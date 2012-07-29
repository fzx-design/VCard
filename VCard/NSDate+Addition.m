//
//  NSDate+Addition.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "NSDate+Addition.h"

@implementation NSDate (Addition)

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
    
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:now];
    int currentYear = [dd year];
    dd = [cal components:unitFlags fromDate:self];
    int targetYear = [dd year];
    
    if (currentYear != targetYear) {
        [formatter setDateFormat:@"yyyy年M月d日 HH:mm"];
    } else {
        [formatter setDateFormat:@"M月d日 HH:mm"];
    }
    
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
    NSDate *date = [NSDate date];
    
    NSTimeInterval seconds = [date timeIntervalSinceDate:self];
    int minutes = floor(seconds / 60);
    if (minutes == 0) {
        return [NSString stringWithFormat:@" 刚刚更新 "];
    } else if (minutes < 60){
        return [NSString stringWithFormat:@"%d 分钟前", minutes];
    }
    
    NSString* dateStr;
    NSTimeInterval time = [today0am timeIntervalSinceDate:self];
    int days = ((int)time)/(3600*24);
    if (time < 0) {
        days = -1;
    }
    days++;
    
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
