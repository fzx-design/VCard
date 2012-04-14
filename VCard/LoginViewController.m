//
//  LoginViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginViewController.h"
#import "ResourceList.h"

#define NUM_OF_CELLS                1

#define PORTRAIT_WIDTH				768
#define HORIZONTAL_TABLEVIEW_HEIGHT	478
#define VERTICAL_TABLEVIEW_WIDTH	768
#define TABLE_BACKGROUND_COLOR		[UIColor clearColor]
#define UserSelectionFrame          CGRectMake(0, UserPortraitOriginY, PORTRAIT_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT)

#define LogoPortraitOriginY 105
#define LogoLandscapeOriginY 45
#define UserPortraitOriginY  255
#define UserLandscapeOriginY 165

#define FrameNormalPortrait CGRectMake(0, 0, 768, 1004)
#define FrameNormalLandscape CGRectMake(0, 0, 1024, 748)
#define FrameEditingTextViewLandscape CGRectMake(0, -220, 1024, 768 + 220)
#define OffsetOrigin 0

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
    
    [self setupParameters];
    [self setupHorizontalView];
    [self setNotificationSettings];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    _currentOrientation = interfaceOrientation;
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

    [self setLogoAndLoginViewWhenRotating];
    
    [self setViewOffsetForEditingMode];
}

- (void)setNotificationSettings
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(loginTextFieldShouldBeginEditing:) 
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [center addObserver:self selector:@selector(loginTextFieldShouldEndEditing:) 
                   name:UIKeyboardWillHideNotification 
                 object:nil];
}

#pragma mark -
#pragma mark Initialization

- (void)setupParameters
{
    _isEditingTextfield = NO;
}

- (void)loginTextFieldShouldBeginEditing:(id)sender
{
    _isEditingTextfield = YES;
    [self setViewOffsetForEditingMode];
}

- (void)loginTextFieldShouldEndEditing:(id)sender
{
    _isEditingTextfield = NO;
    [self setViewOffsetForEditingMode];
}

- (void)setViewOffsetForEditingMode
{
    CGRect targetFrame;
    if (UIInterfaceOrientationIsPortrait(_currentOrientation)) {
        targetFrame = FrameNormalPortrait;
    } else {
        targetFrame = _isEditingTextfield ? FrameEditingTextViewLandscape : FrameNormalLandscape;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = targetFrame;
    }];

}

- (void)setLogoAndLoginViewWhenRotating
{
    CGRect logoFrame = self.logoImageView.frame;
    CGRect userSelectionFrame = self.userSelectionTableView.frame;
    
    logoFrame.origin.y = UIInterfaceOrientationIsPortrait(_currentOrientation) ? LogoPortraitOriginY : LogoLandscapeOriginY;
    userSelectionFrame.origin.y = UIInterfaceOrientationIsPortrait(_currentOrientation) ? UserPortraitOriginY : UserLandscapeOriginY;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.logoImageView.frame = logoFrame;
        self.userSelectionTableView.frame = userSelectionFrame;
    }];
}


#pragma mark -
#pragma mark EasyTableView Initialization

- (void)setupHorizontalView {
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:UserSelectionFrame 
                                               numberOfColumns:NUM_OF_CELLS 
                                                       ofWidth:VERTICAL_TABLEVIEW_WIDTH];
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

}

// Optional delegate to track the selection of a particular cell

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {

}


@end
