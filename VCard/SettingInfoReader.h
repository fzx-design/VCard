//
//  SettingInfoReader.h
//  WeTongji
//
//  Created by 紫川 王 on 12-5-6.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPushNavigationController   @"kPushNavigationController"
#define kModalViewController        @"kModalViewController"
#define kUseSelector                @"kUseSelector"
#define kUseSelectorWithObject      @"kUseSelectorWithObject"
#define kPushOptionViewController   @"kPushOptionViewController"

#define kAccessoryTypeNone          @"kAccessoryTypeNone"
#define kAccessoryTypeSwitch        @"kAccessoryTypeSwitch"
#define kAccessoryTypeDisclosure    @"kAccessoryTypeDisclosure"
#define kAccessoryTypeWatchButton   @"kAccessoryTypeWatchButton"

@interface SettingInfoReader : NSObject

+ (SettingInfoReader *)sharedReader;

- (NSArray *)getSettingInfoSectionArray;
- (NSArray *)getSettingAppInfoSectionArray;
- (NSArray *)getTeamMemberIDArray;

@end

@interface SettingInfoSection : NSObject

@property (nonatomic, strong) NSString *sectionIdentifier;
@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, strong) NSString *sectionHeader;
@property (nonatomic, strong) NSString *sectionFooter;

- (id)initWithDict:(NSDictionary *)dict;

@end

@interface SettingInfo : NSObject

@property (nonatomic, strong) NSString *itemTitle;
@property (nonatomic, strong) NSString *itemContent;
@property (nonatomic, strong) NSString *nibFileName;
@property (nonatomic, strong) NSString *imageFileName;
@property (nonatomic, strong) NSString *accessoryType;
@property (nonatomic, strong) NSString *wayToPresentViewController;
@property (nonatomic, strong) NSString *notificaitonName;

- (id)initWithInfoDict:(NSDictionary *)infoDict;

@end
