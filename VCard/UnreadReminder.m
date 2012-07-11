//
//  UnreadReminder.m
//  VCard
//
//  Created by 海山 叶 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UnreadReminder.h"
#import "WBClient.h"
#import "User.h"
#import "WBClient.h"

@interface UnreadReminder () {
    NSTimer *_timer;
}

@end

@implementation UnreadReminder

static UnreadReminder *sharedUnreadReminder;

+ (void)initializeWithCurrentUser:(User *)user
{
    if (sharedUnreadReminder == nil) {
        sharedUnreadReminder = [[UnreadReminder alloc] init];
        [sharedUnreadReminder setUpTimer];
    }
    sharedUnreadReminder.currentUser = user;
}

+ (int)unreadStatusCountForCurrentUser
{
    return sharedUnreadReminder.currentUser.unreadStatusCount.intValue;
}

+ (int)unreadCommentCountForCurrentUser
{
    return sharedUnreadReminder.currentUser.unreadCommentCount.intValue;
}

+ (int)unreadFollowingCountForCurrentUser
{
    return sharedUnreadReminder.currentUser.unreadFollowingCount.intValue;
}

- (void)setUpTimer
{
    NSInteger interval = [[NSUserDefaults standardUserDefaults] integerForKey:kUserDefaultKeyRefreshingInterval];
	_timer = [NSTimer scheduledTimerWithTimeInterval:interval
											  target:self 
											selector:@selector(timerFired:) 
											userInfo:nil 
											 repeats:YES];
}

- (void)timerFired:(NSTimer *)timer
{
    [self getUnread];
}

- (void)getUnread
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *dict = client.responseJSONObject;
            sharedUnreadReminder.currentUser.unreadCommentCount = [dict objectForKey:@"cmt"];
            sharedUnreadReminder.currentUser.unreadFollowingCount = [dict objectForKey:@"follower"];
            sharedUnreadReminder.currentUser.unreadMentionCount = [dict objectForKey:@"mention_status"];
            sharedUnreadReminder.currentUser.unreadStatusCount = [dict objectForKey:@"status"];
            
            [self sendUnreadNotification];
        }
    }];
    
    [client getUnreadCount:self.currentUser.userID];
}

- (void)sendUnreadNotification
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    int unreadCount = self.currentUser.unreadStatusCount.intValue;
    if (unreadCount != 0) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadStatusCount object:nil];
    }
    
    unreadCount = self.currentUser.unreadCommentCount.intValue;
    if (unreadCount != 0) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadCommentCount object:nil];
    }
    
    unreadCount = self.currentUser.unreadMentionCount.intValue;
    if (unreadCount != 0) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadMentionCount object:nil];
    }
    
    unreadCount = self.currentUser.unreadFollowingCount.intValue;
    if (unreadCount != 0) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadFollowCount object:nil];
    }
}

@end
