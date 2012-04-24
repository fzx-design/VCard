//
//  WaterflowLayoutUnit.h
//  VCard
//
//  Created by 海山 叶 on 12-4-23.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ColumnDirectionLeft,
    ColumnDirectionRight,
} ColumnDirection;

typedef enum {
    ImageHeightSmall,
    ImageHeightLarge,
} ImageHeight;

@interface WaterflowLayoutUnit : NSObject {
    NSInteger _dataIndex;
    CGFloat _upperBound;
    CGFloat _lowerBound;
    ImageHeight _imageHeight;
    
    NSInteger _unitIndex;
}

@property (nonatomic, assign) NSInteger dataIndex;
@property (nonatomic, assign) CGFloat upperBound;
@property (nonatomic, assign) CGFloat lowerBound;
@property (nonatomic, assign) ImageHeight imageHeight;

@property (nonatomic, assign) NSInteger unitIndex;

- (BOOL)containOffset:(CGFloat)offset;
- (CGFloat)unitHeight;

@end