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
#import "NSNotificationCenter+Addition.h"

@interface UnreadReminder () {
    NSTimer *_timer;
    int _messageWaitingRound;
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
    _messageWaitingRound = 0;
}

- (void)timerFired:(NSTimer *)timer
{
    [self getUnread];
    [NSNotificationCenter postTimerFiredNotification];
}

- (void)getUnread
{
    WBClient *client = [WBClient client];
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
            
            NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
            sharedUnreadReminder.currentUser.unreadStatusCount = unreadStatusCount;
            
            int unreadCount = self.currentUser.unreadStatusCount.intValue;
            if (unreadCount != 0) {
                [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadStatusCount object:nil];
            }
            
            if(sharedUnreadReminder.currentUser.unreadCommentCount.integerValue != unreadCommentCount.integerValue) {
                sharedUnreadReminder.currentUser.unreadCommentCount = unreadCommentCount;
                if(commentEnabled) {
                    [self playSoundEffectWithUnreadCount:unreadCommentCount.integerValue];
                    [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadCommentCount object:nil];
                }
            }
            
            if(sharedUnreadReminder.currentUser.unreadFollowingCount.integerValue != unreadFollowingCount.integerValue) {
                sharedUnreadReminder.currentUser.unreadFollowingCount = unreadFollowingCount;
                if(followerEnabled) {
                    [self playSoundEffectWithUnreadCount:unreadFollowingCount.integerValue];
                    [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadFollowCount object:nil];
                }
            }
            
            if(sharedUnreadReminder.currentUser.unreadMentionCount.integerValue != unreadMentionCount.integerValue) {
                sharedUnreadReminder.currentUser.unreadMentionCount = unreadMentionCount;
                if(mentionEnabled) {
                    [self playSoundEffectWithUnreadCount:unreadMentionCount.integerValue];
                    [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadMentionCount object:nil];
                }
            }
            
            if(sharedUnreadReminder.currentUser.unreadMentionComment.integerValue != unreadMentionComment.integerValue) {
                sharedUnreadReminder.currentUser.unreadMentionComment = unreadMentionComment;
                if(mentionEnabled) {
                    [self playSoundEffectWithUnreadCount:unreadMentionComment.integerValue];
                    [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadMentionCommentCount object:nil];
                }
            }
            
            if (sharedUnreadReminder.currentUser.unreadMessageCount.integerValue != unreadMessageCount.integerValue) {
                sharedUnreadReminder.currentUser.unreadMessageCount = unreadMessageCount;
            }
            
            _messageWaitingRound = unreadMessageCount.integerValue == 0 ? 0 : _messageWaitingRound + 1;
            if(messageEnabled && _messageWaitingRound > 2) {
                _messageWaitingRound = 0;
                [self playSoundEffectWithUnreadCount:unreadMessageCount.integerValue];
                [defaultCenter postNotificationName:kNotificationNameShouldUpdateUnreadMessageCount object:nil];
            }
        }
    }];
    
    [client getUnreadCount:self.currentUser.userID];
}

- (void)playSoundEffectWithUnreadCount:(int)unreadCount
{
    if (unreadCount > 0) {
        [[SoundManager sharedManager] playNewMessageSound];
    }
}

@end
