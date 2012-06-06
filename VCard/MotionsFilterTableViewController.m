//
//  MotionsFilterTableViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-4-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsFilterTableViewController.h"

#define CELL_WIDTH 270
#define CELL_HEIGHT

@interface MotionsFilterTableViewController ()

@end

@implementation MotionsFilterTableViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
}

#pragma mark -
#pragma mark UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    NSString *cellIdentifier = @"MotionsFilterTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if(indexPath.row == 0) {
        for(int i = 1; i < 4; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"motions_effects_cell_bg.png"]];
            CGRect frame = imageView.frame;
            frame.origin = CGPointMake(0, 108 * i * (-1));
            imageView.frame = frame;
            [cell addSubview:imageView];
        }
    }
    else if(indexPath.row == 2) {
        for(int i = 1; i < 5; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"motions_effects_cell_bg.png"]];
            CGRect frame = imageView.frame;
            frame.origin = CGPointMake(0, 108 * i);
            imageView.frame = frame;
            [cell addSubview:imageView];
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

@end
