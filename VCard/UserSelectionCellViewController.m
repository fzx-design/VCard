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

#define CornerRadius 175 / 2

@interface UserSelectionCellViewController ()

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
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLoginTextFieldShouldBeginEditing object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLoginTextFieldShouldEndEditing object:nil];
    return YES;
}

@end
