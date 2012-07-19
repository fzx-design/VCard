//
//  SettingInfoReader.m
//  WeTongji
//
//  Created by 紫川 王 on 12-5-6.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "SettingInfoReader.h"

static SettingInfoReader *readerInstance;

#define kSettingInfoSectionArray        @"kSettingInfoSectionArray"
#define kSettingAppInfoSectionArray     @"kSettingAppInfoSectionArray"
#define kSectionHeader                  @"kSectionHeader"
#define kSectionFooter                  @"kSectionFooter"
#define kSectionIdentifier              @"kSectionIdentifier"
#define kSectionArray                   @"kSectionArray"

#define kWayToPresentViewController     @"kWayToPresentViewController"
#define kNibFileName                    @"kNibFileName"
#define kAccessoryType                  @"kAccessoryType"
#define kItemTitle                      @"kItemTitle"
#define kItemContent                    @"kItemContent"
#define kItemImageFileName              @"kItemImageFileName"
#define kNotificationName               @"kNotificationName"

@interface SettingInfoReader()

@property (nonatomic, strong) NSDictionary *settingInfoMap;

@end

@implementation SettingInfoReader

@synthesize settingInfoMap = _settingInfoMap;

+ (SettingInfoReader *)sharedReader {
    if(!readerInstance) {
        readerInstance = [[SettingInfoReader alloc] init];
    }
    return readerInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        [self readPlist];
    }
    return self;
}

- (void)readPlist {
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"SettingInfo" ofType:@"plist"];  
    self.settingInfoMap = [[NSDictionary alloc] initWithContentsOfFile:configFilePath]; 
}

- (NSArray *)getInfoSectionArrayForKey:(NSString *)sectionArrayKey {
    NSArray *sectonArray = [NSArray arrayWithArray:[self.settingInfoMap objectForKey:sectionArrayKey]];
    NSMutableArray *result = [NSMutableArray array];
    for(NSDictionary *sectionDict in sectonArray) {
        SettingInfoSection *section = [[SettingInfoSection alloc] initWithDict:sectionDict];
        NSArray *infoArray = [sectionDict objectForKey:kSectionArray];
        NSMutableArray *parsedInfoArray = [NSMutableArray arrayWithCapacity:4];
        for(NSDictionary *infoDict in infoArray) {
            SettingInfo *info = [[SettingInfo alloc] initWithInfoDict:infoDict];
            [parsedInfoArray addObject:info];
        }
        section.itemArray = parsedInfoArray;
        [result addObject:section];
    }
    return result;
}

- (NSArray *)getSettingAppInfoSectionArray {
    return [self getInfoSectionArrayForKey:kSettingAppInfoSectionArray];
}

- (NSArray *)getSettingInfoSectionArray {
    return [self getInfoSectionArrayForKey:kSettingInfoSectionArray];
}

- (NSArray *)getTeamMemberIDArray {
    NSArray *appInfoArray = [self getSettingAppInfoSectionArray];
    SettingInfoSection *teamMemberSection = [appInfoArray lastObject];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:5];
    for(SettingInfo *info in teamMemberSection.itemArray) {
        [result addObject:info.nibFileName];
    }
    return result;
}

@end

@implementation SettingInfoSection

@synthesize sectionIdentifier = _sectionTitle;
@synthesize itemArray = _itemArray;
@synthesize sectionHeader = _sectionHeader;
@synthesize sectionFooter = _sectionFooter;

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if(self) {
        self.sectionIdentifier = [dict objectForKey:kSectionIdentifier];
        self.sectionHeader = [dict objectForKey:kSectionHeader];
        self.sectionFooter = [dict objectForKey:kSectionFooter];
        self.sectionFooter = [self.sectionFooter stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    return self;
}

@end

@implementation SettingInfo

@synthesize itemTitle = _itemTitle;
@synthesize nibFileName = _nibFileName;
@synthesize imageFileName = _imageFileName;
@synthesize wayToPresentViewController = _wayToPresentViewController;
@synthesize accessoryType = _accessoryType;

- (id)initWithInfoDict:(NSDictionary *)infoDict {
    self = [super init];
    if(self) {
        self.itemTitle = [infoDict objectForKey:kItemTitle];
        self.itemContent = [infoDict objectForKey:kItemContent];
        self.nibFileName = [infoDict objectForKey:kNibFileName];
        self.imageFileName = [infoDict objectForKey:kItemImageFileName];
        self.accessoryType = [infoDict objectForKey:kAccessoryType];
        self.wayToPresentViewController = [infoDict objectForKey:kWayToPresentViewController];
        self.notificaitonName = [infoDict objectForKey:kNotificationName];
    }
    return self;
}

@end
