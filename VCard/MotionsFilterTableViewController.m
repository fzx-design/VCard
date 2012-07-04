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

@end

@implementation MotionsFilterTableViewController

@synthesize tableView = _tableView;
@synthesize bgView = _bgView;
@synthesize delegate = _delegate;

@synthesize reader = _reader;
@synthesize filterInfoArray = _infoArray;
@synthesize filteredThumbnailCacheDictionary = _filteredThumbnailCacheDictionary;

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
    [super viewDidUnload];
    self.tableView = nil;
    self.bgView = nil;
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
    CGRect frame = self.isCurrentOrientationLandscape ? CGRectMake(0, 0, 80, 142) : CGRectMake(0, 0, 80, 239);
    return frame;
}

- (CGRect)tableViewFooterViewFrame {
    CGRect frame = self.isCurrentOrientationLandscape ? CGRectMake(0, 0, 80, 122) : CGRectMake(0, 0, 80, 216);
    return frame;
}

#pragma mark - UI methods

- (void)configureTableView {
    UIView *headerView = [[UIView alloc] initWithFrame:[self tableViewHeaderViewFrame]];
    UIView *footerView = [[UIView alloc] initWithFrame:[self tableViewFooterViewFrame]];
    headerView.backgroundColor = [UIColor clearColor];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = footerView;
    
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    CGRect frame = self.tableView.frame;
    if(!self.isCurrentOrientationLandscape) {
        self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    } else {
        self.tableView.transform = CGAffineTransformIdentity;
    }
    self.tableView.frame = frame;
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
    else 
        [cell loadThumbnailImage:self.thumbnailImage withFilterInfo:info completion:^{
            UIImage *filteredImage = cell.thumbnailImageView.image;
            if(filteredImage)
                [self.filteredThumbnailCacheDictionary setObject:filteredImage forKey:info.filterName];
        }];
    
    if(!self.isCurrentOrientationLandscape) {
        cell.transform = CGAffineTransformMakeRotation(-M_PI_2);
        NSLog(@"cell frame %@", NSStringFromCGRect(cell.frame));
    } else {
        cell.transform = CGAffineTransformIdentity;
    }
}

#pragma mark - Animations

- (void)tableViewSimulatePickerAnimationWithCompletion:(void (^)(NSInteger scrollToIndex))completion {
    CGFloat contentOffset = self.tableView.contentOffset.y;
    if(contentOffset < 0)
        contentOffset = 0;
    NSInteger index = contentOffset / TABLE_VIEW_CELL_HEIGHT;
    CGFloat cellOffset = contentOffset - index * TABLE_VIEW_CELL_HEIGHT;
        
    if(cellOffset > TABLE_VIEW_CELL_HEIGHT / 2) {
        index += 1;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.contentOffset = CGPointMake(0, index * TABLE_VIEW_CELL_HEIGHT);
    } completion:^(BOOL finished) {
        if(finished)
            if(completion)
                completion(index);
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

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self tableViewSimulatePickerAnimationWithCompletion:^(NSInteger scrollToIndex){
            [self.delegate filterTableViewController:self didSelectFilter:[self.filterInfoArray objectAtIndex:scrollToIndex]];
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self tableViewSimulatePickerAnimationWithCompletion:^(NSInteger scrollToIndex){
        [self.delegate filterTableViewController:self didSelectFilter:[self.filterInfoArray objectAtIndex:scrollToIndex]];
    }];
}

@end
