//
//  UnreadReminder.h
//  VCard
//
//  Created by 海山 叶 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface UnreadReminder : NSObject

@property (nonatomic, strong) User *currentUser;

+ (void)initializeWithCurrentUser:(User *)user;

@end
