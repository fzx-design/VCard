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

@interface LoginUserCellViewController ()

@property (nonatomic, strong) User *ownerUser;

@end

@implementation LoginUserCellViewController

@synthesize userNameLabel = _userNameLabel;
@synthesize deleteButton = _deleteButton;
@synthesize delegate = _delegate;

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
        [self.avatarImageView loadImageFromURL:self.ownerUser.largeAvatarURL completion:^{
            [self.avatarImageView fadeIn];
        }];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.deleteButton = nil;
    self.userNameLabel = nil;
}

#pragma mark - IBActions

- (IBAction)didClickDeleteButton:(UIButton *)sender {
    [self.delegate loginCellDidDeleteUser:self.ownerUser];
}

- (IBAction)didClickLoginButton:(UIButton *)sender {
    [self.loginButton setTitle:@"登录中" forState:UIControlStateNormal];
    UserAccountInfo *accountInfo = [NSUserDefaults getUserAccountInfoWithUserID:self.ownerUser.userID];
    [self loginUsingAccount:accountInfo.account password:accountInfo.password completion:^(BOOL succeeded) {
        if(!succeeded)
            [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    }];
}

@end
