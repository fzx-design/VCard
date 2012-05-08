//
//  ResourceProvider.h
//  VCard
//
//  Created by 海山 叶 on 12-5-8.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface ResourceProvider : NSObject

@property (nonatomic, strong) UIFont* systemFont;
@property (nonatomic, assign) CTFontRef ctSystemFont;

+ (CTFontRef)regexFont;

@end
