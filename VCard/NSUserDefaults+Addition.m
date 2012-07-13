//
//  NSUserDefaults+Addition.m
//  VCard
//
//  Created by 王 紫川 on 12-7-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "NSUserDefaults+Addition.h"

#define kStoredCurrentUserID                @"StoredCurrentUserID"
#define kStoredUserAccountInfo              @"StoredUserAccountInfo"
#define kStoredUserAccountInfoUserID        @"kStoredUserAccountInfoUserID"
#define kStoredUserAccountInfoAccount       @"StoredUserAccountInfoAccount"
#define kStoredUserAccountInfoPassword      @"StoredUserAccountInfoPassword"
#define kStoredLoginUserArray               @"StoredLoginUserArray"

#define KeyForStoredUserAccountInfo(userID) ([NSString stringWithFormat:@"%@_%@", kStoredUserAccountInfo, (userID)])

@implementation NSUserDefaults (Addition)

+ (void)insertUserAccountInfoWithUserID:(NSString *)userID
                     account:(NSString *)account
                    password:(NSString *)password {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          account, kStoredUserAccountInfoAccount,
                          password, kStoredUserAccountInfoPassword,
                          userID, kStoredUserAccountInfoUserID, nil];
    [defaults setObject:info forKey:KeyForStoredUserAccountInfo(userID)];
    
    [defaults synchronize];
}

+ (UserAccountInfo *)getUserAccountInfoWithUserID:(NSString *)userID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [defaults objectForKey:KeyForStoredUserAccountInfo(userID)];
    UserAccountInfo *info = [[UserAccountInfo alloc] initWithInfoDict:infoDict];
    return info;
}

+ (void)setCurrentUserID:(NSString *)userID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userID forKey:kStoredCurrentUserID];
    [defaults synchronize];
}

+ (NSString *)getCurrentUserID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults stringForKey:kStoredCurrentUserID];
    return userID;
}

+ (NSArray *)getLoginUserArray {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *storedArray = [defaults arrayForKey:kStoredLoginUserArray];
    return storedArray;
}

+ (void)setLoginUserArray:(NSArray *)array {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:array forKey:kStoredLoginUserArray];
    [defaults synchronize];
}

@end

@implementation UserAccountInfo
        
@synthesize userID = _userID;
@synthesize account = _account;
@synthesize password = _password;

- (id)initWithInfoDict:(NSDictionary *)dict {
    self = [super init];
    if(self) {
        self.userID = [dict objectForKey:kStoredUserAccountInfoUserID];
        self.account = [dict objectForKey:kStoredUserAccountInfoAccount];
        self.password = [dict objectForKey:kStoredUserAccountInfoPassword];
    }
    return self;
}

@end
