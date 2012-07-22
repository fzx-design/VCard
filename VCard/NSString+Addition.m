//
//  NSString+Addition.m
//  VCard
//
//  Created by 王 紫川 on 12-7-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "NSString+Addition.h"
#import "EmoticonsInfoReader.h"

#define EMOTICONS_IDENTIFIER_REG_EX @" \\[[[a-f][0-9] ]*\\] "

@implementation NSString (Addition)

- (NSString *)replaceRegEx:(NSString *)regEx withString:(NSString *)substitute {
    NSString *returnString = [NSString stringWithFormat:@"%@", self];
    NSRange searchRange = NSMakeRange(0, returnString.length);
    NSRange range = [returnString rangeOfString:regEx options:NSRegularExpressionSearch];
    while(range.location != NSNotFound) {
        returnString = [returnString stringByReplacingCharactersInRange:range withString:substitute];
        NSUInteger newRangeLoc = range.location + substitute.length;
        searchRange = NSMakeRange(newRangeLoc, returnString.length - newRangeLoc);
        range = [returnString rangeOfString:regEx options:NSRegularExpressionSearch range:searchRange];
    }
    return returnString;
}

- (NSString *)replaceRegExWithEmoticons {
    NSString *returnString = [NSString stringWithFormat:@"%@", self];
    NSRange searchRange = NSMakeRange(0, returnString.length);
    
    NSRange range = [returnString rangeOfString:EMOTICONS_IDENTIFIER_REG_EX options:NSRegularExpressionSearch];
    while(range.location != NSNotFound) {
        NSString *regString = [returnString substringWithRange:range];
        EmoticonsInfo *info = [[EmoticonsInfoReader sharedReader] emoticonsInfoForIdentifier:regString];
        if(info == nil)
            continue;
        
        NSString *substitute = [NSString stringWithFormat:@"[%@]", info.keyName];
        
        NSLog(@"reString:%@, substitute:%@", regString, substitute);
        
        returnString = [returnString stringByReplacingCharactersInRange:range withString:substitute];
        NSUInteger newRangeLoc = range.location + substitute.length;
        searchRange = NSMakeRange(newRangeLoc, returnString.length - newRangeLoc);
        
        range = [returnString rangeOfString:EMOTICONS_IDENTIFIER_REG_EX options:NSRegularExpressionSearch range:searchRange];
    }
    return returnString;
}

@end
