//
//  Comment.m
//  VCard
//
//  Created by 海山 叶 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Comment.h"
#import "Status.h"
#import "User.h"
#import "NSDateAddition.h"

@implementation Comment

@dynamic authorFollowedByMe;
@dynamic byMe;
@dynamic commentHeight;
@dynamic commentID;
@dynamic createdAt;
@dynamic operatable;
@dynamic operatedBy;
@dynamic source;
@dynamic text;
@dynamic toMe;
@dynamic updateDate;
@dynamic mentioningMe;
@dynamic author;
@dynamic inReplyToUser;
@dynamic targetStatus;
@dynamic targetUser;

+ (Comment *)insertCommentByMe:(NSDictionary *)dict currentUserID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    Comment *result = [Comment configureCommentBasicInfoWithDict:dict managedContext:context];
    
	result.byMe = [NSNumber numberWithBool:YES];
    result.source = userID;
    
    return result;
}

+ (Comment *)insertCommentToMe:(NSDictionary *)dict currentUserID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    Comment *result = [Comment configureCommentBasicInfoWithDict:dict managedContext:context];
    
	result.toMe = [NSNumber numberWithBool:YES];
    result.source = userID;
    
    return result;
}

+ (Comment *)insertCommentMentioningMe:(NSDictionary *)dict currentUserID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    Comment *result = [Comment configureCommentBasicInfoWithDict:dict managedContext:context];
    
	result.mentioningMe = [NSNumber numberWithBool:YES];
    result.source = userID;
    
    return result;
}

+ (Comment *)configureCommentBasicInfoWithDict:(NSDictionary *)dict managedContext:(NSManagedObjectContext *)context 
{
    NSString *commentID = [[dict objectForKey:@"id"] stringValue];
    
    if (!commentID || [commentID isEqualToString:@""]) {
        return nil;
    }
    
    Comment *result = [Comment commentWithID:commentID inManagedObjectContext:context withOperatingObject:kCoreDataIdentifierDefault];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
    }
    result.commentID = [[dict objectForKey:@"id"] stringValue];
    result.operatedBy = kCoreDataIdentifierDefault;
    result.operatable = [NSNumber numberWithBool:NO];
    result.updateDate = [NSDate date];
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    result.text = [dict objectForKey:@"text"];
    
    NSDictionary *statusDict = [dict objectForKey:@"status"];
    if ([statusDict isKindOfClass:[NSDictionary class]] && statusDict.count > 0) {
        result.targetStatus = [Status insertStatus:statusDict inManagedObjectContext:context withOperatingObject:result.operatedBy];
        result.targetStatus.operatable = [NSNumber numberWithBool:YES];
        result.targetUser = result.targetStatus.author;
    } else {
        NSLog(@"%@", dict);
    }
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    if ([userDict isKindOfClass:[NSDictionary class]] && userDict.count > 0) {
        result.author = [User insertUser:userDict inManagedObjectContext:context withOperatingObject:result.operatedBy];
    } else {
        NSLog(@"%@", dict);
    }
    
    return result;
}

+ (Comment *)insertComment:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
    NSString *commentID = [[dict objectForKey:@"id"] stringValue];
    
    if (!commentID || [commentID isEqualToString:@""]) {
        return nil;
    }
    
    Comment *result = [Comment commentWithID:commentID inManagedObjectContext:context withOperatingObject:object];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
    }
    
    result.commentID = commentID;
    result.operatedBy = object;
    result.operatable = [NSNumber numberWithBool:YES];
    
    result.updateDate = [NSDate date];
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.text = [dict objectForKey:@"text"];
    
    NSDictionary *statusDict = [dict objectForKey:@"status"];
    
    if ([statusDict isKindOfClass:[NSDictionary class]] && statusDict.count > 0) {
        result.targetStatus = [Status insertStatus:statusDict inManagedObjectContext:context withOperatingObject:result.operatedBy];
        result.targetUser = result.targetStatus.author;
    } else {
        NSLog(@"%@", dict);
    }
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    
    if ([userDict isKindOfClass:[NSDictionary class]] && userDict.count > 0) {
        result.author = [User insertUser:userDict inManagedObjectContext:context withOperatingObject:object];
    } else {
        NSLog(@"%@", dict);
    }
    
    return result;
}

+ (Comment *)commentWithID:(NSString *)commentID inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"commentID == %@ && operatedBy == %@", commentID, object]];
    
    Comment *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
}

+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteCommentsToMeInManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"toMe == %@", [NSNumber numberWithBool:YES]]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteCommentsByMeInManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"byMe == %@", [NSNumber numberWithBool:YES]]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteCommentsMentioningMeInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"mentioningMe == %@", [NSNumber numberWithBool:YES]]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteCommentsOfStatus:(Status *)status ManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@", status.comments, object]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteCommentWithID:(NSString *)commentID inManagedObjectContext:(NSManagedObjectContext *)context withObject:(id)object
{
    Comment *comment = [Comment commentWithID:commentID inManagedObjectContext:context withOperatingObject:object];
    if (comment) {
        [context deleteObject:comment];
    }
}

+ (void)deleteAllTempCommentsInManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@", [NSNumber numberWithBool:YES]]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (int)getTempCommentCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@", [NSNumber numberWithBool:YES]]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items.count;
}

+ (int)getUndeletableCommentCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@", [NSNumber numberWithBool:NO]]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items.count;
}

- (BOOL)isEqualToComment:(Comment *)comment
{
    return [self.commentID isEqualToString:comment.commentID];
}

@end
