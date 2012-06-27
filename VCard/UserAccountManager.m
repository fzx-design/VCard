//
//  UserAccountManager.m
//  VCard
//
//  Created by 海山 叶 on 12-6-27.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserAccountManager.h"

@implementation UserAccountManager

static UserAccountManager *sharedUserAccount;

+ (void)initializeWithCurrentUser:(User *)user managedObjectContext:(NSManagedObjectContext *)context
{
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        sharedUserAccount = [[UserAccountManager alloc] init];
        sharedUserAccount.currentUser = user;
        sharedUserAccount.managedObjectContext = context;
    }
}

+ (UserAccountManager *)sharedUserAccount
{
    return sharedUserAccount;
}

+ (User *)currentUser
{
    return sharedUserAccount.currentUser;
}

@end
