//
//  NSUserDefaults+Addition.h
//  VCard
//
//  Created by 王 紫川 on 12-7-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserAccountInfo;
@class SettingOptionInfo;

@interface NSUserDefaults (Addition)

+ (void)insertUserAccountInfoWithUserID:(NSString *)userID
                                account:(NSString *)account
                               password:(NSString *)password;

+ (UserAccountInfo *)getUserAccountInfoWithUserID:(NSString *)userID;
+ (void)setCurrentUserID:(NSString *)userID;
+ (NSString *)getCurrentUserID;

+ (NSArray *)getLoginUserArray;
+ (void)setLoginUserArray:(NSArray *)array;

+ (BOOL)isAutoTrafficSavingEnabled;
+ (BOOL)isAutoLocateEnabled;
+ (BOOL)isSoundEffectEnabled;
+ (BOOL)isPictureEnabled;
+ (BOOL)isRetinaDisplayEnabled;

+ (SettingOptionInfo *)getInfoForOptionKey:(NSString *)optionKey;

@end

@interface UserAccountInfo : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;

- (id)initWithInfoDict:(NSDictionary *)dict;

@end

@interface SettingOptionInfo : NSObject

@property (nonatomic, strong) NSArray *optionsArray;
@property (nonatomic, strong) NSArray *optionChosenStatusArray;
@property (nonatomic, strong) NSString *optionKey;
@property (nonatomic, strong) NSString *optionName;
@property (nonatomic, assign) BOOL allowMultiOptions;

- (id)initWithOptionKey:(NSString *)optionKey;

@end
