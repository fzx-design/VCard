//
//  FriendProfileViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "WBClient.h"
#import "User.h"

@implementation FriendProfileViewController

@synthesize relationshipButton = _relationshipButton;

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
    [_screenNameLabel setText:self.screenName];
    
    if (self.user == nil) {
        [self loadUser];
    } else {
        [super setUpViews];
        [self setUpSpecificView];
    }
}


- (void)loadUser
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            self.user = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext];
            [super setUpViews];
            [self setUpSpecificView];
        }
    }];
    
    [client getUserByScreenName:self.screenName];
}

- (void)setUpSpecificView
{
    BOOL following = [self.user.following boolValue];
    BOOL followMe = [self.user.followMe boolValue];
    
    NSString *relationShip = nil;
    if (!following) {
        relationShip = @"关注";
    } else if(!followMe){
        relationShip = @"已关注";
    } else {
        relationShip = @" 互相关注";
    }
    
    [_relationshipButton setTitle:relationShip forState:UIControlStateNormal];
    [_relationshipButton setTitle:relationShip forState:UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


@end
