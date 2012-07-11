//
//  SelfProfileViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SelfProfileViewController.h"
#import "LoginViewController.h"

@implementation SelfProfileViewController

@synthesize changeAvatarButton = _changeAvatarButton;
@synthesize checkCommentButton = _checkCommentButton;
@synthesize checkMentionButton = _checkMentionButton;

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
    self.user = self.currentUser;
    
    [super setUpViews];
    if (_shouldShowFollowerList) {
        [self showFollowers:nil];
    } else {
        [self showStatuses:nil];
    }
    [ThemeResourceProvider configButtonPaperLight:_accountSettingButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)didClickCheckCommentButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowSelfCommentList object:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", self.pageIndex] forKey:kNotificationObjectKeyIndex]];
}

- (IBAction)didClickCheckMentionButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowSelfMentionList object:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", self.pageIndex] forKey:kNotificationObjectKeyIndex]];
}

- (IBAction)didClickAccountSettingButton:(id)sender {
    LoginViewController *vc = [[LoginViewController alloc] init];
    [vc show];
}

@end
