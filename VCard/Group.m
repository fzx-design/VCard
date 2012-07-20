//
//  Group.m
//  VCard
//
//  Created by 海山 叶 on 12-7-15.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Group.h"

@implementation Group

@dynamic groupID;
@dynamic index;
@dynamic name;
@dynamic picURL;
@dynamic type;
@dynamic groupUserID;
@dynamic count;

+ (Group *)groupWithID:(NSString *)groupID userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"groupID == %@", groupID]];
    
    Group *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
}

+ (Group *)groupWithName:(NSString *)name userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@ && type == %@", name, [NSNumber numberWithInt:2]]];
    
    Group *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
}

+ (Group *)insertGroupInfo:(NSDictionary *)dict userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *groupID = [dict objectForKey:@"idstr"];
    
    if (!groupID || [groupID isEqualToString:@""]) {
        return nil;
    }
    
    Group *result = [Group groupWithID:groupID userID:userID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    }
    
    result.groupID = groupID;
    NSString *url = [dict objectForKey:@"profile_image_url"];
    result.picURL = [url stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"];
    result.name = [dict objectForKey:@"name"];
    result.type = [NSNumber numberWithInt:kGroupTypeGroup];
    result.count = [NSNumber numberWithInt:[[dict objectForKey:@"member_count"] intValue]];
    result.index = [NSNumber numberWithInt:10];
    result.groupUserID = userID;
    
    return result;
}

+ (Group *)insertTopicInfo:(NSDictionary *)dict userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *groupID = [dict objectForKey:@"trend_id"];
    
    if (!groupID || [groupID isEqualToString:@""]) {
        return nil;
    }
    
    Group *result = [Group groupWithID:groupID userID:userID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    }
    result.groupID = groupID;
    result.name = [dict objectForKey:@"hotword"];
    result.type = [NSNumber numberWithInt:kGroupTypeTopic];
    result.count = [NSNumber numberWithInt:100];
    result.index = [NSNumber numberWithInt:100];
    result.groupUserID = userID;
    
    return result;
}

+ (Group *)insertTopicWithName:(NSString *)name userID:(NSString *)userID andID:(NSString *)trendID inManangedObjectContext:(NSManagedObjectContext *)context
{
    if (!trendID || [trendID isEqualToString:@""]) {
        return nil;
    }
    
    Group *result = [Group groupWithID:trendID userID:userID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    }
    result.groupID = trendID;
    result.name = name;
    result.type = [NSNumber numberWithInt:kGroupTypeTopic];
    result.groupUserID = userID;
    result.count = [NSNumber numberWithInt:100];
    
    return result;
}

+ (void)deleteGroupWithGroupID:(NSString *)groupID userID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"groupID == %@ && groupUserID == %@", groupID, userID]];
    
    [context deleteObject:[[context executeFetchRequest:request error:NULL] lastObject]];
}

+ (BOOL)checkUserDefaultGroup:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"groupUserID == %@ && groupID == %@", userID, kGroupIDDefault]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items.count == 0;
}

+ (void)setUpDefaultGroupWithUserID:(NSString *)userID defaultImageURL:(NSString *)defaultImageURL inManagedObjectContext:(NSManagedObjectContext *)context
{
    if ([Group checkUserDefaultGroup:userID inManagedObjectContext:context]) {
        Group *defaultGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
        defaultGroup.groupID = kGroupIDDefault;
        defaultGroup.groupUserID = userID;
        defaultGroup.name = @"全部关注";
        defaultGroup.type = [NSNumber numberWithInt:kGroupTypeDefault];
        defaultGroup.count = [NSNumber numberWithInt:100];
        defaultGroup.index = [NSNumber numberWithInt:0];
        defaultGroup.picURL = defaultImageURL;
        
        Group *favourite = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
        favourite.groupID = kGroupIDFavourite;
        favourite.groupUserID = userID;
        favourite.name = @"收藏";
        favourite.type = [NSNumber numberWithInt:kGroupTypeFavourite];
        favourite.count = [NSNumber numberWithInt:100];
        favourite.index = [NSNumber numberWithInt:1];
        favourite.picURL = defaultImageURL;
    }
}

+ (void)deleteAllGroupsOfType:(int)type OfUser:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"type == %@ && groupUserID == %@", [NSNumber numberWithInt:type], userID]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (Group *)setUpDefaultGroupImageWithDefaultURL:(NSString *)defaultURL UserID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    Group *group = [Group groupWithID:kGroupIDDefault userID:userID inManagedObjectContext:context];
    group.picURL = defaultURL;
    return group;
}

@end
