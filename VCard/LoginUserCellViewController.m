//
//  LoginCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginUserCellViewController.h"
#import "UIView+Addition.h"
#import "UIImageView+Addition.h"
#import "NSUserDefaults+Addition.h"
#import "WBClient.h"

@interface LoginUserCellViewController () {
    BOOL _shouldPresentDeleteUserActionSheet;
}

@property (nonatomic, strong) User *ownerUser;
@property (nonatomic, strong) UIActionSheet *actionSheet;

@end

@implementation LoginUserCellViewController

@synthesize userNameLabel = _userNameLabel;
@synthesize deleteButton = _deleteButton;
@synthesize delegate = _delegate;
@synthesize actionSheet = _actionSheet;

@synthesize ownerUser = _ownerUser;

- (id)initWithUser:(User *)user {
    self = [super init];
    if(self) {
        self.ownerUser = user;
    }
    return self;
}

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
    if(self.ownerUser) {
        self.userNameLabel.text = self.ownerUser.screenName;
        [self.avatarImageView loadImageFromURL:self.ownerUser.largeAvatarURL completion:^(BOOL succeeded){
            [self.avatarImageView fadeIn];
        }];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];    
    [center addObserver:self selector:@selector(deviceRotationDidChange:) name:kNotificationNameOrientationChanged object:nil];
    [center addObserver:self selector:@selector(deviceRotationWillChange:) name:kNotificationNameOrientationWillChange object:nil];
}

- (void)viewDidUnload
{
    self.deleteButton = nil;
    self.userNameLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Notification handlers

- (void)deviceRotationDidChange:(NSNotification *)notification {
    if(_shouldPresentDeleteUserActionSheet)
        [self presentDeleteUserActionSheet];
    _shouldPresentDeleteUserActionSheet = NO;
}

- (void)deviceRotationWillChange:(NSNotification *)notification {
    if(self.actionSheet)
        _shouldPresentDeleteUserActionSheet = YES;
    [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
}

#pragma mark - UI methods

- (void)presentDeleteUserActionSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"删除帐户" otherButtonTitles:nil];
    [sheet showFromRect:self.deleteButton.bounds inView:self.deleteButton animated:YES];
    self.actionSheet = sheet;
}

#pragma UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == actionSheet.destructiveButtonIndex)
        [self.delegate loginCellDidDeleteUser:self.ownerUser];
    self.actionSheet = nil;
}

#pragma mark - IBActions

- (IBAction)didClickDeleteButton:(UIButton *)sender {
    [self presentDeleteUserActionSheet];
}

- (IBAction)didClickLoginButton:(UIButton *)sender {
    [self.loginButton setTitle:@"登录中" forState:UIControlStateNormal];
    self.loginButton.enabled = NO;
    UserAccountInfo *accountInfo = [NSUserDefaults getUserAccountInfoWithUserID:self.ownerUser.userID];
    [self loginUsingAccount:accountInfo.account password:accountInfo.password completion:^(BOOL succeeded) {
        if(!succeeded) {
            [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
            self.loginButton.enabled = YES;
            [self handleWrongPasswordSituation];
        }
    }];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        
    } else {
        UserAccountInfo *accountInfo = [NSUserDefaults getUserAccountInfoWithUserID:[CoreDataViewController getCurrentUser].userID];
        NSString *newPassword = [alertView textFieldAtIndex:0].text;
        [NSUserDefaults insertUserAccountInfoWithUserID:accountInfo.userID account:accountInfo.account password:newPassword];
        [self didClickLoginButton:self.loginButton];
    }
}

#pragma mark - Token methods

- (void)handleWrongPasswordSituation {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新浪微博"
                                                    message:[NSString stringWithFormat:@"%@，您的密码可能已经更改，请重新输入。", [CoreDataViewController getCurrentUser].screenName]
                                                   delegate:self
                                          cancelButtonTitle:@"取消" 
                                          otherButtonTitles:@"继续", nil];
    
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

@end
