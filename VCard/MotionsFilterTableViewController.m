//
//  MotionsFilterTableViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-6-30.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsFilterTableViewController.h"

#define FILTER_IMAGE_SIZE CGSizeMake(80, 80)
#define TABLE_VIEW_CELL_HEIGHT      100
#define TABLE_VIEW_CELL_REAL_HEIGHT 80

@interface MotionsFilterTableViewController ()

@property (nonatomic, strong) MotionsFilterReader *reader;
@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, strong) UIImage *thumbnailImage;

@end

@implementation MotionsFilterTableViewController

@synthesize tableView = _tableView;
@synthesize delegate = _delegate;

@synthesize reader = _reader;
@synthesize infoArray = _infoArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [self init];
    if(self) {
        CGFloat w = image.size.width;
        CGFloat h = image.size.height;
        CGRect rect;
        if(w > h) {
            rect = CGRectMake((w - h) / 2, 0, h, h);
        } else {
            rect = CGRectMake(0, (h - w) / 2, w, w);
        }
        
        if (NULL != UIGraphicsBeginImageContextWithOptions)
            UIGraphicsBeginImageContextWithOptions(FILTER_IMAGE_SIZE, NO, 0);
        else
            UIGraphicsBeginImageContext(FILTER_IMAGE_SIZE);
        [image drawInRect:rect];
        self.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureTableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

#pragma mark - Logic methods

- (void)configureReader {
    self.reader = [[MotionsFilterReader alloc] init];
    self.infoArray = [self.reader getFilterInfoArray];
}

#pragma mark - UI methods

- (void)configureTableView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 142)];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 118)];
    headerView.backgroundColor = [UIColor clearColor];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = footerView;
    
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
}

#pragma mark - Animations 

- (void)tableViewSimulatePickerAnimation {
    CGFloat contentOffset = self.tableView.contentOffset.y;
    if(contentOffset < 0)
        contentOffset = 0;
    NSInteger index = contentOffset / TABLE_VIEW_CELL_HEIGHT;
    CGFloat cellOffset = contentOffset - index * TABLE_VIEW_CELL_HEIGHT;
    
    NSLog(@"real offset %f, content offset %f, index %d", self.tableView.contentOffset.y, contentOffset, index);
    
    if(cellOffset > TABLE_VIEW_CELL_HEIGHT / 2) {
        index += 1;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.contentOffset = CGPointMake(0, index * TABLE_VIEW_CELL_HEIGHT);
    } completion:^(BOOL finished) {
        ;
    }];
}

#pragma mark - UITableView delegate & data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = @"MotionsFilterCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:name];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
        cell = [nib lastObject];
    }
        
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_VIEW_CELL_HEIGHT;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self tableViewSimulatePickerAnimation];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self tableViewSimulatePickerAnimation];
}

@end
