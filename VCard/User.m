//
//  User.m
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
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
@dynamic followMe;
@dynamic comments;
@dynamic commentsToMe;
@dynamic favorites;
@dynamic followers;
@dynamic friends;
@dynamic friendsStatuses;
@dynamic statuses;


+ (User *)insertUser:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *userID = [[dict objectForKey:@"id"] stringValue];
    
    if (!userID || [userID isEqualToString:@""]) {
        return nil;
    }
    
    User *result = [User userWithID:userID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    }
    
    result.updateDate = [NSDate date];
    
    result.userID = userID;
    result.screenName = [dict objectForKey:@"screen_name"];
    
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
    
    
    //	NSDictionary *statusDict = [dict objectForKey:@"status"];
    //    
    //    if (statusDict) {
    //        [result addStatusesObject:[Status insertStatus:statusDict inManagedObjectContext:context]];
    //    }
    
    return result;
}

+ (User *)userWithID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userID == %@", userID]];
    
    User *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
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
