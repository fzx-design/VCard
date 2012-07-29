//
//  NSDate+Addition.h
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Addition)

+ (NSDate *)dateFromStringRepresentation:(NSString *)dateString;
- (NSString *)stringRepresentation;
- (NSString *)customString;

@end
