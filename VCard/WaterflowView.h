//
//  WaterflowView.h
//  WaterFlowDisplay
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterflowCell.h"
#import "WaterflowColumn.h"
#import "WaterflowLayoutUnit.h"

@class WaterflowView;


////DataSource and Delegate
@protocol WaterflowViewDatasource <NSObject>
@required
- (WaterflowCell *)flowView:(WaterflowView *)flowView cellForLayoutUnit:(WaterflowLayoutUnit *)layoutUnit;

- (NSInteger)numberOfObjectsInSection;
- (CGFloat)heightForObjectAtIndex:(int)index_ withImageHeight:(NSInteger)imageHeight_;

@end

@protocol WaterflowViewDelegate <NSObject>
@required
- (CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

////Waterflow View
@interface WaterflowView : UIScrollView<UIScrollViewDelegate>
{
    NSInteger numberOfColumns ; 
    NSInteger currentPage;
	
	NSMutableArray *_cellHeight; 
	NSMutableArray *_visibleCells; 
	NSMutableDictionary *_reusedCells;
    
    WaterflowColumn *_leftColumn;
    WaterflowColumn *_rightColumn;
	
    id <WaterflowViewDelegate> _flowdelegate;
    id <WaterflowViewDatasource> _flowdatasource;
    
    NSInteger _curObjIndex;
    NSInteger _leftColumnIndex;
    NSInteger _rightColumnIndex;
}

@property (nonatomic, retain) NSMutableArray *cellHeight; //array of cells height arrays, count = numberofcolumns, and elements in each single child array represents is a total height from this cell to the top
@property (nonatomic, retain) NSMutableArray *visibleCells;  //array of visible cell arrays, count = numberofcolumns
@property (nonatomic, retain) NSMutableDictionary *reusableCells;  //key- identifier, value- array of cells
@property (nonatomic, assign) id <WaterflowViewDelegate> flowdelegate;
@property (nonatomic, assign) id <WaterflowViewDatasource> flowdatasource;

@property (nonatomic, retain) WaterflowColumn *leftColumn;
@property (nonatomic, retain) WaterflowColumn *rightColumn;


- (void)reloadData;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)prepareLayoutNeedRefresh:(BOOL)needRefresh;


@end
