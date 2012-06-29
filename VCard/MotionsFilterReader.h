//
//  MotionsFilterReader.h
//  VCard
//
//  Created by 王 紫川 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MotionsFilterReader : NSObject

- (NSArray *)getFilterInfoArray;

@end

@interface MotionsFilterInfo : NSObject

@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSDictionary *filterParameter;
@property (nonatomic, assign) BOOL requirePurchase;

- (UIImage *)processImage:(UIImage *)image;

@end
