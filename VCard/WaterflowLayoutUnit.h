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
    ImageHeightLow = 250,
    ImageHeightMid = 300,
    ImageHeightHigh = 350,
} ImageHeight;

typedef enum {
    UnitTypeCard,
    UnitTypeDivider,
    UnitTypeNone,
} UnitType;

@interface WaterflowLayoutUnit : NSObject {
    NSInteger _dataIndex;
    CGFloat _upperBound;
    CGFloat _lowerBound;
    int _imageHeight;
    
    NSInteger _unitIndex;
    BOOL _isBlockDivider;
    UnitType _unitType;
}

@property (nonatomic, assign) NSInteger dataIndex;
@property (nonatomic, assign) CGFloat upperBound;
@property (nonatomic, assign) CGFloat lowerBound;
@property (nonatomic, assign) int imageHeight;

@property (nonatomic, assign) NSInteger unitIndex;
@property (nonatomic, assign) BOOL isBlockDivider;
@property (nonatomic, assign) UnitType unitType;

- (BOOL)containOffset:(CGFloat)offset;
- (CGFloat)unitHeight;

@end