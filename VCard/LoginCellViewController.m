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
#import "UnreadReminder.h"
#import "Group.h"
#import "NSNotificationCenter+Addition.h"

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

#pragma mark - Logic methods 

- (void)loginInfoAuthorized
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            User *user = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
            [NSNotificationCenter postCoreChangeCurrentUserNotificationWithUserID:user.userID];
            
            [UnreadReminder initializeWithCurrentUser:user];
            
            Group *favouriteGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
            favouriteGroup.groupID = @"Favourites";
            favouriteGroup.name = @"收藏";
            favouriteGroup.type = [NSNumber numberWithInt:kGroupTypeFavourite];
            favouriteGroup.picURL = self.currentUser.largeAvatarURL;
            favouriteGroup.index = [NSNumber numberWithInt:0];
            [self performSegueWithIdentifier:@"ShowRootViewController" sender:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldSaveContext object:nil];
        }
    }];
    
    [client getUser:[WBClient currentUserID]];
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
                    [self loginInfoAuthorized];
                } else {
                    NSLog(@"Error!");
                }
            }];
            
            [client authorizeUsingUserID:self.userNameTextField.text password:self.userPasswordTextField.text];
        }
        
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)loginButtonClicked:(id)sender
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            //[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLoginInfoAuthorized object:nil];
            [self.delegate loginCell:self didLoginUser:nil];
        } else {
            NSLog(@"Error!");
        }
    }];
    
    [client authorizeUsingUserID:self.userNameTextField.text password:self.userPasswordTextField.text];
}


@end
