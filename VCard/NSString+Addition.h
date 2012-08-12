//
//  NSString+Addition.h
//  VCard
//
//  Created by 王 紫川 on 12-7-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//



@interface NSString (Addition)

- (NSString *)replaceRegExWithEmoticons;
-(NSString *)stringBetweenString:(NSString *)start andString:(NSString *)end;

@end
