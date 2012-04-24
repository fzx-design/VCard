//
//  WaterflowLayoutUnit.m
//  VCard
//
//  Created by 海山 叶 on 12-4-23.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowLayoutUnit.h"

@implementation WaterflowLayoutUnit

@synthesize dataIndex = _dataIndex;
@synthesize upperBound = _upperBound;
@synthesize lowerBound = _lowerBound;
@synthesize imageHeight = _imageHeight;

@synthesize unitIndex = _unitIndex;

- (BOOL)containOffset:(CGFloat)offset
{
    return _upperBound <= offset && _lowerBound > offset;
}

- (CGFloat)unitHeight
{
    return _lowerBound - _upperBound;
}

@end
