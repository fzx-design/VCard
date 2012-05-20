//
//  WaterflowView.m
//  WaterFlowDisplay
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowView.h"
#import "ResourceList.h"
#import <QuartzCore/QuartzCore.h>

#define LeftColumnLandscapeOriginX 120
#define LeftColumnPortraitOriginX 14
#define RightColumnLandscapeOriginX 540
#define RightColumnPortraitOriginX 389

@implementation WaterflowView

@synthesize cellHeight = _cellHeight;
@synthesize visibleCells =_visibleCells;
@synthesize reusableCells = _reusedCells;
@synthesize flowdelegate = _flowdelegate;
@synthesize flowdatasource =_flowdatasource;
@synthesize rightColumn = _rightColumn;
@synthesize leftColumn = _leftColumn;
@synthesize backgroundViewA = _backgroundViewA;
@synthesize backgroundViewB = _backgroundViewB;

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = YES;
		self.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(cellSelected:)
                                                     name:@"CellSelected"
                                                   object:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = YES;
		self.delegate = self;
                
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(cellSelected:)
                                                     name:@"CellSelected"
                                                   object:nil];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"CellSelected"
                                                  object:nil];
    
    self.cellHeight = nil;
    self.visibleCells = nil;
    self.reusableCells = nil;
    self.flowdatasource = nil;
    self.flowdelegate = nil;
    self.rightColumn = nil;
    self.leftColumn = nil;
    
    [super dealloc];
}

- (void)setFlowdatasource:(id<WaterflowViewDatasource>)flowdatasource
{
    _flowdatasource = flowdatasource;
}

- (void)setFlowdelegate:(id<WaterflowViewDelegate>)flowdelegate
{
    _flowdelegate = flowdelegate;
}

- (void)adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    [self resetContentSize:orientation];
    
    CGFloat leftOriginX = UIInterfaceOrientationIsPortrait(orientation) ? LeftColumnPortraitOriginX : LeftColumnLandscapeOriginX;
    CGFloat rightOriginX = UIInterfaceOrientationIsPortrait(orientation) ? RightColumnPortraitOriginX : RightColumnLandscapeOriginX;
    
    [self reLayoutCellsIn:self.leftColumn.visibleCells withOriginx:leftOriginX];
    [self reLayoutCellsIn:self.rightColumn.visibleCells withOriginx:rightOriginX];
}

- (void)reLayoutCellsIn:(NSMutableArray*)visibleCells withOriginx:(CGFloat)originX
{
    for (UIView *cell in visibleCells) {
        CGRect frame = cell.frame;
        frame.origin.x = originX;
        cell.frame = frame;
    }
}

- (void)resetContentSize:(UIInterfaceOrientation)orientation
{
    CGFloat width = UIInterfaceOrientationIsPortrait(orientation) ? 768 : 1024;
    CGFloat height = [self heightOfWaterflowView];
    
    self.contentSize = CGSizeMake(width, height);
}

- (UIInterfaceOrientation)currentOrientation
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - Process Notification
- (void)cellSelected:(NSNotification *)notification
{
    if ([self.flowdelegate respondsToSelector:@selector(flowView:didSelectRowAtIndexPath:)]) {
        [self.flowdelegate flowView:self didSelectRowAtIndexPath:((WaterflowCell*)notification.object).indexPath];
    }
}

#pragma mark - Reuse Cells
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (!identifier || identifier == 0 ) {
        return nil;
    }
    
    NSArray *cellsWithIndentifier = [NSArray arrayWithArray:[self.reusableCells objectForKey:identifier]];
    if (cellsWithIndentifier &&  cellsWithIndentifier.count > 0) {
        WaterflowCell *cell = [cellsWithIndentifier lastObject];
        [[cell retain] autorelease];
        [[self.reusableCells objectForKey:identifier] removeLastObject];
        return cell;
    }
    return nil;
}

- (void)recycleCellIntoReusableQueue:(WaterflowCell *)cell
{
    if(!self.reusableCells) {
        self.reusableCells = [NSMutableDictionary dictionary];
        NSMutableArray *array = [NSMutableArray arrayWithObject:cell];
        [self.reusableCells setObject:array forKey:cell.reuseIdentifier];
        
    } else {
        if (![self.reusableCells objectForKey:cell.reuseIdentifier]) { 
            NSMutableArray *array = [NSMutableArray arrayWithObject:cell];
            [self.reusableCells setObject:array forKey:cell.reuseIdentifier];
        } else {
            [[self.reusableCells objectForKey:cell.reuseIdentifier] addObject:cell];
            
        }
    }
}

#pragma mark - methods
- (void)reloadData
{
    [self reLayoutNeedRefresh:NO];
}

- (void)refresh
{
    [self reLayoutNeedRefresh:YES];
}

- (void)recycleVisuableCellsInColumn:(WaterflowColumn *)column
{
    for (id cell in column.visibleCells) {
        [self recycleCellIntoReusableQueue:(WaterflowCell*)cell];
        [cell removeFromSuperview];
        [cell prepareForReuse];
    }
}

- (void)reLayoutNeedRefresh:(BOOL)needRefresh
{
    [self prepareLayoutNeedRefresh:needRefresh];
    
    [self resetContentSize:[self currentOrientation]];
    
    [self pageScroll];
    
    [self loadImageInCells];
}

- (void)prepareLayoutNeedRefresh:(BOOL)needRefresh
{
    if (needRefresh) {
        _curObjIndex = 0;
        
        for (WaterflowCell *cell in self.leftColumn.visibleCells) {
            [cell removeFromSuperview];
            [cell prepareForReuse];
            [self recycleCellIntoReusableQueue:cell];
        }
        for (WaterflowCell *cell in self.rightColumn.visibleCells) {
            [cell removeFromSuperview];
            [cell prepareForReuse];
            [self recycleCellIntoReusableQueue:cell];
        }
        
        [self.leftColumn clear];
        [self.rightColumn clear];
    }
    
    int numberOfObjectsInSection = [self.flowdatasource numberOfObjectsInSection];
    
    for (  ; _curObjIndex < numberOfObjectsInSection; _curObjIndex++) {
        
        CGFloat imageHeight = [self randomImageHeight];
        
        WaterflowColumn *targetColumn = [self selectColumnToInsert];
        WaterflowLayoutUnit *currentUnit = [[[WaterflowLayoutUnit alloc] init] autorelease];
        WaterflowLayoutUnit *lastUnit = (WaterflowLayoutUnit*)[targetColumn lastObject];
        
        CGFloat height = [self.flowdatasource heightForObjectAtIndex:_curObjIndex withImageHeight:imageHeight];
        
        currentUnit.upperBound = lastUnit ? lastUnit.lowerBound : 0;
        currentUnit.lowerBound = currentUnit.upperBound + height;
        currentUnit.dataIndex = _curObjIndex;

        currentUnit.imageHeight = imageHeight;
        
        currentUnit.unitIndex = targetColumn.unitContainer.count;
        
        [targetColumn addObject:currentUnit];
    }
    
}

- (CGFloat)randomImageHeight
{
    NSInteger factor = arc4random() % 3;
    CGFloat imageHeight = 0.0;
        
    switch (factor) {
        case 0:
            imageHeight = ImageHeightLow;
            break;
        case 1:
            imageHeight = ImageHeightMid;
            break;
        default:
            imageHeight = ImageHeightHigh;
            break;
    }
    return imageHeight;
}

- (CGFloat)heightOfWaterflowView
{
    CGFloat height = 0;
    WaterflowLayoutUnit *leftUnit = (WaterflowLayoutUnit*)[self.leftColumn lastObject];
    WaterflowLayoutUnit *rightUnit = (WaterflowLayoutUnit*)[self.rightColumn lastObject];
    if (leftUnit) {
        height = leftUnit.lowerBound + 20;
    }
    if (rightUnit) {
        height = height > rightUnit.lowerBound + 20 ? height : rightUnit.lowerBound + 20;
    }
    
    return height;
}
 
#pragma mark - Layout Subviews

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [self loadImageInCells];
}

- (void)loadImageInCells
{
    for (WaterflowCell *cell in self.leftColumn.visibleCells) {
        [cell loadImageAfterScrollingStop];
    }
    for (WaterflowCell *cell in self.rightColumn.visibleCells) {
        [cell loadImageAfterScrollingStop];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self pageScroll];
    
    [self loadImageInCells];
    
    [self checkLoadMore];
}

- (void)checkLoadMore
{
    if (self.contentOffset.y > self.contentSize.height - 700.0) {
        [self.flowdatasource flowViewLoadMoreViews];
    }
}

- (void)pageScroll
{
    [self adjustBackgroundView];
    [self layoutCellsInColumnDirection:ColumnDirectionLeft];
    [self layoutCellsInColumnDirection:ColumnDirectionRight];
}

- (void)layoutCellsInColumnDirection:(ColumnDirection)direction
{
    CGFloat origin_x = [self originXForColumn:direction];
    CGFloat width = 345.0;
    
    WaterflowColumn *column = direction == ColumnDirectionLeft ? self.leftColumn : self.rightColumn;
    
    WaterflowLayoutUnit *currentUnit = [self currentUnitIndexInColumn:column];
    
    if (currentUnit == nil) {
        return;
    }
    
    WaterflowCell *cell = nil;
    
    if (column.visibleCells.count == 0 || column.visibleCells.lastObject == nil)  {
        
        CGFloat origin_y = currentUnit.upperBound;
        CGFloat height = [currentUnit unitHeight];
        
        
        cell = [_flowdatasource flowView:self cellForLayoutUnit:currentUnit];
        cell.indexPath = [NSIndexPath indexPathForRow: currentUnit.unitIndex inSection:direction];
        cell.frame = CGRectMake(origin_x, origin_y, width, height);
        [self addSubview:cell];
        [column.visibleCells insertObject:cell atIndex:0];
    } else {
        cell = [column.visibleCells objectAtIndex:0];
    }
    
    //base on this cell at rowToDisplay and process the other cells
    //1. add cell above this basic cell if there's margin between basic cell and top
    while ( cell && ((cell.frame.origin.y - self.contentOffset.y) > 0.0001)) 
    {
        float origin_y = 0;
        float height = 0;
        int unitIndex = cell.indexPath.row;
        
        if(unitIndex == 0) {
            cell = nil;
            break;
        }
        
        WaterflowLayoutUnit *unit = [column.unitContainer objectAtIndex:unitIndex - 1];
        origin_y = unit.upperBound;
        height = [unit unitHeight];
        
        cell = [self.flowdatasource flowView:self cellForLayoutUnit:unit];
        cell.indexPath = [NSIndexPath indexPathForRow:unit.unitIndex inSection:direction];
        cell.frame = CGRectMake(origin_x, origin_y , width, height);
        [column.visibleCells insertObject:cell atIndex:0];
        
        [self addSubview:cell];
    }
    
    //2. remove cell above this basic cell if there's no margin between basic cell and top
    while (cell &&  ((cell.frame.origin.y + cell.frame.size.height  - self.contentOffset.y) <  0.0001)) 
    {
        [cell removeFromSuperview];
        [cell prepareForReuse];
        [self recycleCellIntoReusableQueue:cell];
        [column.visibleCells removeObject:cell];
        
        if(column.visibleCells.count > 0) {
            cell = [column.visibleCells objectAtIndex:0];
        } else {
            cell = nil;
        }
    }
    
    //3. add cells below this basic cell if there's margin between basic cell and bottom
    cell = [column.visibleCells lastObject];
    while (cell &&  ((cell.frame.origin.y + cell.frame.size.height - self.frame.size.height - self.contentOffset.y) <  0.0001))  {
        float origin_y = 0;
        float height = 0;
        int unitIndex = cell.indexPath.row;
        
        if(unitIndex == column.unitContainer.count - 1) {
            cell = nil;
            break;
        } 
        
        WaterflowLayoutUnit *unit = [column.unitContainer objectAtIndex:unitIndex + 1];
        origin_y = unit.upperBound;
        height = [unit unitHeight];
        
        cell = [self.flowdatasource flowView:self cellForLayoutUnit:unit];
        cell.indexPath = [NSIndexPath indexPathForRow:unitIndex + 1 inSection:direction];
        cell.frame = CGRectMake(origin_x, origin_y, width, height);
        [column.visibleCells addObject:cell];
        
        [self addSubview:cell];
    }
    
    //4. remove cells below this basic cell if there's no margin between basic cell and bottom
    while (cell &&  ((cell.frame.origin.y - self.frame.size.height - self.contentOffset.y) > 0.0001)) 
    {
        [cell removeFromSuperview];
        [cell prepareForReuse];
        [self recycleCellIntoReusableQueue:cell];
        [column.visibleCells removeObject:cell];
        
        if(column.visibleCells.count > 0) {
            cell = [column.visibleCells lastObject];
        } else {
            cell = nil;
        }
    }
    
}

- (CGFloat)originXForColumn:(ColumnDirection)direction
{
    CGFloat result = 0.0;
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    if (direction == ColumnDirectionLeft) {
        result =  isPortrait ? LeftColumnPortraitOriginX : LeftColumnLandscapeOriginX;
    } else {
        result =  isPortrait ? RightColumnPortraitOriginX : RightColumnLandscapeOriginX;
    }
    
    return result;
}

- (WaterflowColumn*)selectColumnToInsert
{
    WaterflowLayoutUnit *leftUnit = (WaterflowLayoutUnit*)[self.leftColumn lastObject];
    WaterflowLayoutUnit *rightUnit = (WaterflowLayoutUnit*)[self.rightColumn lastObject];
    if (leftUnit == nil) {
        return self.leftColumn;
    }
    if (rightUnit == nil) {
        return self.rightColumn;
    }
    return leftUnit.lowerBound < rightUnit.lowerBound ? self.leftColumn : self.rightColumn;
}

- (WaterflowLayoutUnit*)currentUnitIndexInColumn:(WaterflowColumn*)column
{
    CGFloat _refreshOffset = self.contentOffset.y < 0 ? - self.contentOffset.y : 0;
    
    WaterflowLayoutUnit *result = nil;
    for (WaterflowLayoutUnit* unit in column.unitContainer) {
        if ([unit containOffset:self.contentOffset.y + _refreshOffset]) {
            result = unit;
            break;
        }
    }
    return result;
}

- (void)adjustBackgroundView
{
    CGFloat top = self.contentOffset.y;
    CGFloat bottom = top + self.frame.size.height;
    
    if ([self view:self.backgroundViewA containsPoint:top] || [self view:self.backgroundViewA containsPoint:bottom]) {
        [self adjustView:self.backgroundViewB with:self.backgroundViewA forTop:top bottom:bottom];
    } else if([self view:self.backgroundViewB containsPoint:top] || [self view:self.backgroundViewB containsPoint:bottom]){
        [self adjustView:self.backgroundViewA with:self.backgroundViewB forTop:top bottom:bottom];
    } else {
        [self view:self.backgroundViewA resetOriginY:top];
        [self view:self.backgroundViewB resetOriginY:bottom];
    }
}

- (void)adjustView:(UIView *)viewToAdjust with:(UIView *)viewRight forTop:(CGFloat)top bottom:(CGFloat)bottom
{
    CGFloat newOriginY;
    
    if (viewToAdjust.frame.origin.y > bottom) {
        newOriginY = viewRight.frame.origin.y - viewToAdjust.frame.size.height;
        [self view:viewToAdjust resetOriginY:newOriginY];
    } else if (viewToAdjust.frame.origin.y + viewToAdjust.frame.size.height < top) {
        newOriginY = viewRight.frame.origin.y + viewRight.frame.size.height;
        [self view:viewToAdjust resetOriginY:newOriginY];
    }
    
}

- (void)view:(UIView *)view resetOriginY:(CGFloat)originY
{
    CGRect frame = view.frame;
    frame.origin.y = originY;
    view.frame = frame;
}

- (BOOL)view:(UIView *)view containsPoint:(CGFloat)originY
{
    return view.frame.origin.y <= originY && view.frame.origin.y + view.frame.size.height > originY;
}

#pragma mark - Properties
- (WaterflowColumn*)leftColumn
{
    if (_leftColumn == nil) {
        _leftColumn = [[WaterflowColumn alloc] init];
    }
    return _leftColumn;
}

- (WaterflowColumn*)rightColumn
{
    if (_rightColumn == nil) {
        _rightColumn = [[WaterflowColumn alloc] init];
    }
    return _rightColumn;
}

- (BaseLayoutView*)backgroundViewA
{
    if (!_backgroundViewA) {
        _backgroundViewA = [[BaseLayoutView alloc] initWithFrame:self.bounds];
        [self insertSubview:_backgroundViewA atIndex:0];
    }
    return _backgroundViewA;
}

- (BaseLayoutView*)backgroundViewB
{
    if (!_backgroundViewB) {
        _backgroundViewB = [[BaseLayoutView alloc] initWithFrame:self.bounds];
        [self view:_backgroundViewB resetOriginY:self.backgroundViewA.frame.origin.y + self.backgroundViewA.frame.size.height];
        [self insertSubview:_backgroundViewB atIndex:0];
    }
    return _backgroundViewB;
}

@end