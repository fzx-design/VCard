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
#import "PostViewController.h"
#import "UIApplication+Addition.h"
#import "GroupInfoTableViewController.h"
#import "Conversation.h"

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
    [ThemeResourceProvider configButtonPaperLight:_mentionButton];
    [ThemeResourceProvider configButtonPaperLight:_messageButton];
    _mentionButton.enabled = NO;
    _messageButton.enabled = NO;
    
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
            self.user = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext withOperatingObject:self.description operatableType:kOperatableTypeNone];
            [super setUpViews];
            [self setUpSpecificView];
        } else {
            [self.relationshipButton setTitle:@"读取失败" forState:UIControlStateNormal];
            [self.relationshipButton setTitle:@"读取失败" forState:UIControlStateHighlighted];
            self.relationshipButton.enabled = NO;
            self.moreInfoButton.enabled = NO;
            [self.discriptionLabel setText:@""];
            [self.discriptionShadowLabel setText:@""];
        }
    }];
    
    [client getUserByScreenName:self.screenName];
}

- (void)setUpSpecificView
{
    _mentionButton.enabled = YES;
    [self checkMessageAvailable];
    [self showStatuses:nil];
    [self updateRelationshipfollowing:self.user.following.boolValue];
}

- (void)checkMessageAvailable
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError && [client.responseJSONObject isKindOfClass:[NSDictionary class]]) {
            NSNumber *available = [client.responseJSONObject objectForKey:@"result"];
            _messageButton.enabled = available.boolValue;
        }
    }];
    
    [client isMessageAvailable:self.user.userID];
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
    };
    [_relationshipButton setTitle:relationShip forState:UIControlStateNormal];
    [_relationshipButton setTitle:relationShip forState:UIControlStateHighlighted];
    
    _moreInfoButton.enabled = following;
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
    CGRect frame = [self.view convertRect:_mentionButton.frame toView:[UIApplication sharedApplication].rootViewController.view];
    PostViewController *vc = [PostViewController getNewStatusViewControllerWithAtUserName:self.screenName delegate:self];
    [vc showViewFromRect:frame];
}

- (IBAction)didClickMoreInfoButton:(UIButton *)sender
{
    [GroupInfoTableViewController showGroupInfoOfUser:self.user.userID fromRect:_moreInfoButton.frame inView:self.backgroundView];
}

- (IBAction)didClickMessageButton:(UIButton *)sender
{
    Conversation *conversation = [Conversation conversationWithCurrentUserID:self.currentUser.userID
                                                                targetUserID:self.user.userID
                                                      inManagedObjectContext:self.managedObjectContext];
    if (conversation == nil) {
        conversation = [Conversation insertCOnversationWithCurrentUserID:self.currentUser.userID
                                                              targetUser:self.user
                                                  inManagedObjectContext:self.managedObjectContext];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowConversation object:@{kNotificationObjectKeyConversation: conversation, kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex]}];
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
            self.user.following = @(YES);
            _moreInfoButton.enabled = YES;
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
            self.user.following = @(NO);
            _moreInfoButton.enabled = NO;
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

#pragma mark - PostViewController Delegate

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message {
    [vc dismissViewUpwards];
}

- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message {
    [vc dismissViewToRect:[self.view convertRect:_mentionButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
}

@end
