//
//  LoginCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginCellViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ResourceList.h"
#import "CastViewController.h"
#import "WBClient.h"

#define CornerRadius 175 / 2

typedef enum {
    ActiveTextfieldNone,
    ActiveTextfieldName,
    ActiveTextfieldPassword,
} ActiveTextfield;


@interface LoginCellViewController () {
    BOOL _shouldLowerKeyboard;
    ActiveTextfield _currentActiveTextfield;
}
@end

@implementation LoginCellViewController

@synthesize avatarImageView = _avatarImageView;
@synthesize userNameTextField = _userNameTextField;
@synthesize userPasswordTextField = _userPasswordTextField;
@synthesize loginButton = _loginButton;

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
    
    _avatarImageView.image = [UIImage imageNamed:kRLAvatarPlaceHolder];
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.layer.cornerRadius = CornerRadius;    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    if ([textField isEqual:self.userNameTextField]) {
        
        [self.userPasswordTextField becomeFirstResponder];
        
    } else if([textField isEqual:self.userPasswordTextField]) {
        
        [self.userPasswordTextField resignFirstResponder];
        
        if (self.userNameTextField.text == @"") {
            [self.userNameTextField becomeFirstResponder];
        } else {
            WBClient *client = [WBClient client];
            
            [client setCompletionBlock:^(WBClient *client) {
                if (!client.hasError) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLoginInfoAuthorized object:nil];
                } else {
                    NSLog(@"Error!");
                }
            }];
            
            [client authorizeUsingUserID:self.userNameTextField.text password:self.userPasswordTextField.text];
        }
        
    }
    
    return YES;
}

#pragma mark - 
- (IBAction)loginButtonClicked:(id)sender
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLoginInfoAuthorized object:nil];
        } else {
            NSLog(@"Error!");
        }
    }];
    
    [client authorizeUsingUserID:self.userNameTextField.text password:self.userPasswordTextField.text];
}


@end
