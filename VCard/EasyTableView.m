//
//  EasyTableView.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableView.h"
#import "EasyTableViewCell.h"

#define OriginX UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]) ? 238 : 366

@interface EasyTableView (PrivateMethods)
- (void)createTableWithOrientation:(EasyTableViewOrientation)orientation;
- (void)prepareRotatedView:(UIView *)rotatedView;
- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EasyTableView

@synthesize delegate, cellBackgroundColor;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize orientation = _orientation;
@synthesize numberOfCells = _numItems;

@synthesize mainStoryboard;

#pragma mark -
#pragma mark Initialization


- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numCols ofWidth:(CGFloat)width {
    if (self = [super initWithFrame:frame]) {
		_numItems			= numCols;
		_cellWidthOrHeight	= width;
		
		[self createTableWithOrientation:EasyTableViewOrientationHorizontal];
	}
    return self;
}

- (void)createTableWithOrientation:(EasyTableViewOrientation)orientation {
	// Save the orientation so that the table view cell knows how to set itself up
	_orientation = orientation;
	
	UITableView *tableView;
    
    int xOrigin	= (self.bounds.size.width - self.bounds.size.height)/2;
    int yOrigin	= (self.bounds.size.height - self.bounds.size.width)/2;
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, self.bounds.size.height, self.bounds.size.width)];
	
	tableView.tag = TABLEVIEW_TAG;
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
	tableView.showsVerticalScrollIndicator = NO;
	tableView.showsHorizontalScrollIndicator = NO;
	
	[self addSubview:tableView];
}


#pragma mark -
#pragma mark Properties

- (UITableView *)tableView {
	return (UITableView *)[self viewWithTag:TABLEVIEW_TAG];
}


- (NSArray *)visibleViews {
	NSArray *visibleCells = [self.tableView visibleCells];
	NSMutableArray *visibleViews = [NSMutableArray arrayWithCapacity:[visibleCells count]];
	
	for (UIView *aView in visibleCells) {
		[visibleViews addObject:[aView viewWithTag:CELL_CONTENT_TAG]];
	}
	return visibleViews;
}


- (CGPoint)contentOffset {
	CGPoint offset = self.tableView.contentOffset;
    offset = CGPointMake(offset.y, offset.x);
	return offset;
}


- (void)setContentOffset:(CGPoint)offset {
    self.tableView.contentOffset = CGPointMake(offset.y, offset.x);
}


- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
	CGPoint newOffset = CGPointMake(offset.y, offset.x);
	[self.tableView setContentOffset:newOffset animated:animated];
}


#pragma mark -
#pragma mark Selection

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	self.selectedIndexPath = indexPath;
	CGPoint defaultOffset = CGPointMake(0, indexPath.row  *_cellWidthOrHeight);
	
	[self.tableView setContentOffset:defaultOffset animated:animated];
}

- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
	if (![_selectedIndexPath isEqual:indexPath]) {
		NSIndexPath *oldIndexPath = [_selectedIndexPath copy];
		
		_selectedIndexPath = indexPath;
		
		UITableViewCell *deselectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:oldIndexPath];
		UITableViewCell *selectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
		
		if ([delegate respondsToSelector:@selector(easyTableView:selectedView:atIndexPath:deselectedView:)]) {
			UIView *selectedView = [selectedCell viewWithTag:CELL_CONTENT_TAG];
			UIView *deselectedView = [deselectedCell viewWithTag:CELL_CONTENT_TAG];
			
			[delegate easyTableView:self
					   selectedView:selectedView
						atIndexPath:_selectedIndexPath
					 deselectedView:deselectedView];
		}
	}
}

#pragma mark -
#pragma mark Multiple Sections

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
        UIView *headerView = [delegate easyTableView:self viewForHeaderInSection:section];
        return headerView.frame.size.width;
    }
    return 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
        UIView *footerView = [delegate easyTableView:self viewForFooterInSection:section];
        return footerView.frame.size.width;
    }
    return 0.0;
}

- (UIView *)viewToHoldSectionView:(UIView *)sectionView {
	// Enforce proper section header/footer view height abd origin. This is required because
	// of the way UITableView resizes section views on orientation changes.
    
    sectionView.frame = CGRectMake(0, 0, sectionView.frame.size.width, self.frame.size.height);
	
	UIView *rotatedView = [[UIView alloc] initWithFrame:sectionView.frame];
	
    rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
    sectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	[rotatedView addSubview:sectionView];
	return rotatedView;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
		UIView *sectionView = [delegate easyTableView:self viewForHeaderInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
		UIView *sectionView = [delegate easyTableView:self viewForFooterInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([delegate respondsToSelector:@selector(numberOfSectionsInEasyTableView:)]) {
        return [delegate numberOfSectionsInEasyTableView:self];
    }
    return 1;
}

#pragma mark -
#pragma mark Location and Paths

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath {
	UIView *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	return [cell viewWithTag:CELL_CONTENT_TAG];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
	NSArray *visibleCells = [self.tableView visibleCells];
	
	__block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UITableViewCell *cell = obj;
        
		if ([cell viewWithTag:CELL_CONTENT_TAG] == view) {
            indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
		}
	}];
	return indexPath;
}

- (CGPoint)offsetForView:(UIView *)view {
	// Get the location of the cell
	CGPoint cellOrigin = [view convertPoint:view.frame.origin toView:self];
	
	// No need to compensate for orientation since all values are already adjusted for orientation
	return cellOrigin;
}

#pragma mark -
#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[self setSelectedIndexPath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([delegate respondsToSelector:@selector(easyTableView:heightOrWidthForCellAtIndexPath:)]) {
        return [delegate easyTableView:self heightOrWidthForCellAtIndexPath:indexPath];
    }
    UIApplication *application = [UIApplication sharedApplication];
    CGRect frame = [[application.delegate window] frame];
    _cellWidthOrHeight =  UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]) ? frame.size.width : frame.size.height;
    return _cellWidthOrHeight;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Don't allow the currently selected cell to be selectable
	if ([_selectedIndexPath isEqual:indexPath]) {
		return nil;
	}
	return indexPath;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([delegate respondsToSelector:@selector(easyTableView:scrolledToOffset:)])
		[delegate easyTableView:self scrolledToOffset:self.contentOffset];
}


#pragma mark -
#pragma mark TableViewDataSource

- (void)setCell:(UITableViewCell *)cell boundsForOrientation:(EasyTableViewOrientation)theOrientation 
{
    cell.bounds	= CGRectMake(0, 0, self.bounds.size.height, _cellWidthOrHeight);
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"EasyTableViewCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[EasyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier storyBoard:self.mainStoryboard];
		
		[self setCell:cell boundsForOrientation:_orientation];
		
		cell.contentView.frame = cell.bounds;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		// Add a view to the cell's content view that is rotated to compensate for the table view rotation
		CGRect viewRect = CGRectMake(OriginX, 0, cell.bounds.size.height, cell.bounds.size.width);
		
		UIView *rotatedView				= [[UIView alloc] initWithFrame:viewRect];
		rotatedView.tag					= ROTATED_CELL_VIEW_TAG;
		rotatedView.center				= cell.contentView.center;
		rotatedView.backgroundColor		= self.cellBackgroundColor;
		
        rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		
		// We want to make sure any expanded content is not visible when the cell is deselected
		rotatedView.clipsToBounds = YES;
		
		// Prepare and add the custom subviews
		[self prepareRotatedView:rotatedView forCell:(EasyTableViewCell*)cell];
		
		[cell.contentView addSubview:rotatedView];
	}
	[self setCell:cell boundsForOrientation:_orientation];
	
	[self setDataForRotatedView:[cell.contentView viewWithTag:ROTATED_CELL_VIEW_TAG] forIndexPath:indexPath];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger numOfItems = _numItems;
	
	if ([delegate respondsToSelector:@selector(numberOfCellsForEasyTableView:inSection:)]) {
		numOfItems = [delegate numberOfCellsForEasyTableView:self inSection:section];
		
		// Animate any changes in the number of items
		[tableView beginUpdates];
		[tableView endUpdates];
	}
	
    return numOfItems;
}

#pragma mark -
#pragma mark Rotation

- (void)prepareRotatedView:(UIView *)rotatedView forCell:(EasyTableViewCell*)cell{
	
    UIView* content = cell.userSelectionCellViewController.view;
	
	content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	content.tag = CELL_CONTENT_TAG;
    
    CGRect prevFrame = content.frame;
    prevFrame.origin.x = OriginX;
    content.frame = prevFrame;
    
	[rotatedView addSubview:content];
}


- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath {
	UIView *content = [rotatedView viewWithTag:CELL_CONTENT_TAG];
	
   [delegate easyTableView:self setDataForView:content forIndexPath:indexPath];
}


@end

