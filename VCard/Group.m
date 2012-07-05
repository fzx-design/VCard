//
//  Group.m
//  VCard
//
//  Created by 海山 叶 on 12-7-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Group.h"

@implementation Group

@dynamic name;
@dynamic picURL;
@dynamic groupID;
@dynamic type;
@dynamic index;

+ (Group *)groupWithID:(NSString *)groupID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Group" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"groupID == %@", groupID]];
    
    Group *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
}

+ (Group *)insertGroupInfo:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *groupID = [dict objectForKey:@"idstr"];
    
    if (!groupID || [groupID isEqualToString:@""]) {
        return nil;
    }
    
    Group *result = [Group groupWithID:groupID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    }
    
    result.groupID = groupID;
    NSString *url = [dict objectForKey:@"profile_image_url"];
    result.picURL = [url stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"];
    result.name = [dict objectForKey:@"name"];
    result.type = [NSNumber numberWithInt:kGroupTypeGroup];
    
    return result;
}

+ (Group *)insertTopicInfo:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *groupID = [dict objectForKey:@"hotword"];
    
    if (!groupID || [groupID isEqualToString:@""]) {
        return nil;
    }
    
    Group *result = [Group groupWithID:groupID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    }
    result.groupID = groupID;
    result.name = [dict objectForKey:@"hotword"];
    result.type = [NSNumber numberWithInt:kGroupTypeTopic];
    
    return result;
}

@end
