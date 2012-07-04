//
//  SearchViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

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
    [self.backgroundView addSubview:self.searchTableViewController.view];
    _textField.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Textfield Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *searchKey = textField.text;
    
    if (!searchKey || [searchKey isEqualToString:@""]) {
        return NO;
    }
    
    [_textField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowTopic object:[NSDictionary dictionaryWithObjectsAndKeys:searchKey, kNotificationObjectKeySearchKey, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
    
    return YES;
}

#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 52;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (SearchTableViewController *)searchTableViewController
{
    if (!_searchTableViewController) {
        _searchTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchTableViewController"];
        _searchTableViewController.pageIndex = self.pageIndex;
        _searchTableViewController.view.frame = [self frameForTableView];
        _searchTableViewController.tableView.frame = [self frameForTableView];
    }
    return _searchTableViewController;
}

@end
