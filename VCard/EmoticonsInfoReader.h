//
//  EmoticonsInfoReader.h
//  VCard
//
//  Created by 紫川 王 on 12-6-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EmoticonsInfo;

@interface EmoticonsInfoReader : NSObject

+ (EmoticonsInfoReader *)sharedReader;
- (EmoticonsInfo *)emoticonsInfoForKey:(NSString *)key;
- (NSArray *)emoticonsInfoArray;
- (void)addEmoticonsPriorityLevelForKey:(NSString *)key;

@end

@interface EmoticonsInfo : NSObject 

@property (nonatomic, strong) NSString *keyName;
@property (nonatomic, strong) NSString *imageFileName;
@property (nonatomic, assign) NSNumber *priorityLevel;

- (id)initWithDict:(NSDictionary *)dict andKey:(NSString *)key;

@end