//
//  SelfProfileViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SelfProfileViewController.h"

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


@end