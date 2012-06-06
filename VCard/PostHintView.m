//
//  PostHintView.m
//  VCard
//
//  Created by 紫川 王 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostHintView.h"
#import <QuartzCore/QuartzCore.h>

#define TABLE_VIEW_MAX_COLUMN_COUNT  5
#define TABLE_VIEW_CELL_SIZE CGSizeMake(238, 44)
#define TABLE_VIEW_BOTTOM_PADDING 1

@implementation PostHintView

@synthesize tableView = _tableView;
@synthesize tableViewDataSourceArray = _tableViewDataSourceArray;
@synthesize delegate = _delegate;
@synthesize maxViewHeight = _maxViewHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - TABLE_VIEW_BOTTOM_PADDING)];
        [self configureBorder];
        [self configureTableView];
        self.maxViewHeight = TABLE_VIEW_MAX_COLUMN_COUNT * 44;
    }
    return self;
}

- (id)initWithCursorPos:(CGPoint)cursorPos {
    //NSLog(@"init cursorPos:%f, %f", cursorPos.x, cursorPos.y);
    self = [self initWithFrame:CGRectMake(cursorPos.x, cursorPos.y, TABLE_VIEW_CELL_SIZE.width, TABLE_VIEW_CELL_SIZE.height + TABLE_VIEW_BOTTOM_PADDING)];
    if(self) {
        
    }
    return self;
}

#pragma mark - Logic methods

- (NSString *)firstHintResult {
    NSString *result = nil;
    if(self.tableViewDataSourceArray.count > 0)
        result = [self.tableViewDataSourceArray objectAtIndex:0];
    return result;
}

- (void)updateHint:(NSString *)hint {
}

- (NSMutableArray *)tableViewDataSourceArray {
    if(_tableViewDataSourceArray == nil)
        _tableViewDataSourceArray = [NSMutableArray array];
    return _tableViewDataSourceArray;
}

- (void)refreshData {
    if(self.tableViewDataSourceArray.count > 0)
        self.tableView.userInteractionEnabled = YES;
    else 
        self.tableView.userInteractionEnabled = NO;
    
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3f animations:^{
        [self refreshFrame];
    }];
}

- (void)setMaxViewHeight:(CGFloat)maxViewHeight {
    CGFloat maxTableViewHeight = TABLE_VIEW_MAX_COLUMN_COUNT * 44;
    _maxViewHeight = maxViewHeight < maxTableViewHeight ? maxViewHeight : maxTableViewHeight;
    _maxViewHeight = _maxViewHeight > 44 ? _maxViewHeight : 44;
    //_maxViewHeight = (int)_maxViewHeight / 44 * 44;
    [self refreshFrame];
}

#pragma mark - UI methods

- (void)refreshFrame {
    CGRect frame = self.frame;
    NSInteger columnCount = self.tableViewDataSourceArray.count;
    columnCount = columnCount > 0 ? columnCount : 1;
    frame.size.height = columnCount * 44;
    frame.size.height = frame.size.height > self.maxViewHeight ? self.maxViewHeight : frame.size.height;
    self.frame = frame;
}

- (void)configureTableView { 
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | !UIViewAutoresizingFlexibleLeftMargin | !UIViewAutoresizingFlexibleTopMargin;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.clipsToBounds = YES;
    //self.tableView.backgroundColor = [UIColor redColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = NO;
    
    CGRect frame = CGRectZero;
    frame.size = self.frame.size;
    UIView *tableViewHolderView = [[UIView alloc] initWithFrame:frame];
    tableViewHolderView.autoresizingMask = self.tableView.autoresizingMask;
    tableViewHolderView.clipsToBounds = YES;
    tableViewHolderView.backgroundColor = [UIColor clearColor];
    tableViewHolderView.layer.cornerRadius = 10.0f;
    //tableViewHolderView.backgroundColor = [UIColor blueColor];
    
    //NSLog(@"table view holder view frame:%@", NSStringFromCGRect(tableViewHolderView.frame));
    //NSLog(@"table view frame:%@", NSStringFromCGRect(self.tableView.frame));
    
    [tableViewHolderView addSubview:self.tableView];
    [self addSubview:tableViewHolderView];
}

- (void)configureBorder {
    self.layer.cornerRadius = 10.0f;
    self.layer.shadowOffset = CGSizeMake(0, 10);
    self.layer.shadowRadius = 10.0f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5f;
}

#pragma mark - UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.tableViewDataSourceArray.count;
    count = count > 0 ? count : 1;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = [self customCellClassName];
    NSString *cellIdentifier = name ? name : @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if (name) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_VIEW_CELL_SIZE.height;
}

#pragma mark to_override

- (NSString *)customCellClassName {
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *result = [self.tableViewDataSourceArray objectAtIndex:indexPath.row];
    [self.delegate postHintView:self didSelectHintString:result];
}

@end
