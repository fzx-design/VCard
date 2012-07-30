//
//  Status.m
//  VCard
//
//  Created by Gabriel Yeah on 12-7-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Status.h"
#import "Comment.h"
#import "Status.h"
#import "User.h"
#import "NSDate+Addition.h"
#import "NSUserDefaults+Addition.h"
#import "CoreDataViewController.h"


@implementation Status

@dynamic bmiddlePicURL;
@dynamic cached;
@dynamic cacheDateString;
@dynamic cacheLinks;
@dynamic cacheTextLabel;
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
@dynamic mediaLink;
@dynamic operatable;
@dynamic operatedBy;
@dynamic originalPicURL;
@dynamic repostsCount;
@dynamic searchKey;
@dynamic searchString;
@dynamic source;
@dynamic statusID;
@dynamic text;
@dynamic thumbnailPicURL;
@dynamic type;
@dynamic updateDate;
@dynamic currentUserID;
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
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"statusID == %@ && operatedBy == %@ && currentUserID = %@", statudID, object, currentUserID]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    Status *res = [items lastObject];
    items = nil;
    
    return res;
}

+ (Status *)insertStatus:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSString *statusID = [[dict objectForKey:@"id"] stringValue];
    
    if (!statusID || [statusID isEqualToString:@""]) {
        return nil;
    }
    
    Status *result = [Status statusWithID:statusID inManagedObjectContext:context withOperatingObject:object];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:context];
    }
    
    result.updateDate = [NSDate date];
    
    result.statusID = statusID;
    result.currentUserID = [CoreDataViewController getCurrentUser].userID;
    result.operatable = [NSNumber numberWithBool:![(NSString *)object isEqualToString:kCoreDataIdentifierDefault]];
    result.operatedBy = object;
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.text = [dict objectForKey:@"text"];
    
    result.source = [dict objectForKey:@"source"];
    
    BOOL favourited = [[NSUserDefaults getCurrentUserFavouriteIDs] containsObject:result.statusID];
    result.favorited = @(favourited);
    
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
        result.lat = @([[(NSArray*)([geoDic objectForKey:@"coordinates"]) objectAtIndex:0] floatValue]);
        result.lon = @([[(NSArray*)([geoDic objectForKey:@"coordinates"]) objectAtIndex:1] floatValue]);
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

+ (void)deleteAllObjectsFetchedByUser:(NSString *)currentUserID InManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"currentUserID = %@", currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteAllTempStatusesInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@ && currentUserID = %@", @(YES), currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteStatusesOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"author == %@ && forTableView == %@ && operatedBy == %@ && currentUserID = %@", user, @(YES), object, currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteStatusesWithSearchKey:(NSString *)searchKey InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"searchKey == %@ && operatedBy == %@ && currentUserID = %@", searchKey, object, currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteRepostsOfStatus:(Status *)status ManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@ && currentUserID = %@", status.repostedBy, object, currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteMentionStatusesInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isMentioned == %@ && forTableView == %@ && currentUserID = %@", @(YES), @(YES), currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteStatusWithID:(NSString *)statusID inManagedObjectContext:(NSManagedObjectContext *)context withObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"statusID == %@ && operatedBy == %@ && currentUserID = %@", statusID, object, currentUserID]];
    
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

+ (NSArray *)getTempStatusCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@ && currentUserID = %@", @(YES), currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items;
}

+ (NSArray *)getUndeletableStatusCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Status" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@ && currentUserID = %@", @(NO), currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items;
}

@end
