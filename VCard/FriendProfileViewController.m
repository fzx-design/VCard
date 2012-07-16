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
    _loading = NO;
    [self.screenNameLabel setText:self.screenName];
    [ThemeResourceProvider configButtonPaperLight:_moreInfoButton];
    
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
            self.user = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
            [super setUpViews];
            [self setUpSpecificView];
        }
    }];
    
    [client getUserByScreenName:self.screenName];
}

- (void)setUpSpecificView
{
    [self showStatuses:nil];
    [self updateRelationshipfollowing:self.user.following.boolValue];
}

- (void)updateRelationshipfollowing:(BOOL)following
{
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

- (void)updatingRelationship
{
    NSString *relationShip = @"操作中";
    [_relationshipButton setTitle:relationShip forState:UIControlStateNormal];
    [_relationshipButton setTitle:relationShip forState:UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma mark - IBActions
- (IBAction)didClickRelationButton:(UIButton *)sender
{
    if (_loading) {
        return;
    }
    BOOL following = [self.user.following boolValue];
    if (following) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self 
                                                        cancelButtonTitle:nil 
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"取消关注", nil];
        actionSheet.destructiveButtonIndex = 0;
        actionSheet.delegate = self;
        [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
    } else {
        [self followUser];
    }
}

- (IBAction)didClickMentionButton:(UIButton *)sender
{
    
}

- (void)followUser
{
    if (_loading || self.user == nil) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            self.user.following = [NSNumber numberWithBool:YES];
        } else {
            //TODO: Report error
        }
        [self updateRelationshipfollowing:!client.hasError];
        _loading = NO;
    }];
    
    [self updatingRelationship];
    
    [client follow:self.user.userID];
}

- (void)unfollowUser
{
    if (_loading || self.user == nil) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            self.user.following = [NSNumber numberWithBool:NO];
        } else {
            //TODO: Report error
        }
        [self updateRelationshipfollowing:client.hasError];
        _loading = NO;
    }];
    
    [self updatingRelationship];
    
    [client unfollow:self.user.userID];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self unfollowUser];
    }
}

@end
