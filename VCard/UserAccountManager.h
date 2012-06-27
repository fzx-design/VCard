//
//  UserAccountManager.h
//  VCard
//
//  Created by 海山 叶 on 12-6-27.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserAccountManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;

+ (void)initializeWithCurrentUser:(User *)user managedObjectContext:(NSManagedObjectContext *)context;
+ (User *)currentUser;

@end
