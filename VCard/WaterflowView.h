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
#import "PullToRefreshView.h"
#import "BaseLayoutView.h"

#define kWaterflowViewInfoBarViewIndex          100
#define kWaterflowViewPullToRefreshViewIndex    101

@class WaterflowView;


////DataSource and Delegate
@protocol WaterflowViewDatasource <NSObject>
@required
- (WaterflowCell *)flowView:(WaterflowView *)flowView cellForLayoutUnit:(WaterflowLayoutUnit *)layoutUnit;

- (void)flowViewLoadMoreViews;
- (NSInteger)numberOfObjectsInSection;
- (CGFloat)heightForObjectAtIndex:(int)index_ withImageHeight:(NSInteger)imageHeight_;

@end

@protocol WaterflowViewDelegate <NSObject>
@optional
- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)didDragWaterflowViewWithOffset:(CGFloat)offset;
- (void)didSwipeWaterflowView;
- (void)didEndDraggingWaterflowView:(CGFloat)offset;
- (void)didClickReturnToNormalTimelineButton;
@end

////Waterflow View
@interface WaterflowView : UIScrollView<UIScrollViewDelegate>
{
    NSInteger numberOfColumns; 
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
    
    UIImageView *_infoBarView;
    UIButton *_returnButton;
    UILabel *_titleLabel;
    
    BaseLayoutView *_backgroundViewA;
    BaseLayoutView *_backgroundViewB;
}

@property (nonatomic, retain) NSMutableArray *cellHeight; //array of cells height arrays, count = numberofcolumns, and elements in each single child array represents is a total height from this cell to the top
@property (nonatomic, retain) NSMutableArray *visibleCells;  //array of visible cell arrays, count = numberofcolumns
@property (nonatomic, retain) NSMutableDictionary *reusableCells;  //key- identifier, value- array of cells
@property (nonatomic, assign) id <WaterflowViewDelegate> flowdelegate;
@property (nonatomic, assign) id <WaterflowViewDatasource> flowdatasource;

@property (nonatomic, retain) WaterflowColumn *leftColumn;
@property (nonatomic, retain) WaterflowColumn *rightColumn;

@property (nonatomic, retain) BaseLayoutView *backgroundViewA;
@property (nonatomic, retain) BaseLayoutView *backgroundViewB;


- (void)reloadData;
- (void)refresh;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)adjustViewsForOrientation:(UIInterfaceOrientation)orientation;
- (void)prepareLayoutNeedRefresh:(BOOL)needRefresh;

- (void)showInfoBarWithTitleName:(NSString *)name;

@end
