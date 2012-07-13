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
#define kSectionName                    @"kSectionName"
#define kSectionArray                   @"kSectionArray"

#define kWayToPresentViewController     @"kWayToPresentViewController"
#define kNibFileName                    @"kNibFileName"
#define kAccessoryType                  @"kAccessoryType"
#define kItemTitle                      @"kItemTitle"
#define kItemContent                    @"kItemContent"
#define kItemImageFileName              @"kItemImageFileName"

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
        SettingInfoSection *section = [[SettingInfoSection alloc] init];
        section.sectionTitle = [sectionDict objectForKey:kSectionName];
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

@end

@implementation SettingInfoSection

@synthesize sectionTitle = _sectionTitle;
@synthesize itemArray = _itemArray;

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
    }
    return self;
}

@end
