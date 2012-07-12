//
//  EmoticonsInfoReader.m
//  VCard
//
//  Created by 紫川 王 on 12-6-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "EmoticonsInfoReader.h"

static EmoticonsInfoReader *readerInstance;

#define kEmoticonsInfoStoredPriorityDict    @"EmoticonsInfoStoredPriorityDict"
#define kImageFileName                      @"ImageName"
#define kPriorityLevel                      @"PriorityLevel"
#define kInitPriorityLevel                  @"InitPriorityLevel"
#define kEmoticonsInfoDict                  @"EmoticonsInfoDict"

#define MAX_EMOTICONS_PRIORITY_LEVEL        1000000
#define EMOTICONS_PRIORITY_LEVEL_INTERVAL   100

@interface EmoticonsInfoReader()

@property (nonatomic, strong) NSMutableDictionary *originalEmoticonsInfoDict;
@property (nonatomic, strong) NSMutableDictionary *emoticonsInfoDict;

@end

@implementation EmoticonsInfoReader

@synthesize emoticonsInfoDict = _emoticonsInfoDict;
@synthesize originalEmoticonsInfoDict = _originalEmoticonsInfoDict;

+ (EmoticonsInfoReader *)sharedReader {
    if(!readerInstance) {
        readerInstance = [[EmoticonsInfoReader alloc] init];
    }
    return readerInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        [self readPlist];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dict = [defaults dictionaryForKey:kEmoticonsInfoStoredPriorityDict];
        if(dict) {
            [self configureStoredPriorityLevel:dict];
        }
    }
    return self;
}

- (void)configureStoredPriorityLevel:(NSDictionary *)dict {
    [self.emoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        EmoticonsInfo *info = obj;
        NSNumber *storedPriorityLevel = [dict objectForKey:info.keyName];
        info.priorityLevel = storedPriorityLevel ? storedPriorityLevel.integerValue : info.priorityLevel;
    }];
}

- (void)readPlist {
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"EmoticonsInfo" ofType:@"plist"];  
    self.originalEmoticonsInfoDict = [[[NSMutableDictionary alloc] initWithContentsOfFile:configFilePath] objectForKey:kEmoticonsInfoDict];
    
    self.emoticonsInfoDict = [NSMutableDictionary dictionaryWithCapacity:self.originalEmoticonsInfoDict.count];
    [self.originalEmoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        EmoticonsInfo *info = [[EmoticonsInfo alloc] initWithDict:obj andKey:key];
        info.priorityLevel = self.originalEmoticonsInfoDict.count - info.priorityLevel;
        [self.emoticonsInfoDict setObject:info forKey:key];
    }];
}

- (NSDictionary *)generateStorePriorityLevelDict {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self.emoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        EmoticonsInfo *info = obj;
        [result setObject:[NSNumber numberWithInteger:info.priorityLevel] forKey:info.keyName];
    }];
    return result;
}

- (void)storePriorityLevel {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [self generateStorePriorityLevelDict];
    [defaults setObject:dict forKey:kEmoticonsInfoStoredPriorityDict];
    [defaults synchronize];
}

- (EmoticonsInfo *)emoticonsInfoForKey:(NSString *)key {
    return [self.emoticonsInfoDict objectForKey:key];
}

- (NSArray *)emoticonsInfoArray {
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.emoticonsInfoDict.count];
    [self.emoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [array addObject:obj];
    }];
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EmoticonsInfo *info1 = (EmoticonsInfo *)obj1;
        EmoticonsInfo *info2 = (EmoticonsInfo *)obj2;
        return info2.priorityLevel - info1.priorityLevel;
    }];
    return array;
}

- (void)addEmoticonsPriorityLevelForKey:(NSString *)key {
    EmoticonsInfo *info = [self.emoticonsInfoDict objectForKey:key];
    info.priorityLevel = info.priorityLevel + EMOTICONS_PRIORITY_LEVEL_INTERVAL;
    [self.emoticonsInfoDict setObject:info forKey:key];
    
    NSLog(@"key:%@, priority level:%d", key, info.priorityLevel);
    
    if(info.priorityLevel > MAX_EMOTICONS_PRIORITY_LEVEL) {
        [self.emoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            EmoticonsInfo *item = obj;
            item.priorityLevel = item.priorityLevel / 2;
        }];
    }
    
    [self storePriorityLevel];
}

@end

@implementation EmoticonsInfo

@synthesize imageFileName = _imageFileName;
@synthesize priorityLevel = _priorityLevel;
@synthesize keyName = _keyName;
@synthesize emoticonIdentifier = _emoticonIdentifier;

- (id)initWithDict:(NSDictionary *)dict andKey:(NSString *)key {
    self = [super init];
    if(self) {
        self.keyName = key;
        
        self.imageFileName = [dict objectForKey:kImageFileName];
        NSNumber *level = [dict objectForKey:kPriorityLevel];
        self.priorityLevel = level.integerValue;
        
        NSNumber *initLevel = [dict objectForKey:kInitPriorityLevel];
        initLevel = initLevel ? initLevel : level;
        self.emoticonIdentifier = [NSString stringWithFormat:@"[%x]", self.priorityLevel];        
    }
    return self;
}

@end
