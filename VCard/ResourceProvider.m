//
//  ResourceProvider.m
//  VCard
//
//  Created by 海山 叶 on 12-5-8.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ResourceProvider.h"
#import "ResourceList.h"

@implementation ResourceProvider

static ResourceProvider *sharedResourceProvider = nil;

@synthesize systemFont;
@synthesize ctSystemFont;

@synthesize topImageRef;
@synthesize bottomImageRef;
@synthesize centerTileImage;
@synthesize centerTileImageRef;
@synthesize backgroundTileImageRef;

+ (void)initialize
{
    sharedResourceProvider = [[ResourceProvider alloc] init];
    sharedResourceProvider.systemFont = [UIFont boldSystemFontOfSize:17.0f];
    sharedResourceProvider.ctSystemFont = CTFontCreateWithName((__bridge CFStringRef)sharedResourceProvider.systemFont.fontName, sharedResourceProvider.systemFont.pointSize, NULL);
    
    sharedResourceProvider.topImageRef = [[UIImage imageNamed:kRLCardTop] CGImage];
    sharedResourceProvider.bottomImageRef = [[UIImage imageNamed:kRLCardBottom] CGImage];
    sharedResourceProvider.centerTileImage = [UIImage imageNamed:kRLCardBGUnit];
    sharedResourceProvider.centerTileImageRef = [sharedResourceProvider.centerTileImage CGImage];
    
    sharedResourceProvider.backgroundTileImageRef = [[UIImage imageNamed:kRLCastViewBGUnit] CGImage];
}

+ (CTFontRef)regexFont
{
    return sharedResourceProvider.ctSystemFont;
}

+ (CGImageRef)bottomImageRef
{
    return sharedResourceProvider.bottomImageRef;
}

+ (CGImageRef)centerTileImageRef
{
    return sharedResourceProvider.centerTileImageRef;
}

+ (CGImageRef)topImageRef
{
    return sharedResourceProvider.topImageRef;
}

+ (CGImageRef)backgroundTileImageRef
{
    return sharedResourceProvider.backgroundTileImageRef;
}

@end
