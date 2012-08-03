//
//  User.m
//  VCard
//
//  Created by Gabriel Yeah on 12-7-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "User.h"
#import "Comment.h"
#import "Conversation.h"
#import "Status.h"
#import "User.h"
#import "NSDate+Addition.h"
#import "CoreDataViewController.h"


@implementation User

@dynamic blogURL;
@dynamic createdAt;
@dynamic domainURL;
@dynamic favouritesCount;
@dynamic favouritesIDs;
@dynamic followersCount;
@dynamic following;
@dynamic followMe;
@dynamic friendsCount;
@dynamic gender;
@dynamic largeAvatarURL;
@dynamic location;
@dynamic operatable;
@dynamic operatedBy;
@dynamic profileImageURL;
@dynamic screenName;
@dynamic selfDescription;
@dynamic statusesCount;
@dynamic unreadCommentCount;
@dynamic unreadFollowingCount;
@dynamic unreadMentionComment;
@dynamic unreadMentionCount;
@dynamic unreadMessageCount;
@dynamic unreadStatusCount;
@dynamic updateDate;
@dynamic userID;
@dynamic verified;
@dynamic verifiedType;
@dynamic currentUserID;
@dynamic comments;
@dynamic commentsToMe;
@dynamic conversation;
@dynamic favorites;
@dynamic followers;
@dynamic friends;
@dynamic friendsStatuses;
@dynamic statuses;

+ (User *)insertCurrentUser:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = [User configureBasicUserInfoWithDict:dict inManagedObjectContext:context withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeCurrentUser];
    user.currentUserID = user.userID;
    return user;
}

+ (User *)insertUser:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object operatableType:(int)type
{
    User *user = [User configureBasicUserInfoWithDict:dict inManagedObjectContext:context withOperatingObject:object operatableType:type];
    user.currentUserID = [CoreDataViewController getCurrentUser].userID;
    return user;
}

+ (User *)configureBasicUserInfoWithDict:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object operatableType:(int)type
{
    NSString *userID = [[dict objectForKey:@"id"] stringValue];
    
    if (!userID || [userID isEqualToString:@""]) {
        return nil;
    }
    
    User *result = [User userWithID:userID inManagedObjectContext:context withOperatingObject:object operatableType:type];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    } else {
        //        NSLog(@"%@, %@", result.screenName, result.operatedBy);
    }
    
    result.updateDate = [NSDate date];
    
    result.userID = userID;
    result.screenName = [dict objectForKey:@"screen_name"];
    
    result.operatable = @(type);
    result.operatedBy = object;
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.profileImageURL = [dict objectForKey:@"profile_image_url"];
    result.largeAvatarURL = [dict objectForKey:@"avatar_large"];
    result.gender = [dict objectForKey:@"gender"];
    result.selfDescription = [dict objectForKey:@"description"];
    result.location = [dict objectForKey:@"location"];
    result.verified = @([[dict objectForKey:@"verified"] boolValue]);
    
    result.verifiedType = [dict objectForKey:@"verified_type"];
    result.domainURL = [dict objectForKey:@"domain"];
    result.blogURL = [dict objectForKey:@"url"];
    
    result.friendsCount = [[dict objectForKey:@"friends_count"] stringValue];
    result.followersCount = [[dict objectForKey:@"followers_count"] stringValue];
    result.statusesCount = [[dict objectForKey:@"statuses_count"] stringValue];
    result.favouritesCount = [[dict objectForKey:@"favourites_count"] stringValue];
    
    BOOL following = [[dict objectForKey:@"following"] boolValue];
    BOOL followMe = [[dict objectForKey:@"follow_me"] boolValue];
    
    result.following = @(following);
    result.followMe = @(followMe);
    
    return result;
}

+ (User *)getCurrentUserWithID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userID == %@ && currentUserID == %@ && operatedBy == %@", userID, userID, kCoreDataIdentifierDefault]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    User *res = [items lastObject];
    
    return res;
}

+ (User *)userWithID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object operatableType:(int)type
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userID == %@ && operatedBy == %@ && currentUserID == %@ && operatable == %@", userID, object, currentUserID, @(type)]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    User *res = [items lastObject];
    
    return res;
}

+ (void)deleteFriendsOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@ && currentUserID == %@", user.friends, object, currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteFollowersOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@ && currentUserID == %@", user.followers, object, currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteUsersInManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"operatedBy == %@ && currentUserID == %@", object, currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"currentUserID == %@", currentUserID]];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteRedundantUsersInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"currentUserID == %@ && userID != %@ && operatable == %@", currentUserID, currentUserID, @(kOperatableTypeDefault)]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (User *user in items) {
        NSLog(@"cast view delete: %@", user.screenName);
        [context deletedObjects];
    }
}

+ (void)deleteCommentRelatedUsersInManagedObjectContext:(NSManagedObjectContext *)context operatableType:(int)type
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"currentUserID == %@ && userID != %@ && operatable == %@", currentUserID, currentUserID, @(type)]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (User *user in items) {
        NSLog(@"comment type: %@ delete: %@", user.operatable, user.screenName);
        [context deleteObject:user];
    }
    items = nil;
}

+ (void)deleteAllTempUsersInManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@ && currentUserID == %@", @(kOperatableTypeNone), currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    NSLog(@"stack delete %d users", items.count);
    
    for (User *user in items) {
        NSLog(@"stack delete %@", user.screenName);
        [context deleteObject:user];
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

+ (NSArray *)getTempUserCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@", @(kOperatableTypeNone)]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items;
}

+ (NSArray *)getUndeletableUserCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable != %@", @(kOperatableTypeNone)]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items;
}

@end
