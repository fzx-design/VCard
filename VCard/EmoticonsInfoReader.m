//
//  EmoticonsInfoReader.m
//  VCard
//
//  Created by 紫川 王 on 12-6-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "EmoticonsInfoReader.h"

static EmoticonsInfoReader *readerInstance;

#define kEmoticonsInfoHasInitiated  @"EmoticonsInfoHasInitiated"
#define kEmoticonsInfoDict  @"EmoticonsInfoDict"
#define kImageFileName  @"ImageName"
#define kPriorityLevel  @"PriorityLevel"

#define MAX_EMOTICONS_PRIORITY_LEVEL        1000000
#define EMOTICONS_PRIORITY_LEVEL_INTERVAL   100
#define EMOTICONS_COUNT                     104

@interface EmoticonsInfoReader()

@property (nonatomic, strong) NSMutableDictionary *originEmoticonsInfoDict;
@property (nonatomic, strong) NSMutableDictionary *emoticonsInfoDict;

@end

@implementation EmoticonsInfoReader

@synthesize emoticonsInfoDict = _emoticonsInfoDict;
@synthesize originEmoticonsInfoDict = _originEmoticonsInfoDict;

+ (EmoticonsInfoReader *)sharedReader {
    if(!readerInstance) {
        readerInstance = [[EmoticonsInfoReader alloc] init];
    }
    return readerInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        //[self readPlist];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dict = [defaults dictionaryForKey:kEmoticonsInfoDict];
        if(dict) {
            self.originEmoticonsInfoDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [self generateEmoticonsInfoDict];
        }
        else 
            [self readPlist];
    }
    return self;
}

- (void)generateEmoticonsInfoDict {
    self.emoticonsInfoDict = [NSMutableDictionary dictionaryWithCapacity:self.originEmoticonsInfoDict.count];
    [self.originEmoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        EmoticonsInfo *info = [[EmoticonsInfo alloc] initWithDict:obj andKey:key];
        [self.emoticonsInfoDict setObject:info forKey:key];
    }];
}

- (void)readPlist {
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"EmoticonsInfo" ofType:@"plist"];  
    self.originEmoticonsInfoDict = [[[NSMutableDictionary alloc] initWithContentsOfFile:configFilePath] objectForKey:kEmoticonsInfoDict];
    
    self.emoticonsInfoDict = [NSMutableDictionary dictionaryWithCapacity:self.originEmoticonsInfoDict.count];
    [self.originEmoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        EmoticonsInfo *info = [[EmoticonsInfo alloc] initWithDict:obj andKey:key];
        info.priorityLevel = EMOTICONS_COUNT - info.priorityLevel;
        [self.emoticonsInfoDict setObject:info forKey:key];
    }];
    
    [self.emoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        EmoticonsInfo *info = obj;
        NSMutableDictionary *originInfo = [NSMutableDictionary dictionaryWithDictionary:[self.originEmoticonsInfoDict objectForKey:key]];
        [originInfo setObject:[NSNumber numberWithInteger:info.priorityLevel] forKey:kPriorityLevel];
        [self.originEmoticonsInfoDict setObject:originInfo forKey:key];
    }];
    
    [self userDefaultsSynchronize];
}

- (void)userDefaultsSynchronize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.originEmoticonsInfoDict forKey:kEmoticonsInfoDict];
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
    NSMutableDictionary *originInfo = [NSMutableDictionary dictionaryWithDictionary:[self.originEmoticonsInfoDict objectForKey:key]];
    [originInfo setObject:[NSNumber numberWithInteger:info.priorityLevel] forKey:kPriorityLevel];
    [self.originEmoticonsInfoDict setObject:originInfo forKey:key];
    
    NSLog(@"key:%@, priority level:%d", key, info.priorityLevel);
    
    if(info.priorityLevel > MAX_EMOTICONS_PRIORITY_LEVEL) {
        [self.emoticonsInfoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            EmoticonsInfo *item = obj;
            item.priorityLevel = item.priorityLevel / 2;
            
            NSMutableDictionary *originInfo = [NSMutableDictionary dictionaryWithDictionary:[self.originEmoticonsInfoDict objectForKey:key]];
            [originInfo setObject:[NSNumber numberWithInteger:item.priorityLevel] forKey:kPriorityLevel];
            [self.originEmoticonsInfoDict setObject:originInfo forKey:key];
        }];
    }
}

@end

@implementation EmoticonsInfo

@synthesize imageFileName = _imageFileName;
@synthesize priorityLevel = _priorityLevel;
@synthesize keyName = _keyName;

- (id)initWithDict:(NSDictionary *)dict andKey:(NSString *)key {
    self = [super init];
    if(self) {
        self.keyName = key;
        self.imageFileName = [dict objectForKey:kImageFileName];
        NSNumber *level = [dict objectForKey:kPriorityLevel];
        self.priorityLevel = level.integerValue;
    }
    return self;
}

@end
