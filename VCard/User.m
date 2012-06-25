//
//  User.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "User.h"
#import "Comment.h"
#import "Status.h"
#import "User.h"
#import "NSDateAddition.h"

@implementation User

@dynamic blogURL;
@dynamic createdAt;
@dynamic domainURL;
@dynamic favouritesCount;
@dynamic followersCount;
@dynamic following;
@dynamic followMe;
@dynamic friendsCount;
@dynamic gender;
@dynamic largeAvatarURL;
@dynamic location;
@dynamic profileImageURL;
@dynamic screenName;
@dynamic selfDescription;
@dynamic statusesCount;
@dynamic updateDate;
@dynamic userID;
@dynamic verified;
@dynamic verifiedType;
@dynamic operatedBy;
@dynamic operatable;
@dynamic comments;
@dynamic commentsToMe;
@dynamic favorites;
@dynamic followers;
@dynamic friends;
@dynamic friendsStatuses;
@dynamic statuses;

+ (User *)insertUser:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSString *userID = [[dict objectForKey:@"id"] stringValue];
    
    if (!userID || [userID isEqualToString:@""]) {
        return nil;
    }
    
    User *result = [User userWithID:userID inManagedObjectContext:context withOperatingObject:object];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    } else {
//        NSLog(@"%@, %@", result.screenName, result.operatedBy);
    }
    
    result.updateDate = [NSDate date];
    
    result.userID = userID;
    result.screenName = [dict objectForKey:@"screen_name"];
    result.operatable = [NSNumber numberWithBool:![(NSString *)object isEqualToString:kCoreDataIdentifierDefault]];
    result.operatedBy = object;
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.profileImageURL = [dict objectForKey:@"profile_image_url"];
    result.largeAvatarURL = [dict objectForKey:@"avatar_large"];
    result.gender = [dict objectForKey:@"gender"];
    result.selfDescription = [dict objectForKey:@"description"];
    result.location = [dict objectForKey:@"location"];
    result.verified = [NSNumber numberWithBool:[[dict objectForKey:@"verified"] boolValue]];
    
    result.verifiedType = [dict objectForKey:@"verified_type"];
    result.domainURL = [dict objectForKey:@"domain"];
    result.blogURL = [dict objectForKey:@"url"];
    
    result.friendsCount = [[dict objectForKey:@"friends_count"] stringValue];
    result.followersCount = [[dict objectForKey:@"followers_count"] stringValue];
    result.statusesCount = [[dict objectForKey:@"statuses_count"] stringValue];
    result.favouritesCount = [[dict objectForKey:@"favourites_count"] stringValue];
    
    BOOL following = [[dict objectForKey:@"following"] boolValue];
    BOOL followMe = [[dict objectForKey:@"follow_me"] boolValue];
    
    result.following = [NSNumber numberWithBool:following];
    result.followMe = [NSNumber numberWithBool:followMe];
    
    return result;
}

+ (User *)userWithID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userID == %@ && operatedBy == %@", userID, object]];
    
    User *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
}

+ (void)deleteFriendsOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@", user.friends, object]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteFollowersOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@", user.followers, object]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteAllTempUsersInManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@", [NSNumber numberWithBool:YES]]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

- (BOOL)isEqualToUser:(User *)user
{
    return [self.userID isEqualToString:user.userID];
}

- (VerifiedType)verifiedTypeOfUser
{
    VerifiedType type = VerifiedTypeNone;
    int typeValue = [self.verifiedType intValue];
    
    if (typeValue == -1) {
        type = VerifiedTypeNone;
    } else if (typeValue == 0) {
        type = VerifiedTypePerson;
    } else if (typeValue < 200) {
        type = VerifiedTypeAssociation;
    } else {
        type = VerifiedTypeTalent;
    }
    return type;
}


@end
