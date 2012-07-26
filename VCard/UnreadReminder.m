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
#import "NSUserDefaults+Addition.h"

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
    BlockARCWeakSelf weakSelf = self;
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            
            NSArray *notificationStatusArray = [NSUserDefaults getCurrentNotificationStatus];
            
            BOOL commentEnabled = ((NSNumber *)[notificationStatusArray objectAtIndex:SettingOptionFontNotificationTypeComment]).boolValue;
            BOOL followerEnabled = ((NSNumber *)[notificationStatusArray objectAtIndex:SettingOptionFontNotificationTypeFollower]).boolValue;
            BOOL mentionEnabled = ((NSNumber *)[notificationStatusArray objectAtIndex:SettingOptionFontNotificationTypeMention]).boolValue;
            BOOL messageEnabled = ((NSNumber *)[notificationStatusArray objectAtIndex:SettingOptionFontNotificationTypeMessage]).boolValue;
            
            NSDictionary *dict = client.responseJSONObject;
            
            NSNumber *unreadStatusCount = [dict objectForKey:@"status"];
            NSNumber *unreadCommentCount = [dict objectForKey:@"cmt"];
            NSNumber *unreadFollowingCount = [dict objectForKey:@"follower"];
            NSNumber *unreadMentionCount = [dict objectForKey:@"mention_status"];
            NSNumber *unreadMentionComment = [dict objectForKey:@"mention_cmt"];
            NSNumber *unreadMessageCount = [dict objectForKey:@"dm"];
            
            sharedUnreadReminder.currentUser.unreadStatusCount = unreadStatusCount;
            
            if(sharedUnreadReminder.currentUser.unreadCommentCount.integerValue != unreadCommentCount.integerValue) {
                sharedUnreadReminder.currentUser.unreadCommentCount = unreadCommentCount;
                if(commentEnabled)
                    [[SoundManager sharedManager] playNewMessageSound];
            }
            
            if(sharedUnreadReminder.currentUser.unreadFollowingCount.integerValue != unreadFollowingCount.integerValue) {
                sharedUnreadReminder.currentUser.unreadFollowingCount = unreadFollowingCount;
                if(followerEnabled)
                    [[SoundManager sharedManager] playNewMessageSound];
            }
            
            if(sharedUnreadReminder.currentUser.unreadMentionCount.integerValue != unreadMentionCount.integerValue) {
                sharedUnreadReminder.currentUser.unreadMentionCount = unreadMentionCount;
                if(mentionEnabled)
                    [[SoundManager sharedManager] playNewMessageSound];
            }
            
            if(sharedUnreadReminder.currentUser.unreadMentionComment.integerValue != unreadMentionComment.integerValue) {
                sharedUnreadReminder.currentUser.unreadMentionComment = unreadMentionComment;
                if(mentionEnabled)
                    [[SoundManager sharedManager] playNewMessageSound];
            }
            
            if(sharedUnreadReminder.currentUser.unreadMessageCount.integerValue != unreadMessageCount.integerValue) {
                sharedUnreadReminder.currentUser.unreadMessageCount = unreadMessageCount;
                if(messageEnabled)
                    [[SoundManager sharedManager] playNewMessageSound];
            }
                        
            [weakSelf sendUnreadNotification];
        }
    }];
    
    [client getUnreadCount:self.currentUser.userID];
}

- (void)sendUnreadNotification
{
    NSArray *notificationStatusArray = [NSUserDefaults getCurrentNotificationStatus];
    
    BOOL commentEnabled = ((NSNumber *)[notificationStatusArray objectAtIndex:SettingOptionFontNotificationTypeComment]).boolValue;
    BOOL followerEnabled = ((NSNumber *)[notificationStatusArray objectAtIndex:SettingOptionFontNotificationTypeFollower]).boolValue;
    BOOL mentionEnabled = ((NSNumber *)[notificationStatusArray objectAtIndex:SettingOptionFontNotificationTypeMention]).boolValue;
    BOOL messageEnabled = ((NSNumber *)[notificationStatusArray objectAtIndex:SettingOptionFontNotificationTypeMessage]).boolValue;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    int unreadCount = self.currentUser.unreadStatusCount.intValue;
    if (unreadCount != 0) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadStatusCount object:nil];
    }
    
    unreadCount = self.currentUser.unreadCommentCount.intValue;
    if (unreadCount != 0 && commentEnabled) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadCommentCount object:nil];
    }
    
    unreadCount = self.currentUser.unreadMentionCount.intValue;
    if (unreadCount != 0 && mentionEnabled) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadMentionCount object:nil];
    }
    
    unreadCount = self.currentUser.unreadFollowingCount.intValue;
    if (unreadCount != 0 && followerEnabled) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadFollowCount object:nil];
    }
    unreadCount = self.currentUser.unreadMentionComment.intValue;
    if (unreadCount != 0 && mentionEnabled) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadMentionCommentCount object:nil];
    }
    unreadCount = self.currentUser.unreadMessageCount.intValue;
    if (unreadCount != 0 && messageEnabled) {
        [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadMessageCount object:nil];
    }
}

@end
