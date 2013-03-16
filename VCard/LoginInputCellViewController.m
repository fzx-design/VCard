//
//  LoginCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginInputCellViewController.h"
#import "UIView+Addition.h"

@interface LoginInputCellViewController () {
    BOOL _tooManyUsers;
}

@end

@implementation LoginInputCellViewController

@synthesize userNameTextField = _userNameTextField;
@synthesize userPasswordTextField = _userPasswordTextField;
@synthesize activityIndicator = _activityIndicator;
@synthesize tooManyUsersLabel = _tooManyUsersLabel;
@synthesize inputBgView = _inputBgView;

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
    
    self.tooManyUsersLabel.alpha = 0;
}

- (void)viewDidUnload
{
    self.activityIndicator = nil;
    self.userNameTextField = nil;
    self.userPasswordTextField = nil;
    self.inputBgView = nil;
    self.tooManyUsersLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Logic methods 

- (void)login {
    if ([self.userNameTextField.text isEqualToString:@""]) {
        [self.userNameTextField becomeFirstResponder];
    } else if([self.userPasswordTextField.text isEqualToString:@""]) {
        return;
    } else {
        self.loginButton.hidden = YES;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        
        [self.userPasswordTextField resignFirstResponder];
        
        BlockARCWeakSelf weakSelf = self;
        [self loginUsingAccount:self.userNameTextField.text password:self.userPasswordTextField.text completion:^(BOOL succeeded) {
            if(!succeeded) {
                weakSelf.loginButton.hidden = NO;
                weakSelf.activityIndicator.hidden = YES;
                [weakSelf.activityIndicator stopAnimating];
            }
        }];
    }
}

- (void)setTooManyUsers:(BOOL)tooMany {
    if(tooMany) {
        self.tooManyUsersLabel.alpha = 1;
        self.inputBgView.alpha = 0;
    } else {
        if(_tooManyUsers) {
            [self.tooManyUsersLabel fadeOut];
            [self.inputBgView fadeIn];
        } else {
            self.tooManyUsersLabel.alpha = 0;
            self.inputBgView.alpha = 1;
        }
    }
    _tooManyUsers = tooMany;
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
