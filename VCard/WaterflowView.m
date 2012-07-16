//
//  WaterflowView.m
//  WaterFlowDisplay
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowView.h"
#import "UIApplication+Addition.h"
#import "UIView+Resize.h"
#import <QuartzCore/QuartzCore.h>

#define LeftColumnLandscapeOriginX 120
#define LeftColumnPortraitOriginX 14
#define RightColumnLandscapeOriginX 540
#define RightColumnPortraitOriginX 389

#define SingleBlockHeightLimit 3000
#define BlockDividerHeight 30

#define kInfoBarImageViewFrame          CGRectMake(0, -40, 768, 33)
#define kInfoBarReturnButtonFrame       CGRectMake(0, -40, 90, 30)
#define kInfoBarTitleLabelFrame         CGRectMake(0, -40, 768, 30)
#define kInfoBarReturnButtonTextColor   [UIColor colorWithHue:70.0 / 255.0 saturation:70.0 / 255.0 brightness:70.0 / 255.0 alpha:1.0]
#define kInfoBarTitleLabelTextColor     [UIColor colorWithHue:45.0 / 255.0 saturation:45.0 / 255.0 brightness:45.0 / 255.0 alpha:1.0]

@interface WaterflowView () {
    NSInteger _nextBlockLimit;
    UIPanGestureRecognizer *_shelfPanGestureRecognizer;
}

@end

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
        [self setUpVariables];
        [self setUpNotification];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpVariables];
        [self setUpNotification];
        [self setUpInfoBar];
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:@"CellSelected"
                    object:nil];
    [center removeObserver:self
                      name:kNotificationNameShouldDisableWaterflowScroll
                    object:nil];
    [center removeObserver:self
                      name:kNotificationNameShouldEnableWaterflowScroll
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

- (void)setUpVariables
{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = YES;
    self.delegate = self;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    
    _shelfPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleShelfPanGesture:)];
    _shelfPanGestureRecognizer.minimumNumberOfTouches = 2;
    _shelfPanGestureRecognizer.maximumNumberOfTouches = 2;
    _shelfPanGestureRecognizer.delaysTouchesBegan = YES;

    [self addGestureRecognizer:_shelfPanGestureRecognizer];
}

- (void)setUpNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(cellSelected:)
                   name:@"CellSelected"
                 object:nil];
    [center addObserver:self 
               selector:@selector(disableScroll:)
                   name:kNotificationNameShouldDisableWaterflowScroll
                 object:nil];
    [center addObserver:self 
               selector:@selector(enableScroll:)
                   name:kNotificationNameShouldEnableWaterflowScroll
                 object:nil];
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
    for (WaterflowCell *cell in visibleCells) {
        CGFloat actualOriginX = [cell.reuseIdentifier isEqualToString:kReuseIdentifierDividerCell] ? 0.0 : originX;

        CGRect frame = cell.frame;
        frame.origin.x = actualOriginX;
        cell.frame = frame;
    }
}

- (void)resetContentSize:(UIInterfaceOrientation)orientation
{
    CGFloat width = UIInterfaceOrientationIsPortrait(orientation) ? 768 : 1024;
    CGFloat height = [self heightOfWaterflowView];
    
    if (height < self.frame.size.height) {
        height = self.frame.size.height + 1;
    }
    
    self.contentSize = CGSizeMake(width, height);
}

- (UIInterfaceOrientation)currentOrientation
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - Handle Gesture
- (void)handleShelfPanGesture:(UIPanGestureRecognizer *)sender
{
    NSLog(@"%f", [sender velocityInView:self].y);
    if (sender.state == UIGestureRecognizerStateBegan && [sender velocityInView:self].y > 200.0) {
        [_flowdelegate didSwipeWaterflowView];
        sender.enabled = NO;
    } else {
        if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) {
            if (sender.enabled) {
                [_flowdelegate didEndDraggingWaterflowView:[sender translationInView:self].y];
            }
            sender.enabled = YES;
        } else {
            [_flowdelegate didDragWaterflowViewWithOffset:[sender translationInView:self].y];
        }
    }    
}

- (void)handleShelfSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    
}

#pragma mark - Process Notification
- (void)cellSelected:(NSNotification *)notification
{
    if ([self.flowdelegate respondsToSelector:@selector(flowView:didSelectRowAtIndexPath:)]) {
        [self.flowdelegate flowView:self didSelectRowAtIndexPath:((WaterflowCell*)notification.object).indexPath];
    }
}

- (void)disableScroll:(NSNotification *)notification
{
    self.scrollEnabled = NO;
}

- (void)enableScroll:(NSNotification *)notification
{
    self.scrollEnabled = YES;
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
    [self relayout];
    [UIView animateWithDuration:0.3 animations:^{
        self.contentOffset = CGPointZero;
    }];
}

- (void)relayout
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
        _nextBlockLimit = 0;
        
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
        
        [self setBlockDivider:_curObjIndex];
        
        CGFloat imageHeight = [self randomImageHeight];
        
        WaterflowColumn *targetColumn = [self selectColumnToInsert];
        WaterflowLayoutUnit *currentUnit = [[[WaterflowLayoutUnit alloc] init] autorelease];
        WaterflowLayoutUnit *lastUnit = (WaterflowLayoutUnit*)[targetColumn lastObject];
        
        CGFloat height = [self.flowdatasource heightForObjectAtIndex:_curObjIndex withImageHeight:imageHeight];
        
        currentUnit.isBlockDivider = NO;
        currentUnit.unitType = UnitTypeCard;
        currentUnit.upperBound = lastUnit ? lastUnit.lowerBound : 0;
        currentUnit.lowerBound = currentUnit.upperBound + height;
        currentUnit.dataIndex = _curObjIndex;
        currentUnit.imageHeight = imageHeight;
        currentUnit.unitIndex = targetColumn.unitContainer.count;
        
        [targetColumn addObject:currentUnit];
    }
    
}

- (void)setBlockDivider:(NSInteger)dataIndex
{
    int currentViewHeight = [self heightOfWaterflowView];
    if (currentViewHeight >= _nextBlockLimit && [self differenceBetweenColumns] < 300) {
        _nextBlockLimit = currentViewHeight + SingleBlockHeightLimit;
        
        int dividerOffset = currentViewHeight == 0 ? 14 : -20;
        
        WaterflowLayoutUnit *dividerUnitLeft = [[[WaterflowLayoutUnit alloc] init] autorelease];
        WaterflowLayoutUnit *dividerUnitRight = [[[WaterflowLayoutUnit alloc] init] autorelease];
        
        dividerUnitLeft.isBlockDivider = YES;
        dividerUnitLeft.unitType = UnitTypeDivider;
        dividerUnitLeft.upperBound = currentViewHeight + dividerOffset;
        dividerUnitLeft.lowerBound = dividerUnitLeft.upperBound + BlockDividerHeight;
        dividerUnitLeft.unitIndex = self.leftColumn.unitContainer.count;
        dividerUnitLeft.dataIndex = dataIndex;
        [self.leftColumn addObject:dividerUnitLeft];
        
        dividerUnitRight.isBlockDivider = YES;
        dividerUnitRight.unitType = UnitTypeNone;
        dividerUnitRight.upperBound = currentViewHeight + dividerOffset;
        dividerUnitRight.lowerBound = dividerUnitRight.upperBound + BlockDividerHeight;
        dividerUnitRight.unitIndex = self.rightColumn.unitContainer.count;
        [self.rightColumn addObject:dividerUnitRight];
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

- (int)differenceBetweenColumns
{
    WaterflowLayoutUnit *leftUnit = (WaterflowLayoutUnit*)[self.leftColumn lastObject];
    WaterflowLayoutUnit *rightUnit = (WaterflowLayoutUnit*)[self.rightColumn lastObject];
    int leftHeight = 0.0;
    int rightHeight = 0.0;
    if (leftUnit) {
        leftHeight = leftUnit.lowerBound;
    }
    if (rightUnit) {
        rightHeight = rightUnit.lowerBound;
    }
    return abs(leftHeight - rightHeight);
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
    [self adjustInfoBar];
    
    [self pageScroll];
    
    [self loadImageInCells];
    
    [self checkLoadMore];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSNumber *shouldSystemSupportScrollsTopTop = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultKeyShouldScrollToTop];
    return self.scrollsToTop && shouldSystemSupportScrollsTopTop.boolValue;
}

- (void)checkLoadMore
{
    if (self.contentOffset.y > self.contentSize.height - 1000.0) {
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
        
        int actualOriginX = currentUnit.isBlockDivider ? 0 : origin_x;
        int actualWidth = currentUnit.isBlockDivider ? [self widthOfSceen] : width;
        
        cell = [_flowdatasource flowView:self cellForLayoutUnit:currentUnit];
        cell.indexPath = [NSIndexPath indexPathForRow: currentUnit.unitIndex inSection:direction];
        cell.frame = CGRectMake(actualOriginX, origin_y, actualWidth, height);
        [self insertSubview:cell belowSubview:_infoBarView];
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
        
        int actualOriginX = unit.isBlockDivider ? 0.0 : origin_x;
        int actualWidth = unit.isBlockDivider ? [self widthOfSceen] : width;
        
        cell = [self.flowdatasource flowView:self cellForLayoutUnit:unit];
        cell.indexPath = [NSIndexPath indexPathForRow:unit.unitIndex inSection:direction];
        cell.frame = CGRectMake(actualOriginX, origin_y , actualWidth, height);
        [column.visibleCells insertObject:cell atIndex:0];
        
        [self insertSubview:cell belowSubview:_infoBarView];
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
        
        int actualOriginX = unit.isBlockDivider ? 0.0: origin_x;
        int actualWidth = unit.isBlockDivider ? [self widthOfSceen] : width;
        
        cell = [self.flowdatasource flowView:self cellForLayoutUnit:unit];
        cell.indexPath = [NSIndexPath indexPathForRow:unitIndex + 1 inSection:direction];
        cell.frame = CGRectMake(actualOriginX, origin_y, actualWidth, height);
        [column.visibleCells addObject:cell];
        
        [self insertSubview:cell belowSubview:_infoBarView];
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

- (CGFloat)widthOfSceen
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    return isPortrait ? 768.0 : 1024.0;
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
    
    if (column.unitContainer.count == 0) {
        return nil;
    }
    
    WaterflowLayoutUnit *result = [column.unitContainer objectAtIndex:0];
    for (WaterflowLayoutUnit* unit in column.unitContainer) {
        if ([unit containOffset:self.contentOffset.y + _refreshOffset]) {
            result = unit;
            break;
        } else if(unit.upperBound > self.contentOffset.y + _refreshOffset) {
            result = unit;
            break;
        }
    }
    return result;
}

#pragma mark - Adjust Info Bar
- (void)setUpInfoBar
{
    _infoBarView = [[UIImageView alloc] initWithFrame:kInfoBarImageViewFrame];
    _infoBarView.image = [[UIImage imageNamed:@"banner_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsZero];
    _infoBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _returnButton = [[UIButton alloc] initWithFrame:kInfoBarReturnButtonFrame];
    [_returnButton setTitle:@"查看全部" forState:UIControlStateNormal];
    [_returnButton setTitle:@"查看全部" forState:UIControlStateHighlighted];
    [_returnButton setTitleColor:kInfoBarReturnButtonTextColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:kInfoBarReturnButtonTextColor forState:UIControlStateHighlighted];
    [_returnButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_returnButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_returnButton setBackgroundImage:[UIImage imageNamed:@"button_flat.png"] forState:UIControlStateNormal];
    [_returnButton setBackgroundImage:[UIImage imageNamed:@"button_flat_hover.png"] forState:UIControlStateHighlighted];
    _returnButton.autoresizingMask = UIViewAutoresizingNone;
    _returnButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _returnButton.titleLabel.shadowColor = [UIColor whiteColor];
    _returnButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [_returnButton addTarget:self
                      action:@selector(didClickReturnButton)
            forControlEvents:UIControlEventTouchUpInside];
    
    _titleLabel = [[UILabel alloc] initWithFrame:kInfoBarTitleLabelFrame];
    _titleLabel.text = @"";
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _titleLabel.textColor = kInfoBarTitleLabelTextColor;
    _titleLabel.shadowColor = [UIColor whiteColor];
    _titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    _infoBarView.hidden = YES;
    _returnButton.hidden = YES;
    _titleLabel.hidden = YES;
    
    [self insertSubview:_infoBarView atIndex:kWaterflowViewInfoBarViewIndex];
    [self insertSubview:_titleLabel atIndex:kWaterflowViewInfoBarViewIndex];
    [self insertSubview:_returnButton atIndex:kWaterflowViewInfoBarViewIndex];
}

- (void)showInfoBarWithTitleName:(NSString *)name
{
    _infoBarView.hidden = NO;
    _returnButton.hidden = NO;
    _titleLabel.hidden = NO;
    
    [UIView animateWithDuration:0.15 animations:^{
        _titleLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        _titleLabel.text = name;
        [UIView animateWithDuration:0.15 animations:^{
            _titleLabel.alpha = 1.0;
        }];
    }];
        
    if (_infoBarView.frame.origin.y == -40) {
        CGFloat targetOriginY = self.contentOffset.y > 0 ? self.contentOffset.y : 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            [_infoBarView resetOriginY:targetOriginY];
            [_returnButton resetOriginY:targetOriginY];
            [_titleLabel resetOriginY:targetOriginY];
        }];
    }
}

- (void)adjustInfoBar
{
    if (self.contentOffset.y > 0.0) {
        [_infoBarView resetOriginY:self.contentOffset.y];
        [_titleLabel resetOriginY:self.contentOffset.y];
        [_returnButton resetOriginY:self.contentOffset.y];

    } else {
        [_infoBarView resetOriginY:0.0];
        [_titleLabel resetOriginY:0.0];
        [_returnButton resetOriginY:0.0];
    }
}

- (void)didClickReturnButton
{
    CGFloat targetOriginY = _infoBarView.frame.origin.y - 40.0;
    [UIView animateWithDuration:0.3 animations:^{
        [_infoBarView resetOriginY:targetOriginY];
        [_returnButton resetOriginY:targetOriginY];
        [_titleLabel resetOriginY:targetOriginY];
    } completion:^(BOOL finished) {
        _infoBarView.hidden = YES;
        _returnButton.hidden = YES;
        _titleLabel.hidden = YES;
        
        [_infoBarView resetOriginY:-40.0];
        [_returnButton resetOriginY:-40.0];
        [_titleLabel resetOriginY:-40.0];
        [_flowdelegate didClickReturnToNormalTimelineButton];
    }];
}

#pragma mark - Adjust Background View

- (void)adjustBackgroundView
{
    CGFloat top = self.contentOffset.y;
    CGFloat bottom = top + self.frame.size.height;
    
    UIView *upperView = nil;
    UIView *lowerView = nil;
    BOOL alignToTop = NO;
    
    if ((alignToTop = [self view:self.backgroundViewA containsPoint:top]) || [self view:self.backgroundViewB containsPoint:bottom]) {
        upperView = self.backgroundViewA;
        lowerView = self.backgroundViewB;
    } else if((alignToTop = [self view:self.backgroundViewB containsPoint:top]) || [self view:self.backgroundViewA containsPoint:bottom]) {
        upperView = self.backgroundViewB;
        lowerView = self.backgroundViewA;
    }
    
    if (upperView && lowerView) {
        if (alignToTop) {
            [self view:lowerView resetOriginY:upperView.frame.origin.y + upperView.frame.size.height];
        } else {
            [self view:upperView resetOriginY:lowerView.frame.origin.y - lowerView.frame.size.height];
        }
    } else {
        [self view:self.backgroundViewA resetOriginY:top];
        [self view:self.backgroundViewB resetOriginY:self.backgroundViewA.frame.origin.y + self.backgroundViewA.frame.size.height];
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
        _backgroundViewA = [[BaseLayoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 1024.0)];
        _backgroundViewA.autoresizingMask = UIViewAutoresizingNone;
        [self insertSubview:_backgroundViewA atIndex:0];
    }
    return _backgroundViewA;
}

- (BaseLayoutView*)backgroundViewB
{
    if (!_backgroundViewB) {
        _backgroundViewB = [[BaseLayoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 1024.0)];
        _backgroundViewB.autoresizingMask = UIViewAutoresizingNone;
        [self view:_backgroundViewB resetOriginY:self.backgroundViewA.frame.origin.y + self.backgroundViewA.frame.size.height];
        [self insertSubview:_backgroundViewB atIndex:0];
    }
    return _backgroundViewB;
}

@end