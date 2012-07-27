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
    __block CIImage *processImage = [CIImage imageWithCGImage:image.CGImage];
    [self.filterParameter enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *filterKey = key;
        NSDictionary *param = obj;
        CIFilter *filter = [CIFilter filterWithName:filterKey];
        if(filter == nil)
            abort();
        [filter setDefaults];
        [filter setValue:processImage forKey:@"inputImage"];
        [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *paramKey = key;
            if([obj isKindOfClass:[NSNumber class]]) {
                NSNumber *amount = obj;
                [filter setValue:amount forKey:paramKey];
            } else if([obj isKindOfClass:[NSArray class]]) {
                NSArray *array = obj;
                float rgba[4];
                for(NSUInteger i = 0; i < 4; i++) {
                    NSNumber *component = [array objectAtIndex:i];
                    rgba[i] = component.floatValue;
                }
                CIColor *color = [[CIColor alloc] initWithColor:[UIColor colorWithRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]]];
                [filter setValue:color forKey:paramKey];
            }
        }];
        processImage = [filter outputImage];
    }];
    if(processImage == nil)
        return image;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef ref = [context createCGImage:processImage fromRect:processImage.extent];
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    
    return result;
}

@end
