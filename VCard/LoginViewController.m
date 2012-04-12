//
//  LoginViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginViewController.h"

#define NUM_OF_CELLS                1

#define PORTRAIT_WIDTH				768
#define LANDSCAPE_HEIGHT			(1024-20)
#define HORIZONTAL_TABLEVIEW_HEIGHT	478
#define VERTICAL_TABLEVIEW_WIDTH	768
#define TABLE_BACKGROUND_COLOR		[UIColor clearColor]
#define UserSelectionFrame CGRectMake(0,UserPortraitOriginY, PORTRAIT_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT)

#define LogoPortraitOriginY 133
#define LogoLandscapeOriginY 83
#define UserPortraitOriginY  250
#define UserLandscapeOriginY 200

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize logoImageView = _logoImageView;
@synthesize userSelectionTableView = _userSelectionTableView;
@synthesize currentUserCell = _currentUserCell;

#pragma mark -
#pragma mark LifeCycle

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
	// Do any additional setup after loading the view.
    [self setupHorizontalView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect logoFrame = self.logoImageView.frame;
    CGRect userSelectionFrame = self.userSelectionTableView.frame;
    
    logoFrame.origin.y = UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) ? LogoPortraitOriginY : LogoLandscapeOriginY;
    userSelectionFrame.origin.y = UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) ? UserPortraitOriginY : UserLandscapeOriginY;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.logoImageView.frame = logoFrame;
        self.userSelectionTableView.frame = userSelectionFrame;
    }];
}

#pragma mark -
#pragma mark EasyTableView Initialization

- (void)setupHorizontalView {
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:UserSelectionFrame numberOfColumns:NUM_OF_CELLS ofWidth:VERTICAL_TABLEVIEW_WIDTH];
	self.userSelectionTableView = view;
	
	_userSelectionTableView.delegate = self;
	_userSelectionTableView.tableView.backgroundColor = TABLE_BACKGROUND_COLOR;
	_userSelectionTableView.tableView.allowsSelection = NO;
	_userSelectionTableView.tableView.separatorColor = [UIColor clearColor];
	_userSelectionTableView.cellBackgroundColor = [UIColor clearColor];
    _userSelectionTableView.mainStoryboard = self.storyboard;
	_userSelectionTableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:_userSelectionTableView];
}

#pragma mark -
#pragma mark EasyTableViewDelegate

// Second delegate populates the views with data from a data source

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath {
//	UILabel *label	= (UILabel *)view;
//	label.text		= [NSString stringWithFormat:@"%i", indexPath.row];
}

// Optional delegate to track the selection of a particular cell

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {
//	[self borderIsSelected:YES forView:selectedView];		
//	
//	if (deselectedView) 
//		[self borderIsSelected:NO forView:deselectedView];
//	
//	UILabel *label	= (UILabel *)selectedView;
//	bigLabel.text	= label.text;
}


@end
