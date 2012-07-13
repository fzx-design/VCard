//
//  WTGroupTableViewController.m
//  WeTongji
//
//  Created by 紫川 王 on 12-4-14.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "WTGroupTableViewController.h"
#import "NSUserDefaults+Addition.h"
#import "NSNotificationCenter+Addition.h"

@interface WTGroupTableViewController ()

@end

@implementation WTGroupTableViewController

@synthesize dataSourceIndexArray = _dataSourceIndexArray;
@synthesize dataSourceDictionary = _dataSourceDictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dataSourceIndexArray = [NSMutableArray arrayWithCapacity:10];
        self.dataSourceDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureDataSource];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.tableView = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

#pragma mark -
#pragma mark UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.dataSourceIndexArray objectAtIndex:section];
    NSArray *value = [self.dataSourceDictionary valueForKey:key];
    return value.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSourceIndexArray.count;
}

#pragma mark -
#pragma mark UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"TableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark -
#pragma mark Methods to overwrite

- (void)configureDataSource {
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

@end
