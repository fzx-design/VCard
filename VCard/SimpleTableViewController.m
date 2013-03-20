//
//  SimpleTableViewController.m
//  VCard
//
//  Created by Emerson on 13-3-18.
//  Copyright (c) 2013年 Mondev. All rights reserved.
//

#import "SimpleTableViewController.h"
#import "UIApplication+Addition.h"
#import "MyCell.h"
@interface SimpleTableViewController ()

@end

@implementation SimpleTableViewController
@synthesize listData = _listData;

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
    NSDictionary * temp_array = [[NSDictionary alloc]initWithObjectsAndKeys:@"Simple Table",@"Name",@"White",@"Color", nil];
    _listData = [[NSArray alloc]initWithObjects:temp_array, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellTableIdentifier = @"CellTableIdentifier";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib * nib = [UINib nibWithNibName:@"MyCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellTableIdentifier];
        nibsRegistered = YES;
    }
    
    NSUInteger row = [indexPath row];
    NSDictionary * rowData = [_listData objectAtIndex:row];
    MyCell * cell = [tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    cell.name = [rowData objectForKey:@"Name"];
    cell.color = [rowData objectForKey:@"Color"];
    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    return row;
}

-(NSIndexPath *)tableView:(UITableView *)tableView
 willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSUInteger row = [indexPath row];
//    
//    if (row == 0)
//        return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSString *rowValue = [_listData objectAtIndex:row];
    
    NSString *message = [[NSString alloc] initWithFormat:@"You selected %@", rowValue];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row Selected!"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Yes I Did"
                                          otherButtonTitles:nil];
    [alert show];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

@end
