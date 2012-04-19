//
//  UserSelectionCellViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserSelectionCellViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ResourceList.h"
#import "CastViewController.h"

#define CornerRadius 175 / 2

typedef enum {
    ActiveTextfieldNone,
    ActiveTextfieldName,
    ActiveTextfieldPassword,
} ActiveTextfield;


@interface UserSelectionCellViewController () {
    BOOL _shouldLowerKeyboard;
    ActiveTextfield _currentActiveTextfield;
}
@end

@implementation UserSelectionCellViewController

@synthesize avatorImageView = _avatorImageView;
@synthesize userNameTextField = _userNameTextField;
@synthesize userPasswordTextField = _userPasswordTextField;

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
    
    _shouldLowerKeyboard = YES;
    _currentActiveTextfield = ActiveTextfieldNone;
    
    _userNameTextField.delegate = self;
    _userPasswordTextField.delegate = self;
    
    _avatorImageView.image = [UIImage imageNamed:kRLAvatorPlaceHolder];
    _avatorImageView.layer.masksToBounds = YES;
    _avatorImageView.layer.cornerRadius = CornerRadius;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    if ([textField isEqual:self.userNameTextField]) {
        
        [self.userPasswordTextField becomeFirstResponder];
        
    } else if([textField isEqual:self.userPasswordTextField]) {
        
        [self.userPasswordTextField resignFirstResponder];
        
    }
    
    return YES;
}

#pragma mark -



@end
