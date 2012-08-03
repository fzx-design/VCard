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
#define kSettingEnableDateDisplay           @"SettingEnableDateDisplay"

#define kCurrentUserFavouriteIDs            @"kCurrentUserFavouriteIDs"
#define kCurrentGroupIndex                  @"kCurrentGroupIndex"
#define kCurrentGroupTitle                  @"kCurrentGroupTitle"

#define kVCard4_0_Initialized               @"VCard4_0_Initialized"

#define kSettingOptionFontSize              @"SettingOptionFontSize"
#define kSettingOptionNotification          @"SettingOptionNotification"
#define kSettingFontSize                    @"SettingFontSize"
#define kSettingLeading                     @"SettingLeading"

#define kHasShownGuideBook                  @"HasShownGuideBook"
#define kHasShownShelfTips                  @"HasShownShelfTips"
#define kHasShownStackTips                  @"HasShownStackTips"
#define kHasShown3GWarning                  @"kHasShown3GWarning"
#define kHasFetchedMessages                 @"kHasFetchedMessages"
#define kHasShownMessageList                @"kHasShownMessageList"

#define kShouldPostRecommendVCardWeibo      @"ShouldPostRecommendVCardWeibo"

#define kReloadingCardCell                  @"ReloadingCardCell"

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
        [defaults setBool:NO forKey:kSettingEnableRetinaDisplay];
        [defaults setBool:YES forKey:kSettingEnablePicture];
        [defaults setBool:NO forKey:kSettingEnableDateDisplay];
        [defaults setFloat:17.0 forKey:kSettingFontSize];
        [defaults setFloat:8.0 forKey:kSettingLeading];
        
        [defaults setInteger:0 forKey:kCurrentGroupIndex];
        [defaults setObject:@"" forKey:kCurrentGroupTitle];
        
        [defaults setObject:@[@(NO), @(YES), @(NO)] forKey:kSettingOptionFontSize];
        [defaults setObject:@[@(YES), @(YES), @(YES), @(YES)] forKey:kSettingOptionNotification];
        [defaults setObject:@[] forKey:kCurrentUserFavouriteIDs];
        
        [defaults setBool:NO forKey:kHasShownShelfTips];
        [defaults setBool:NO forKey:kHasShownStackTips];
        [defaults setBool:NO forKey:kHasShownGuideBook];
        [defaults setBool:NO forKey:kHasShown3GWarning];
        [defaults setBool:NO forKey:kHasFetchedMessages];
    }
    [defaults setBool:YES forKey:kVCard4_0_Initialized];
    [defaults synchronize];
    
    [NSUserDefaults setShownMessageList:NO];
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

+ (BOOL)shouldPostRecommendVCardWeibo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kShouldPostRecommendVCardWeibo];
}

+ (void)setShouldPostRecommendVCardWeibo:(BOOL)shouldPost {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:shouldPost forKey:kShouldPostRecommendVCardWeibo];
    [defaults synchronize];
}

+ (void)updateCurrentFontSize
{
    CGFloat fontSize = 0;
    SettingOptionFontSizeType type = [NSUserDefaults currentFontSizeType];
    if (type == SettingOptionFontSizeTypeSmall) {
        fontSize = (CGFloat)SettingOptionFontSizeSmall;
    } else if (type == SettingOptionFontSizeTypeNormal) {
        fontSize = (CGFloat)SettingOptionFontSizeNormal;
    } else if (type == SettingOptionFontSizeTypeBig){
        fontSize = (CGFloat)SettingOptionFontSizeBig;
    }
    [NSUserDefaults setCurrentFontSize:fontSize];
}

+ (void)setCurrentFontSize:(CGFloat)fontSize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    SettingOptionInfo *info = [NSUserDefaults getInfoForOptionKey:kSettingOptionFontSize];
    NSNumber *chosenStatus1 = [NSNumber numberWithBool:fontSize == (CGFloat)SettingOptionFontSizeSmall];
    NSNumber *chosenStatus2 = [NSNumber numberWithBool:fontSize == (CGFloat)SettingOptionFontSizeNormal];
    NSNumber *chosenStatus3 = [NSNumber numberWithBool:fontSize == (CGFloat)SettingOptionFontSizeBig];
    info.optionChosenStatusArray = @[chosenStatus1, chosenStatus2, chosenStatus3];
    [NSUserDefaults setSettingOptionInfo:info];
    
    if (fontSize == (CGFloat)SettingOptionFontSizeSmall) {
        [[NSUserDefaults standardUserDefaults] setFloat:6.0 forKey:kSettingLeading];
    } else if (fontSize == (CGFloat)SettingOptionFontSizeNormal) {
        [[NSUserDefaults standardUserDefaults] setFloat:8.0 forKey:kSettingLeading];
    } else {
        [[NSUserDefaults standardUserDefaults] setFloat:10.0 forKey:kSettingLeading];
    }
    
    [defaults setFloat:fontSize forKey:kSettingFontSize];
    [defaults synchronize];
}

+ (CGFloat)currentFontSize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults floatForKey:kSettingFontSize];
}

+ (CGFloat)currentLeading
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults floatForKey:kSettingLeading];
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

+ (BOOL)hasShown3GWarning {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kHasShown3GWarning];
}

+ (void)setShown3GWarning:(BOOL)hasShown {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:hasShown forKey:kHasShown3GWarning];
    [defaults synchronize];
}

+ (BOOL)hasFetchedMessages {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kHasFetchedMessages];
}

+ (void)setFetchedMessages:(BOOL)hasShown {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:hasShown forKey:kHasFetchedMessages];
    [defaults synchronize];
}

+ (BOOL)hasShownMessageList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kHasShownMessageList];
}

+ (void)setShownMessageList:(BOOL)hasShown
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:hasShown forKey:kHasShownMessageList];
    [defaults synchronize];
}

+ (void)setCurrentUserFavouriteIDs:(NSArray *)array
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:array forKey:kCurrentUserFavouriteIDs];
    [defaults synchronize];
}

+ (void)addFavouriteID:(NSString *)statusID
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[NSUserDefaults getCurrentUserFavouriteIDs]];
    [array addObject:statusID];
    [NSUserDefaults setCurrentUserFavouriteIDs:array];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeFavouriteID:(NSString *)statusID
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[NSUserDefaults getCurrentUserFavouriteIDs]];
    if ([array containsObject:statusID]) {
        [array removeObject:statusID];
        [NSUserDefaults setCurrentUserFavouriteIDs:array];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *)getCurrentUserFavouriteIDs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kCurrentUserFavouriteIDs];
}

+ (NSArray *)getCurrentNotificationStatus {
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
    [defaults setBool:enabled forKey:kSettingEnablePicture];
    [defaults synchronize];
}

+ (void)setAutoTrafficSavingEnabled:(BOOL)enabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enabled forKey:kSettingEnableAutoTrafficSaving];
    [defaults synchronize];
}

+ (BOOL)isRetinaDisplayEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingEnableRetinaDisplay];
}

+ (BOOL)isDateDisplayEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingEnableDateDisplay];
}

+ (void)insertUserAccountInfoWithUserID:(NSString *)userID
                     account:(NSString *)account
                    password:(NSString *)password {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *info = @{kStoredUserAccountInfoAccount: account,
                          kStoredUserAccountInfoPassword: password,
                          kStoredUserAccountInfoUserID: userID};
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

+ (void)setCurrentGroupTitle:(NSString *)groupTitle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:groupTitle forKey:kCurrentGroupTitle];
    [defaults synchronize];
}

+ (NSString *)getCurrentGroupTitle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults stringForKey:kCurrentGroupTitle];
    return userID;
}

+ (void)setCurrentGroupIndex:(int)groupIndex {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:groupIndex forKey:kCurrentGroupIndex];
    [defaults synchronize];
}

+ (int)getCurrentGroupIndex {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int currentGroupIndex = [defaults integerForKey:kCurrentGroupIndex];
    return currentGroupIndex;
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

+ (BOOL)isReloaingCardCell {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kReloadingCardCell];
}

+ (void)setReloadingCardCellStatus:(BOOL)reloading {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:reloading forKey:kReloadingCardCell];
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
            self.optionsArray = @[@"小", @"正常", @"大"];
            self.optionName = @"字体大小";
        } else if([optionKey isEqualToString:kSettingOptionNotification]) {
            self.allowMultiOptions = YES;
            self.optionsArray = @[@"新评论", @"新粉丝", @"提到我的", @"新私信"];
            self.optionName = @"消息提示";
        }
        self.optionKey = optionKey;
    }
    return self;
}

@end
