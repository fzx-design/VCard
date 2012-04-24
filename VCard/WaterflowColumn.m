//
//  WaterflowColumn.m
//  VCard
//
//  Created by 海山 叶 on 12-4-23.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowColumn.h"

@implementation WaterflowColumn

@synthesize unitContainer = _unitContainer;
@synthesize visibleCells = _visibleCells;
@synthesize currentIndex = _currentIndex;

- (void)addObject:(id)object
{
    [self.unitContainer addObject:object];
}

- (id)objectAtIndex:(int)index
{
    id object = nil;
    if (index < self.unitContainer.count && index > 0) {
        object = [self.unitContainer objectAtIndex:index];
    }
    return object;
}

- (id)currentObject
{
    return [self.unitContainer objectAtIndex:self.currentIndex];
}

- (id)lastObject
{
    return [self.unitContainer lastObject];
}

- (void)clear
{
    [self.unitContainer removeAllObjects];
}

- (NSMutableArray*)unitContainer
{
    if (_unitContainer == nil) {
        _unitContainer = [[NSMutableArray alloc] init];
    }
    return _unitContainer;
}

- (NSMutableArray*)visibleCells
{
    if (_visibleCells == nil) {
        _visibleCells = [[NSMutableArray alloc] init];
    }
    return _visibleCells;
}


@end
