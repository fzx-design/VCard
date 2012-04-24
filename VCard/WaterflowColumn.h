//
//  WaterflowColumn.h
//  VCard
//
//  Created by 海山 叶 on 12-4-23.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaterflowColumn : NSObject {
    NSMutableArray *_unitContainer;
    NSMutableArray *_visibleCells;
    NSInteger _currentIndex;
}

@property (nonatomic, strong) NSMutableArray *unitContainer;
@property (nonatomic, strong) NSMutableArray *visibleCells; 
@property (nonatomic, assign) NSInteger currentIndex;

- (void)addObject:(id)object;

- (id)objectAtIndex:(int)index;

- (id)lastObject;

- (void)clear;


@end
