//
//  LoginCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginInputCellViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ResourceList.h"
#import "CastViewController.h"
#import "WBClient.h"
#import "UnreadReminder.h"
#import "Group.h"
#import "NSNotificationCenter+Addition.h"
#import "NSUserDefaults+Addition.h"

typedef enum {
    ActiveTextfieldNone,
    ActiveTextfieldName,
    ActiveTextfieldPassword,
} ActiveTextfield;


@interface LoginInputCellViewController () {
    BOOL _shouldLowerKeyboard;
    ActiveTextfield _currentActiveTextfield;
}
@end

@implementation LoginInputCellViewController

@synthesize userNameTextField = _userNameTextField;
@synthesize userPasswordTextField = _userPasswordTextField;
@synthesize delegate = _delegate;

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
    
    //self.userNameTextField.text = @"";
    //self.userPasswordTextField.text = @"";
    
    _shouldLowerKeyboard = YES;
    _currentActiveTextfield = ActiveTextfieldNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Logic methods 

- (void)login {
    if (self.userNameTextField.text == @"") {
        [self.userNameTextField becomeFirstResponder];
    } else if(self.userPasswordTextField.text == @"") {
        return;
    } else {
        [self.userPasswordTextField resignFirstResponder];
        self.view.userInteractionEnabled = NO;
        
        WBClient *client = [WBClient client];
        
        [client setCompletionBlock:^(WBClient *client) {
            if (!client.hasError) {
                NSDictionary *userDict = client.responseJSONObject;
                User *user = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
                
                [NSUserDefaults insertUserAccountInfoWithUserID:user.userID account:self.userNameTextField.text password:self.userPasswordTextField.text];
                
                [UnreadReminder initializeWithCurrentUser:user];
                
                [self.delegate loginInputCell:self didLoginUser:user];
                
                NSLog(@"login step 3 succeeded");
            } else {
                NSLog(@"login step 3 failed");
            }
            self.view.userInteractionEnabled = YES;
        }];

        [client authorizeUsingUserID:self.userNameTextField.text password:self.userPasswordTextField.text];
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
