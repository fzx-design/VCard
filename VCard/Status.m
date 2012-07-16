//
//  Status.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Status.h"
#import "Comment.h"
#import "Status.h"
#import "User.h"
#import "NSDateAddition.h"

@implementation Status

@dynamic bmiddlePicURL;
@dynamic cardSizeCardHeight;
@dynamic cardSizeImageHeight;
@dynamic commentsCount;
@dynamic createdAt;
@dynamic favorited;
@dynamic featureMusic;
@dynamic featureOrigin;
@dynamic featurePic;
@dynamic featureVideo;
@dynamic forCastView;
@dynamic forTableView;
@dynamic isMentioned;
@dynamic lat;
@dynamic location;
@dynamic lon;
@dynamic operatable;
@dynamic operatedBy;
@dynamic originalPicURL;
@dynamic repostsCount;
@dynamic searchString;
@dynamic source;
@dynamic statusID;
@dynamic text;
@dynamic thumbnailPicURL;
@dynamic updateDate;
@dynamic searchKey;
@dynamic author;
@dynamic comments;
@dynamic favoritedBy;
@dynamic isFriendsStatusOf;
@dynamic repostedBy;
@dynamic repostStatus;

- (BOOL)isEqualToStatus:(Status *)status
{
    return [self.statusID isEqualToString:status.statusID];
}

+ (Status *)statusWithID:(NSString *)statudID inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"statusID == %@ && operatedBy == %@", statudID, object]];
    
    Status *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
}

+ (int)countOfStatuseInContext:(NSManagedObjectContext *)context

{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [context countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
    }
    
    return count;
}

+ (Status *)insertStatus:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{    
    NSString *statusID = [[dict objectForKey:@"id"] stringValue];
    
    if (!statusID || [statusID isEqualToString:kCoreDataIdentifierDefault]) {
        return nil;
    }
    
    Status *result = [Status statusWithID:statusID inManagedObjectContext:context withOperatingObject:object];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:context];
    }
    
    result.updateDate = [NSDate date];
    
    result.statusID = statusID;
    result.operatable = [NSNumber numberWithBool:![(NSString *)object isEqualToString:kCoreDataIdentifierDefault]];
    result.operatedBy = object;
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.text = [dict objectForKey:@"text"];
    
    result.source = [dict objectForKey:@"source"];
    
    result.favorited = [NSNumber numberWithBool:[[dict objectForKey:@"favorited"] boolValue]];
    
    NSInteger commentsCount = [[dict objectForKey:@"comments_count"] intValue];
    if (result.commentsCount.intValue < commentsCount) {
        result.commentsCount = [NSString stringWithFormat:@"%i",commentsCount];
    }
    NSInteger repostsCount = [[dict objectForKey:@"reposts_count"] intValue];
    if (result.repostsCount.intValue < repostsCount) {
        result.repostsCount = [NSString stringWithFormat:@"%i",repostsCount];
    }
    
    result.thumbnailPicURL = [dict objectForKey:@"thumbnail_pic"];
    result.bmiddlePicURL = [dict objectForKey:@"bmiddle_pic"];
    result.originalPicURL = [dict objectForKey:@"original_pic"];
    
    NSDictionary* geoDic = (NSDictionary*)[dict objectForKey:@"geo"];
    if (geoDic && ![[geoDic class] isSubclassOfClass:[NSNull class]]) {
        result.lat = [[NSNumber alloc] initWithFloat:[[(NSArray*)([geoDic objectForKey:@"coordinates"]) objectAtIndex:0] floatValue]];
        result.lon = [[NSNumber alloc] initWithFloat:[[(NSArray*)([geoDic objectForKey:@"coordinates"]) objectAtIndex:1] floatValue]];
    }
    else {
        result.lat = 0;
        result.lon = 0;
    }
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    
    if ([userDict isKindOfClass:[NSDictionary class]] && userDict > 0) {
        result.author = [User insertUser:userDict inManagedObjectContext:context withOperatingObject:object];
    }
    
    NSDictionary* repostedStatusDict = [dict objectForKey:@"retweeted_status"];
    if (repostedStatusDict) {
        result.repostStatus = [Status insertStatus:repostedStatusDict inManagedObjectContext:context withOperatingObject:object];
    }
    
    return result;
}

+ (void)deleteObjectsEarlierThan:(NSDate *)updateDate inManagedObjectContext:(NSManagedObjectContext *)context
{
    int totalNumber = [self countOfStatuseInContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(updateDate <= %@)", updateDate];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
    
    totalNumber = [self countOfStatuseInContext:context];
}

+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteAllTempStatusesInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@", [NSNumber numberWithBool:YES]]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteStatusesOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"author == %@ && forTableView == %@ && operatedBy == %@", user, [NSNumber numberWithBool:YES], object]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteStatusesWithSearchKey:(NSString *)searchKey InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"searchKey == %@ && operatedBy == %@", searchKey, object]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteRepostsOfStatus:(Status *)status ManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@", status.repostedBy, object]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteMentionStatusesInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isMentioned == %@ && forTableView == %@", [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES]]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteObject:(Status *)object inManagedObjectContext:(NSManagedObjectContext *)context
{
    [context deleteObject:object];
}


+ (void)deleteStatusWithID:(NSString *)statusID inManagedObjectContext:(NSManagedObjectContext *)context withObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"statusID == %@ && operatedBy == %@", statusID, object]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

- (BOOL)hasLocationInfo
{
    return self.lat && self.lon && [self.lat floatValue] != 0 && [self.lon floatValue] != 0;
}

- (BOOL)locationInfoAlreadyLoaded
{
    return self.location && ![self.location isEqualToString:@""];
}

@end
