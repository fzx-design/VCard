//
//  MotionsFilterTableViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-6-30.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsFilterTableViewController.h"

#define FILTER_IMAGE_SIZE CGSizeMake(80, 80)

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
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 142)];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 118)];
    headerView.backgroundColor = [UIColor clearColor];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = footerView;
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
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

@end
