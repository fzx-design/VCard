//
//  ResourceProvider.m
//  VCard
//
//  Created by 海山 叶 on 12-5-8.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ResourceProvider.h"

@implementation ResourceProvider

static ResourceProvider *sharedResourceProvider = nil;

@synthesize systemFont;
@synthesize ctSystemFont;

+ (void)initialize
{
    sharedResourceProvider = [[ResourceProvider alloc] init];
    sharedResourceProvider.systemFont = [UIFont systemFontOfSize:17.0f];
    sharedResourceProvider.ctSystemFont = CTFontCreateWithName((__bridge CFStringRef)sharedResourceProvider.systemFont.fontName, sharedResourceProvider.systemFont.pointSize, NULL);
}

+ (CTFontRef)regexFont
{
    return sharedResourceProvider.ctSystemFont;
}

@end
