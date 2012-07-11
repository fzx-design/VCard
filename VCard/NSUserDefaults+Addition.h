//
//  NSUserDefaults+Addition.h
//  VCard
//
//  Created by 王 紫川 on 12-7-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserAccountInfo;

@interface NSUserDefaults (Addition)

+ (void)insertUserAccountInfoWithUserID:(NSString *)userID
                                account:(NSString *)account
                               password:(NSString *)password;

+ (UserAccountInfo *)getUserAccountInfoWithUserID:(NSString *)userID;
+ (void)setCurrentUserID:(NSString *)userID;
+ (NSString *)getCurrentUserID;

+ (NSArray *)getLoginUserArray;
+ (void)setLoginUserArray:(NSArray *)array;

@end

@interface UserAccountInfo : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;

- (id)initWithInfoDict:(NSDictionary *)dict;

@end
