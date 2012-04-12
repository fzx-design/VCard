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
#define HORIZONTAL_TABLEVIEW_HEIGHT	500
#define VERTICAL_TABLEVIEW_WIDTH	1024
#define TABLE_BACKGROUND_COLOR		[UIColor clearColor]

@interface LoginViewController ()

@end

@implementation LoginViewController

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

#pragma mark -
#pragma mark EasyTableView Initialization

- (void)setupHorizontalView {
	CGRect frameRect	= CGRectMake(0, LANDSCAPE_HEIGHT / 3, PORTRAIT_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:NUM_OF_CELLS ofWidth:VERTICAL_TABLEVIEW_WIDTH];
	self.userSelectionTableView = view;
	
	_userSelectionTableView.delegate = self;
	_userSelectionTableView.tableView.backgroundColor = TABLE_BACKGROUND_COLOR;
	_userSelectionTableView.tableView.allowsSelection = NO;
	_userSelectionTableView.tableView.separatorColor = [UIColor darkGrayColor];
	_userSelectionTableView.cellBackgroundColor = [UIColor whiteColor];
	_userSelectionTableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:_userSelectionTableView];
}

#pragma mark -
#pragma mark EasyTableViewDelegate

// These delegate methods support both example views - first delegate method creates the necessary views

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
//	CGRect labelRect		= CGRectMake(10, 10, rect.size.width-20, rect.size.height-20);
//	UILabel *label			= [[UILabel alloc] initWithFrame:labelRect];
//	label.textAlignment		= UITextAlignmentCenter;
//	label.textColor			= [UIColor whiteColor];
//	label.font				= [UIFont boldSystemFontOfSize:60];
//    
//    
//	return label;
    
    UserSelectionCellViewController *cell = [[UserSelectionCellViewController alloc] init];
    
    _currentUserCell = nil;
    _currentUserCell = cell;
    
    return cell.view;
    
}

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

#pragma mark -
#pragma mark Optional EasyTableView delegate methods for section headers and footers

#ifdef SHOW_MULTIPLE_SECTIONS

//// Delivers the number of sections in the TableView
//- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)easyTableView{
//    return NUM_OF_SECTIONS;
//}
//
//// Delivers the number of cells in each section, this must be implemented if numberOfSectionsInEasyTableView is implemented
//-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
//    return NUM_OF_CELLS;
//}
//
//// The height of the header section view MUST be the same as your HORIZONTAL_TABLEVIEW_HEIGHT (horizontal EasyTableView only)
//- (UIView *)easyTableView:(EasyTableView*)easyTableView viewForHeaderInSection:(NSInteger)section {
//    UILabel *label = [[UILabel alloc] init];
//	label.text = @"HEADER";
//	label.textColor = [UIColor whiteColor];
//	label.textAlignment = UITextAlignmentCenter;
//    
//	if (easyTableView == self.horizontalView) {
//		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
//	}
//	if (easyTableView == self.verticalView) {
//		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
//	}
//    
//    switch (section) {
//        case 0:
//            label.backgroundColor = [UIColor redColor];
//            break;
//        default:
//            label.backgroundColor = [UIColor blueColor];
//            break;
//    }
//    return label;
//}
//
//// The height of the footer section view MUST be the same as your HORIZONTAL_TABLEVIEW_HEIGHT (horizontal EasyTableView only)
//- (UIView *)easyTableView:(EasyTableView*)easyTableView viewForFooterInSection:(NSInteger)section {
//    UILabel *label = [[UILabel alloc] init];
//	label.text = @"FOOTER";
//	label.textColor = [UIColor yellowColor];
//	label.textAlignment = UITextAlignmentCenter;
//	label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
//    
//	if (easyTableView == self.horizontalView) {
//		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
//	}
//	if (easyTableView == self.verticalView) {
//		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
//	}
//	
//    switch (section) {
//        case 0:
//            label.backgroundColor = [UIColor purpleColor];
//            break;
//        default:
//            label.backgroundColor = [UIColor brownColor];
//            break;
//    }
//    
//    return label;
//}

#endif


@end
