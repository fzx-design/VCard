//
//  Group.h
//  VCard
//
//  Created by 海山 叶 on 12-7-15.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kGroupTypeFavourite 0
#define kGroupTypeGroup     1
#define kGroupTypeTopic     2

#define kGroupIDDefault     @"kGroupIDDefault"
#define kGroupIDFavourite   @"kGroupIDFavourite"

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * groupID;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * picURL;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * groupUserID;
@property (nonatomic, retain) NSNumber * count;

+ (Group *)insertGroupInfo:(NSDictionary *)dict userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Group *)insertTopicInfo:(NSDictionary *)dict userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Group *)insertTopicWithName:(NSString *)name userID:(NSString *)userID andID:(NSString *)trendID inManangedObjectContext:(NSManagedObjectContext *)context;
+ (Group *)groupWithName:(NSString *)name userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteGroupWithGroupID:(NSString *)groupID userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)setUpDefaultGroupWithUserID:(NSString *)userID defaultImageURL:(NSString *)defaultImageURL inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Group *)setUpDefaultGroupImageWithDefaultURL:(NSString *)defaultURL UserID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context;

@end
