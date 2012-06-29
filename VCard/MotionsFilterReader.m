//
//  MotionsFilterReader.m
//  VCard
//
//  Created by 王 紫川 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsFilterReader.h"

#define kFilterName         @"FilterName"
#define kFilterParameter    @"FilterParameter"
#define kRequirePurchase    @"RequirePurchase"

@interface MotionsFilterReader()

@property (nonatomic, strong) NSArray *filterInfoOriginalArray;
@property (nonatomic, strong) NSArray *filterInfoArray;

@end

@implementation MotionsFilterReader

@synthesize filterInfoArray = _filterInfoArray;
@synthesize filterInfoOriginalArray = _filterInfoOriginalArray;

- (id)init {
    self = [super init];
    if(self) {
        [self readPlist];
    }
    return self;
}

- (void)readPlist {
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"MotionsFilterInfo" ofType:@"plist"];  
    self.filterInfoOriginalArray = [[NSArray alloc] initWithContentsOfFile:configFilePath];
}

- (NSArray *)getFilterInfoArray {
    if(!self.filterInfoArray) {
        [self configureFilterInfoArray];
    }
    return self.filterInfoArray;
}

- (void)configureFilterInfoArray {
    __block NSMutableArray *infoArray = [NSMutableArray array];
    [self.filterInfoOriginalArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = obj;
        NSString *filterName = [dict objectForKey:kFilterName];
        NSDictionary *filterPara = [dict objectForKey:kFilterParameter];
        NSNumber *iap = [dict objectForKey:kRequirePurchase];
        MotionsFilterInfo *info = [[MotionsFilterInfo alloc] init];
        info.filterName = filterName;
        info.filterParameter = filterPara;
        info.requirePurchase = iap.boolValue;
        [infoArray addObject:info];
    }];
    self.filterInfoArray = infoArray;
}

@end

@implementation MotionsFilterInfo

@synthesize filterName = _filterName;
@synthesize filterParameter = _filterParameter;
@synthesize requirePurchase = _requirePurchase;

- (UIImage *)processImage:(UIImage *)image {
    UIImage *result = nil;
    return result;
}

@end
