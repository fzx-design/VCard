//
//  NSNotificationCenter+Addition.m
//  SocialFusion
//
//  Created by 王紫川 on 12-1-24.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "NSNotificationCenter+Addition.h"

#define kChangeCurrentUserNotification          @"ChangeCurrentUserNotification"
#define kCoreChangeCurrentUserNotification      @"CoreChangeCurrentUserNotification"
#define kNotificationNameShouldChangeUserAvatar @"NotificationNameShouldChangeUserAvatar"
#define kWBClientErrorNotification              @"WBClientErrorNotification"

#define kRootViewControllerViewDidLoadNotification  @"RootViewControllerViewDidLoadNotification"
#define kShouldPostRecommendVCardWeiboNotification  @"ShouldPostRecommendVCardWeiboNotification"

@implementation NSNotificationCenter (Addition)

+ (void)postShouldPostRecommendVCardWeiboNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldPostRecommendVCardWeiboNotification object:nil userInfo:nil];
}

+ (void)registerShouldPostRecommendVCardWeiboNotificationWithSelector:(SEL)aSelector target:(id)aTarget {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kShouldPostRecommendVCardWeiboNotification 
                 object:nil];
}

+ (void)postRootViewControllerViewDidLoadNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRootViewControllerViewDidLoadNotification object:nil userInfo:nil];
}

+ (void)registerRootViewControllerViewDidLoadNotificationWithSelector:(SEL)aSelector target:(id)aTarget {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kRootViewControllerViewDidLoadNotification 
                 object:nil];
}

+ (void)postWBClientErrorNotification:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWBClientErrorNotification object:error userInfo:nil];
}

+ (void)registerWBClientErrorNotificationWithSelector:(SEL)aSelector target:(id)aTarget {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kWBClientErrorNotification 
                 object:nil];
}

+ (void)postChangeCurrentUserNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeCurrentUserNotification object:nil userInfo:nil];
}

+ (void)registerChangeCurrentUserNotificationWithSelector:(SEL)aSelector target:(id)aTarget {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kChangeCurrentUserNotification 
                 object:nil];
}

+ (void)postCoreChangeCurrentUserNotificationWithUserID:(NSString *)userID {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCoreChangeCurrentUserNotification object:userID userInfo:nil];
}

+ (void)registerCoreChangeCurrentUserNotificationWithSelector:(SEL)aSelector target:(id)aTarget {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kCoreChangeCurrentUserNotification 
                 object:nil];
}

+ (void)postChangeUserAvatarNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldChangeUserAvatar object:nil userInfo:nil];
}

+ (void)registerChangeUserAvatarNotificationWith:(SEL)aSelector target:(id)aTarget {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:aTarget selector:aSelector
                   name:kNotificationNameShouldChangeUserAvatar
                 object:nil];
}

@end
