//
//  WaterflowView.m
//  WaterFlowDisplay
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowView.h"
#import "ResourceList.h"

@interface WaterflowView()
- (void)initialize;
- (void)recycleCellIntoReusableQueue:(WaterflowCell*)cell;
- (void)pageScroll;
- (void)cellSelected:(NSNotification*)notification;
@end

@implementation WaterflowView
@synthesize cellHeight=_cellHeight,visibleCells=_visibleCells,reusableCells=_reusedCells;
@synthesize flowdelegate=_flowdelegate,flowdatasource=_flowdatasource;
@synthesize rightColumnUnits = _rightColumnUnits;
@synthesize leftColumnUnits = _leftColumnUnits;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
		self.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(cellSelected:)
                                                     name:@"CellSelected"
                                                   object:nil];
        
        currentPage = 1;
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
		self.delegate = self;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(cellSelected:)
                                                     name:@"CellSelected"
                                                   object:nil];
        
        currentPage = 1;
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
    [super dealloc];
}

- (void)setFlowdatasource:(id<WaterflowViewDatasource>)flowdatasource
{
    _flowdatasource = flowdatasource;
//    [self initialize];
}

- (void)setFlowdelegate:(id<WaterflowViewDelegate>)flowdelegate
{
    _flowdelegate = flowdelegate;
//    [self initialize];
}

#pragma mark-
#pragma mark- process notification
- (void)cellSelected:(NSNotification *)notification
{
    if ([self.flowdelegate respondsToSelector:@selector(flowView:didSelectRowAtIndexPath:)])
    {
        [self.flowdelegate flowView:self didSelectRowAtIndexPath:((WaterflowCell*)notification.object).indexPath];
    }
}

#pragma mark-
#pragma mark - manage and reuse cells
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (!identifier || identifier == 0 ) return nil;
    
    NSArray *cellsWithIndentifier = [NSArray arrayWithArray:[self.reusableCells objectForKey:identifier]];
    if (cellsWithIndentifier &&  cellsWithIndentifier.count > 0)
    {
        WaterflowCell *cell = [cellsWithIndentifier lastObject];
        [[cell retain] autorelease];
        [[self.reusableCells objectForKey:identifier] removeLastObject];
        return cell;
    }
    return nil;
}

- (void)recycleCellIntoReusableQueue:(WaterflowCell *)cell
{
    if(!self.reusableCells)
    {
        self.reusableCells = [NSMutableDictionary dictionary];
        
        NSMutableArray *array = [NSMutableArray arrayWithObject:cell];
        [self.reusableCells setObject:array forKey:cell.reuseIdentifier];
    }
    
    else 
    {
        if (![self.reusableCells objectForKey:cell.reuseIdentifier])
        {
            NSMutableArray *array = [NSMutableArray arrayWithObject:cell];
            [self.reusableCells setObject:array forKey:cell.reuseIdentifier];
        }
        else 
        {
            [[self.reusableCells objectForKey:cell.reuseIdentifier] addObject:cell];
        }
    }

}

#pragma mark-
#pragma mark- methods
- (void)initialize
{    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLCastViewBGUnit]];
    
    numberOfColumns = [self.flowdatasource numberOfColumnsInFlowView:self];
    
    self.reusableCells = [NSMutableDictionary dictionary];
    self.cellHeight = [NSMutableArray arrayWithCapacity:numberOfColumns];
    self.visibleCells = [NSMutableArray arrayWithCapacity:numberOfColumns];
    
    CGFloat scrollHeight = 0.f;
    
    ////put height of cells per column into an array, then add this array into self.cellHeight
    for (int i = 0; i< numberOfColumns; i++)
    {
        [self.visibleCells addObject:[NSMutableArray array]]; 
        
        NSMutableArray *cellHeightInOneColume = [NSMutableArray array];
        NSInteger rows = [_flowdatasource flowView:self numberOfRowsInColumn:i] * currentPage;
        
        CGFloat columHeight = 0.f;
        for (int j =0; j < rows; j++)
        {
            CGFloat height = [_flowdelegate flowView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            columHeight += height;
            [cellHeightInOneColume addObject:[NSNumber numberWithFloat:columHeight]];
        }
        
        [self.cellHeight addObject:cellHeightInOneColume];
        scrollHeight = (columHeight >= scrollHeight)?columHeight:scrollHeight;
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, scrollHeight);
    
    [self prepareLayoutNeedRefresh:YES];
    
    [self pageScroll];
}

- (void)prepareLayoutNeedRefresh:(BOOL)needRefresh
{
    if (needRefresh) {
        _curObjIndex = 0;
        [self.leftColumnUnits clear];
        [self.rightColumnUnits clear];
    }
    
    for (  ; _curObjIndex < [self.flowdatasource numberOfObjectsInSection]; _curObjIndex++) {
        CGFloat height = [self.flowdatasource heightForObjectAtIndex:_curObjIndex withImageHeight:ImageHeightLarge];
        WaterflowColumn *targetColumn = [self selectColumnToInsert];
        WaterflowLayoutUnit *currentUnit = [[[WaterflowLayoutUnit alloc] init] autorelease];
        WaterflowLayoutUnit *lastUnit = (WaterflowLayoutUnit*)[targetColumn lastObject];
        
        currentUnit.upperBound = lastUnit ? lastUnit.lowerBound : 0;
        currentUnit.lowerBound = currentUnit.upperBound + height;
        currentUnit.dataIndex = _curObjIndex;
        currentUnit.imageHeight = ImageHeightLarge;
        
        currentUnit.unitIndex = targetColumn.unitContainer.count;
        
        [targetColumn addObject:currentUnit];
    }
    
}

- (WaterflowColumn*)selectColumnToInsert
{
    WaterflowLayoutUnit *leftUnit = (WaterflowLayoutUnit*)[self.leftColumnUnits lastObject];
    WaterflowLayoutUnit *rightUnit = (WaterflowLayoutUnit*)[self.rightColumnUnits lastObject];
    if (leftUnit == nil) {
        return self.leftColumnUnits;
    }
    if (rightUnit == nil) {
        return self.rightColumnUnits;
    }
    return leftUnit.lowerBound < rightUnit.lowerBound ? self.leftColumnUnits : self.rightColumnUnits;
}

- (void)reloadData
{
    //remove and recycle all visible cells
    for (int i = 0; i < numberOfColumns; i++)
    {
        NSMutableArray *array = [self.visibleCells objectAtIndex:i];
        for (id cell in array)
        {
            [self recycleCellIntoReusableQueue:(WaterflowCell*)cell];
            [cell removeFromSuperview];
        }
    }
    
    [self initialize];
}

- (void)pageScroll
{
    
    [self layoutCellsInColumnDirection:ColumnDirectionLeft];
    [self layoutCellsInColumnDirection:ColumnDirectionRight];
    
//    //CGPoint offset = self.contentOffset;
//    
//    
//    for (int i = 0 ; i< numberOfColumns; i++)
//    {
//        float origin_x = i * (self.frame.size.width / numberOfColumns);
//		float width = self.frame.size.width / numberOfColumns;
//                
//        WaterflowCell *cell = nil;
//        
//        if ([self.visibleCells objectAtIndex:i] == nil || ((NSArray*)[self.visibleCells objectAtIndex:i]).count == 0) //everytime reloadData is called and no cells in visibleCellArray
//        {
//            int rowToDisplay = 0;
//			for( int j = 0; j < [[self.cellHeight objectAtIndex:i] count] - 1; j++)  //calculate which row to display in this column
//			{
//				float everyCellHeight = [[[self.cellHeight objectAtIndex:i] objectAtIndex:j] floatValue];
//				if(everyCellHeight < self.contentOffset.y)
//				{
//					rowToDisplay ++;
//				}
//			}
//			
//            #ifdef DEBUG
//			NSLog(@"row to display %d", rowToDisplay);
//            #endif	
//            
//			float origin_y = 0;
//			float height = 0;
//			if(rowToDisplay == 0)  
//			{
//				origin_y = 0;
//				height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay] floatValue];
//			}
//			else if(rowToDisplay < [[self.cellHeight objectAtIndex:i] count]) 
//            {
//				origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay - 1] floatValue];
//				height  = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay ] floatValue] - origin_y;
//			}
//			
//			cell = [_flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowToDisplay inSection:i]];
//			cell.indexPath = [NSIndexPath indexPathForRow: rowToDisplay inSection:i];
//			cell.frame = CGRectMake(origin_x, origin_y, width, height);
//			[self addSubview:cell];
//			[[self.visibleCells objectAtIndex:i] insertObject:cell atIndex:0];
//       }
//        else   //there are cells in visibelCellArray
//        {
//            cell = [[self.visibleCells objectAtIndex:i] objectAtIndex:0];
//        }
//        
//        //base on this cell at rowToDisplay and process the other cells
//        //1. add cell above this basic cell if there's margin between basic cell and top
//        while ( cell && ((cell.frame.origin.y - self.contentOffset.y) > 0.0001)) 
//        {
//            float origin_y = 0;
//			float height = 0;
//            int rowToDisplay = cell.indexPath.row;
//            
//            if(rowToDisplay == 0) 
//            {
//                cell = nil;
//                break;
//            }
//            else if (rowToDisplay == 1)
//            {
//                origin_y = 0;
//                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay  -1] floatValue];
//            }
//            else if (cell.indexPath.row < [[self.cellHeight objectAtIndex:i] count])
//            {
//                origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay -2] floatValue];
//                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay - 1] floatValue] - origin_y;
//            }
//            
//            cell = [self.flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow: rowToDisplay > 0 ? (rowToDisplay  - 1) : 0 inSection:i]];
//            cell.indexPath = [NSIndexPath indexPathForRow: rowToDisplay > 0 ? (rowToDisplay - 1) : 0 inSection:i];
//            cell.frame = CGRectMake(origin_x,origin_y , width, height);
//            [[self.visibleCells objectAtIndex:i] insertObject:cell atIndex:0];
//            
//            [self addSubview:cell];
//        }
//        //2. remove cell above this basic cell if there's no margin between basic cell and top
//        while (cell &&  ((cell.frame.origin.y + cell.frame.size.height  - self.contentOffset.y) <  0.0001)) 
//		{
//			[cell removeFromSuperview];
//			[self recycleCellIntoReusableQueue:cell];
//			[[self.visibleCells objectAtIndex:i] removeObject:cell];
//			
//			if(((NSMutableArray*)[self.visibleCells objectAtIndex:i]).count > 0)
//			{
//				cell = [[self.visibleCells objectAtIndex:i] objectAtIndex:0];
//			}
//			else 
//            {
//				cell = nil;
//			}
//		}
//        //3. add cells below this basic cell if there's margin between basic cell and bottom
//        cell = [[self.visibleCells objectAtIndex:i] lastObject];
//        while (cell &&  ((cell.frame.origin.y + cell.frame.size.height - self.frame.size.height - self.contentOffset.y) <  0.0001)) 
//		{
//            //NSLog(@"self.offset %@, self.frame %@, cell.frame %@, cell.indexpath %@",NSStringFromCGPoint(self.contentOffset),NSStringFromCGRect(self.frame),NSStringFromCGRect(cell.frame),cell.indexPath);
//            float origin_y = 0;
//			float height = 0;
//            int rowToDisplay = cell.indexPath.row;
//            
//            if(rowToDisplay == [[self.cellHeight objectAtIndex:i] count] - 1)
//			{
//				origin_y = 0;
//				cell = nil;
//				break;;
//			}
//            else 
//            {
//                origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay] floatValue];
//                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay + 1] floatValue] -  origin_y;
//            }
//            
//            cell = [self.flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowToDisplay + 1 inSection:i]];
//            cell.indexPath = [NSIndexPath indexPathForRow:rowToDisplay + 1 inSection:i];
//            cell.frame = CGRectMake(origin_x, origin_y, width, height);
//            [[self.visibleCells objectAtIndex:i] addObject:cell];
//            
//            [self addSubview:cell];
//        }
//        //4. remove cells below this basic cell if there's no margin between basic cell and bottom
//        while (cell &&  ((cell.frame.origin.y - self.frame.size.height - self.contentOffset.y) > 0.0001)) 
//		{
//			[cell removeFromSuperview];
//			[self recycleCellIntoReusableQueue:cell];
//			[[self.visibleCells objectAtIndex:i] removeObject:cell];
//			
//			if(((NSMutableArray*)[self.visibleCells objectAtIndex:i]).count > 0)
//			{
//				cell = [[self.visibleCells objectAtIndex:i] lastObject];
//			}
//			else 
//            {
//				cell = nil;
//			}
//		}
//    }
}

- (void)layoutCellsInColumnDirection:(ColumnDirection)direction
{
    CGFloat origin_x = direction == ColumnDirectionLeft ? 200.0 : 600.0;
    CGFloat width = 345.0;
    
    WaterflowColumn *column = direction == ColumnDirectionLeft ? self.leftColumnUnits : self.rightColumnUnits;

    WaterflowLayoutUnit *currentUnit = [self currentUnitIndexInColumn:column];

    WaterflowCell *cell = nil;
    
    if (column.visibleCells.count == 0 || column.visibleCells.lastObject == nil)  {
        
        CGFloat origin_y = currentUnit.upperBound;
        CGFloat height = [currentUnit unitHeight];
        
        
        cell = [_flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentUnit.dataIndex inSection:direction]];
        cell.indexPath = [NSIndexPath indexPathForRow: currentUnit.unitIndex inSection:direction];
        cell.frame = CGRectMake(origin_x, origin_y, width, height);
        [self addSubview:cell];
        [column.visibleCells insertObject:cell atIndex:0];
    }
    else
    {
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
        
        WaterflowLayoutUnit *unit = [column.unitContainer objectAtIndex:unitIndex];
        origin_y = unit.upperBound;
        height = [unit unitHeight];
        
        cell = [self.flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:unit.dataIndex inSection:direction]];
        cell.indexPath = [NSIndexPath indexPathForRow:unit.unitIndex inSection:direction];
        cell.frame = CGRectMake(origin_x, origin_y , width, height);
        [column.visibleCells insertObject:cell atIndex:0];
        
        [self addSubview:cell];
    }
    //2. remove cell above this basic cell if there's no margin between basic cell and top
    while (cell &&  ((cell.frame.origin.y + cell.frame.size.height  - self.contentOffset.y) <  0.0001)) 
    {
        [cell removeFromSuperview];
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
        
        WaterflowLayoutUnit *unit = [column.unitContainer objectAtIndex:unitIndex];
        origin_y = unit.upperBound;
        height = [unit unitHeight];
        
        cell = [self.flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:unit.dataIndex inSection:direction]];
        cell.indexPath = [NSIndexPath indexPathForRow:unitIndex + 1 inSection:direction];
        cell.frame = CGRectMake(origin_x, origin_y, width, height);
        [column.visibleCells addObject:cell];
        
        [self addSubview:cell];
    }
    //4. remove cells below this basic cell if there's no margin between basic cell and bottom
    while (cell &&  ((cell.frame.origin.y - self.frame.size.height - self.contentOffset.y) > 0.0001)) 
    {
        [cell removeFromSuperview];
        [self recycleCellIntoReusableQueue:cell];
        [column.visibleCells removeObject:cell];
        
        if(column.visibleCells.count > 0) {
            cell = [column.visibleCells lastObject];
        } else {
            cell = nil;
        }
    }
}

- (WaterflowLayoutUnit*)currentUnitIndexInColumn:(WaterflowColumn*)column
{
    WaterflowLayoutUnit *result = nil;
    for (WaterflowLayoutUnit* unit in column.unitContainer) {
        if ([unit containOffset:self.contentOffset.y]) {
            result = unit;
            break;
        }
    }
    return result;
}

#pragma mark-
#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self pageScroll];
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) 
    {
        //load more
        currentPage ++;
        [self reloadData];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
//    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//    if (bottomEdge >= scrollView.contentSize.height) 
//    {
//       //load more
//        currentPage ++;
//        [self reloadData];
//    }
}

#pragma mark - Properties
- (WaterflowColumn*)leftColumnUnits
{
    if (_leftColumnUnits == nil) {
        _leftColumnUnits = [[WaterflowColumn alloc] init];
    }
    return _leftColumnUnits;
}

- (WaterflowColumn*)rightColumnUnits
{
    if (_rightColumnUnits == nil) {
        _rightColumnUnits = [[WaterflowColumn alloc] init];
    }
    return _rightColumnUnits;
}


@end