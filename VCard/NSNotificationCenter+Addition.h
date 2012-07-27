//
//  NSNotificationCenter+Addition.h
//  SocialFusion
//
//  Created by 王紫川 on 12-1-24.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Addition)

+ (void)postChangeCurrentUserNotification;
+ (void)postCoreChangeCurrentUserNotificationWithUserID:(NSString *)userID;
+ (void)postChangeUserAvatarNotification;
+ (void)postWBClientErrorNotification:(NSError *)error;
+ (void)postRootViewControllerViewDidLoadNotification;
+ (void)postShouldPostRecommendVCardWeiboNotification;
+ (void)postWillReloadCardCellNotification;
+ (void)postDidReloadCardCellNotification;

+ (void)registerCoreChangeCurrentUserNotificationWithSelector:(SEL)aSelector target:(id)aTarget;
+ (void)registerChangeCurrentUserNotificationWithSelector:(SEL)aSelector target:(id)aTarget;
+ (void)registerChangeUserAvatarNotificationWith:(SEL)aSelector target:(id)aTarget;
+ (void)registerWBClientErrorNotificationWithSelector:(SEL)aSelector target:(id)aTarget;
+ (void)registerRootViewControllerViewDidLoadNotificationWithSelector:(SEL)aSelector target:(id)aTarget;
+ (void)registerShouldPostRecommendVCardWeiboNotificationWithSelector:(SEL)aSelector target:(id)aTarget;
+ (void)registerWillReloadCardCellNotificationWithSelector:(SEL)aSelector target:(id)aTarget;
+ (void)registerDidReloadCardCellNotificationWithSelector:(SEL)aSelector target:(id)aTarget;

@end
