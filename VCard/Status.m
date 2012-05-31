//
//  Status.m
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Status.h"
#import "Comment.h"
#import "Status.h"
#import "User.h"
#import "NSDateAddition.h"

@implementation Status

@dynamic bmiddlePicURL;
@dynamic commentsCount;
@dynamic createdAt;
@dynamic favorited;
@dynamic featureMusic;
@dynamic featureOrigin;
@dynamic featurePic;
@dynamic featureVideo;
@dynamic isMentioned;
@dynamic lat;
@dynamic location;
@dynamic lon;
@dynamic originalPicURL;
@dynamic repostsCount;
@dynamic searchString;
@dynamic source;
@dynamic statusID;
@dynamic text;
@dynamic thumbnailPicURL;
@dynamic updateDate;
@dynamic cardSizeImageHeight;
@dynamic cardSizeCardHeight;
@dynamic forTableView;
@dynamic forCastView;
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

+ (Status *)statusWithID:(NSString *)statudID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"statusID == %@", statudID]];
    
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

+ (Status *)insertStatus:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{    
    NSString *statusID = [[dict objectForKey:@"id"] stringValue];
    
    if (!statusID || [statusID isEqualToString:@""]) {
        return nil;
    }
    
    Status *result = [Status statusWithID:statusID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:context];
    }
    
    result.updateDate = [NSDate date];
    
    result.statusID = statusID;
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.text = [dict objectForKey:@"text"];
    
    result.source = [dict objectForKey:@"source"];
    
    result.favorited = [NSNumber numberWithBool:[[dict objectForKey:@"favorited"] boolValue]];
    
    result.commentsCount = [NSString stringWithFormat:@"%i",[dict objectForKey:@"comments_count"]];
    result.repostsCount = [NSString stringWithFormat:@"%i",[dict objectForKey:@"reposts_count"]];
    
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
    
    result.author = [User insertUser:userDict inManagedObjectContext:context];
        
    NSDictionary* repostedStatusDict = [dict objectForKey:@"retweeted_status"];
    if (repostedStatusDict) {
        result.repostStatus = [Status insertStatus:repostedStatusDict inManagedObjectContext:context];
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

+ (void)deleteObject:(Status *)object inManagedObjectContext:(NSManagedObjectContext *)context
{
    [context deleteObject:object];
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
