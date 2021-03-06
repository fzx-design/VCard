//
//  MotionsFilterTableViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-6-30.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsFilterTableViewController.h"
#import "MotionsFilterCell.h"
#import "UIImage+Addition.h"

#define TABLE_VIEW_CELL_HEIGHT      100
#define TABLE_VIEW_CELL_REAL_HEIGHT 80
#define FILTER_IMAGE_SIZE CGSizeMake(TABLE_VIEW_CELL_REAL_HEIGHT, TABLE_VIEW_CELL_REAL_HEIGHT)

@interface MotionsFilterTableViewController ()

@property (nonatomic, strong) MotionsFilterReader *reader;
@property (nonatomic, strong) NSArray *filterInfoArray;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) NSMutableDictionary *filteredThumbnailCacheDictionary;
@property (nonatomic, assign) NSInteger currentFilterIndex;

@end

@implementation MotionsFilterTableViewController

@synthesize tableView = _tableView;
@synthesize bgView = _bgView;
@synthesize delegate = _delegate;

@synthesize reader = _reader;
@synthesize filterInfoArray = _infoArray;
@synthesize filteredThumbnailCacheDictionary = _filteredThumbnailCacheDictionary;
@synthesize currentFilterIndex = _currentFilterIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.filteredThumbnailCacheDictionary = [NSMutableDictionary dictionary];
        [self configureReader];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [self init];
    if(self) {
        self.thumbnailImage = [image imageCroppedToFitSize:FILTER_IMAGE_SIZE];
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
    self.tableView = nil;
    self.bgView = nil;
    [super viewDidUnload];
}

- (void)loadViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [super loadViewControllerWithInterfaceOrientation:interfaceOrientation];
}

#pragma mark - Logic methods

- (void)configureReader {
    self.reader = [[MotionsFilterReader alloc] init];
    self.filterInfoArray = [self.reader getFilterInfoArray];
}

- (void)refreshWithImage:(UIImage *)image {
    self.thumbnailImage = [image imageCroppedToFitSize:FILTER_IMAGE_SIZE];
    [self.filteredThumbnailCacheDictionary removeAllObjects];
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:NO];
}

- (CGRect)tableViewHeaderViewFrame {
    CGRect frame = self.isCurrentOrientationLandscape ? CGRectMake(0, 0, 80, 142) : CGRectMake(0, 0, 238, 80);
    return frame;
}

- (CGRect)tableViewFooterViewFrame {
    CGRect frame = self.isCurrentOrientationLandscape ? CGRectMake(0, 0, 80, 122) : CGRectMake(0, 0, 215, 80);
    return frame;
}

- (NSUInteger)calculateCurrentCellIndex {
    CGFloat contentOffset = self.tableView.contentOffset.y;
    if(contentOffset < 0)
        contentOffset = 0;
    NSInteger index = contentOffset / TABLE_VIEW_CELL_HEIGHT;
    CGFloat cellOffset = contentOffset - index * TABLE_VIEW_CELL_HEIGHT;
    
    if(cellOffset > TABLE_VIEW_CELL_HEIGHT / 2) {
        index += 1;
    }
    
    return index;
}

#pragma mark - UI methods

- (void)configureTableView {
    UIView *headerView = [[UIView alloc] initWithFrame:[self tableViewHeaderViewFrame]];
    UIView *footerView = [[UIView alloc] initWithFrame:[self tableViewFooterViewFrame]];
    headerView.backgroundColor = [UIColor clearColor];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    if(!self.isCurrentOrientationLandscape) {
        CGRect frame = self.tableView.frame;
        self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        headerView.transform = CGAffineTransformMakeRotation(M_PI_2);
        footerView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.tableView.frame = frame;
    }
    
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = footerView;
    
    self.tableView.contentOffset = CGPointMake(0, self.currentFilterIndex * TABLE_VIEW_CELL_HEIGHT);
}

- (void)configureCell:(MotionsFilterCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    MotionsFilterInfo *info = [self.filterInfoArray objectAtIndex:indexPath.row];
    if(!info.requirePurchase)
        cell.iapIndicator.hidden = YES;
    else
        cell.iapIndicator.hidden = NO;
    UIImage *cacheImage = [self.filteredThumbnailCacheDictionary objectForKey:info.filterName];
    if(cacheImage)
        [cell setThumbnailImage:cacheImage];
    else {
        BlockARCWeakSelf weakSelf = self;
        [cell loadThumbnailImage:self.thumbnailImage withFilterInfo:info completion:^{
            UIImage *filteredImage = cell.thumbnailImageView.image;
            if(filteredImage)
                [weakSelf.filteredThumbnailCacheDictionary setObject:filteredImage forKey:info.filterName];
        }];
    }
    
    if(!self.isCurrentOrientationLandscape) {
        cell.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    cell.filterNameLabel.text = info.filterName;
}

#pragma mark - Animations

- (void)tableViewSimulatePickerAnimationWithCompletion:(void (^)(NSInteger scrollToIndex))completion {

    self.currentFilterIndex = [self calculateCurrentCellIndex];
    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.contentOffset = CGPointMake(0, self.currentFilterIndex * TABLE_VIEW_CELL_HEIGHT);
    } completion:^(BOOL finished) {
        if(finished)
            if(completion)
                completion(self.currentFilterIndex);
    }];
}

#pragma mark - UITableView delegate & data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = self.isCurrentOrientationLandscape ? @"MotionsFilterCell-landscape" : @"MotionsFilterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:name];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
        cell = [nib lastObject];
    }
    [self configureCell:(MotionsFilterCell *)cell atIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterInfoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_VIEW_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static NSUInteger immediateCellIndex = 0;
    
    NSUInteger calculatedCellIndex = [self calculateCurrentCellIndex];
    
    if(immediateCellIndex != calculatedCellIndex) {
        immediateCellIndex = calculatedCellIndex;
        //[[UIDevice currentDevice] playInputClick];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        BlockARCWeakSelf weakSelf = self;
        [self tableViewSimulatePickerAnimationWithCompletion:^(NSInteger scrollToIndex){
            [weakSelf.delegate filterTableViewController:weakSelf didSelectFilter:[weakSelf.filterInfoArray objectAtIndex:scrollToIndex]];
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BlockARCWeakSelf weakSelf = self;
    [self tableViewSimulatePickerAnimationWithCompletion:^(NSInteger scrollToIndex){
        [weakSelf.delegate filterTableViewController:weakSelf didSelectFilter:[weakSelf.filterInfoArray objectAtIndex:scrollToIndex]];
    }];
}

@end
