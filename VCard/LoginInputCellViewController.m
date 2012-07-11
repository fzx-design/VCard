//
//  LoginCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginInputCellViewController.h"
#import "UIView+Addition.h"

@interface LoginInputCellViewController ()

@end

@implementation LoginInputCellViewController

@synthesize userNameTextField = _userNameTextField;
@synthesize userPasswordTextField = _userPasswordTextField;
@synthesize activityIndicator = _activityIndicator;

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
    self.activityIndicator.hidden = YES;
    
    self.userNameTextField.text = @"";
    self.userPasswordTextField.text = @"";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.activityIndicator = nil;
    self.userNameTextField = nil;
    self.userPasswordTextField = nil;
}

#pragma mark - Logic methods 

- (void)login {
    if (self.userNameTextField.text == @"") {
        [self.userNameTextField becomeFirstResponder];
    } else if(self.userPasswordTextField.text == @"") {
        return;
    } else {
        self.loginButton.hidden = YES;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        
        [self.userPasswordTextField resignFirstResponder];
        [self loginUsingAccount:self.userNameTextField.text password:self.userPasswordTextField.text completion:^(BOOL succeeded) {
            if(!succeeded) {
                self.loginButton.hidden = NO;
                self.activityIndicator.hidden = YES;
                [self.activityIndicator stopAnimating];
            }
        }];
    }
}


#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.userNameTextField]) {
        [self.userPasswordTextField becomeFirstResponder];
    } else if([textField isEqual:self.userPasswordTextField]) {
        [self login];
    }
    return YES;
}

#pragma mark - IBActions

- (IBAction)loginButtonClicked:(id)sender
{    
    [self login];
}

@end
