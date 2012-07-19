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
#define kStoredUserAccountInfoUserID        @"StoredUserAccountInfoUserID"
#define kStoredUserAccountInfoAccount       @"StoredUserAccountInfoAccount"
#define kStoredUserAccountInfoPassword      @"StoredUserAccountInfoPassword"
#define kStoredLoginUserArray               @"StoredLoginUserArray"

#define kSettingEnableAutoTrafficSaving     @"SettingEnableAutoTrafficSaving"
#define kSettingEnableAutoLocate            @"SettingEnableAutoLocate"
#define kSettingEnableSoundEffect           @"SettingEnableSoundEffect"
#define kSettingEnableRetinaDisplay         @"SettingEnableRetinaDisplay"
#define kSettingEnablePicture               @"SettingEnablePicture"

#define kVCard4_0_Initialized               @"VCard4_0_Initialized"

#define kSettingOptionFontSize              @"SettingOptionFontSize"
#define kSettingOptionNotification          @"SettingOptionNotification"

#define kHasShownGuideBook                  @"HasShownGuideBook"
#define kHasShownShelfTips                  @"kHasShownShelfTips"
#define kHasShownStackTips                  @"kHasShownStackTips"

#define KeyForStoredUserAccountInfo(userID) ([NSString stringWithFormat:@"%@_%@", kStoredUserAccountInfo, (userID)])

@implementation NSUserDefaults (Addition)

+ (void)initialize {
    [NSUserDefaults initializeVCard_4_0];
}

+ (void)initializeVCard_4_0 {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:kVCard4_0_Initialized]) {
        NSLog(@"init vcard 4.0");
        [defaults setBool:NO forKey:kSettingEnableAutoTrafficSaving];
        [defaults setBool:NO forKey:kSettingEnableAutoLocate];
        [defaults setBool:YES forKey:kSettingEnableSoundEffect];
        [defaults setBool:YES forKey:kSettingEnableRetinaDisplay];
        [defaults setBool:YES forKey:kSettingEnablePicture];
        
        [defaults setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], nil] forKey:kSettingOptionFontSize];
        [defaults setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], nil] forKey:kSettingOptionNotification];
        
        [defaults setBool:NO forKey:kHasShownShelfTips];
        [defaults setBool:NO forKey:kHasShownStackTips];
        [defaults setBool:NO forKey:kHasShownGuideBook];
    }
    [defaults setBool:YES forKey:kVCard4_0_Initialized];
    [defaults synchronize];
}

+ (SettingOptionFontSizeType)currentFontSizeType {
    SettingOptionInfo *info = [NSUserDefaults getInfoForOptionKey:kSettingOptionFontSize];
    __block SettingOptionFontSizeType result;
    [info.optionChosenStatusArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *chosenNumber = obj;
        if(chosenNumber.boolValue) {
            result = idx;
            *stop = YES;
        }
    }];
    return result;
}

+ (BOOL)hasShownShelfTips {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kHasShownShelfTips];
}

+ (void)setShownShelfTips:(BOOL)hasShown {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:hasShown forKey:kHasShownShelfTips];
    [defaults synchronize];
}

+ (BOOL)hasShownStackTips {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kHasShownStackTips];
}

+ (void)setShownStackTips:(BOOL)hasShown {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:hasShown forKey:kHasShownStackTips];
    [defaults synchronize];
}

+ (BOOL)hasShownGuideBook {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kHasShownGuideBook];
}

+ (void)setShownGuideBook:(BOOL)hasShown {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:hasShown forKey:kHasShownGuideBook];
    [defaults synchronize];
}

+ (NSArray *)currentNotificationStatus {
    SettingOptionInfo *info = [NSUserDefaults getInfoForOptionKey:kSettingOptionNotification];
    return info.optionChosenStatusArray;
}

+ (SettingOptionInfo *)getInfoForOptionKey:(NSString *)optionKey {
    SettingOptionInfo *result = [[SettingOptionInfo alloc] initWithOptionKey:optionKey];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    result.optionChosenStatusArray = [defaults arrayForKey:optionKey];
    return result;
}

+ (void)setSettingOptionInfo:(SettingOptionInfo *)info {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:info.optionChosenStatusArray forKey:info.optionKey];
    [defaults synchronize];
}

+ (BOOL)isAutoTrafficSavingEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingEnableAutoTrafficSaving];
}

+ (BOOL)isAutoLocateEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingEnableAutoLocate];
}

+ (BOOL)isSoundEffectEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingEnableSoundEffect];
}

+ (BOOL)isPictureEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingEnablePicture];
}

+ (void)setPictureEnabled:(BOOL)enabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:enabled] forKey:kSettingEnablePicture];
}

+ (BOOL)isRetinaDisplayEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingEnableRetinaDisplay];
}

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

@implementation SettingOptionInfo

@synthesize optionKey = _optionKey;
@synthesize optionsArray = _optionsArray;
@synthesize optionChosenStatusArray = _chosenOptionIndexesArray;
@synthesize optionName = _optionName;
@synthesize allowMultiOptions = _allowMultiOptions;

- (id)initWithOptionKey:(NSString *)optionKey {
    self = [super init];
    if(self) {
        if([optionKey isEqualToString:kSettingOptionFontSize]) {
            self.optionsArray = [NSArray arrayWithObjects:@"小", @"正常", @"大", nil];
            self.optionName = @"字体大小";
        } else if([optionKey isEqualToString:kSettingOptionNotification]) {
            self.allowMultiOptions = YES;
            self.optionsArray = [NSArray arrayWithObjects:@"新评论", @"新粉丝", @"提到我的", @"新私信", nil];
            self.optionName = @"消息提示";
        }
        self.optionKey = optionKey;
    }
    return self;
}

@end
