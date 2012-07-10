//
//  LoginCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginUserCellViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ResourceList.h"
#import "CastViewController.h"
#import "WBClient.h"

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
    [self.delegate loginUserCell:self didDeleteUser:self.ownerUser];
}

- (IBAction)didClickLoginButton:(UIButton *)sender {
    [self.delegate loginUserCell:self didSelectUser:self.ownerUser];
}

@end
