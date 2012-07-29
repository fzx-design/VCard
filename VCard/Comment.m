//
//  Comment.m
//  VCard
//
//  Created by Gabriel Yeah on 12-7-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Comment.h"
#import "Status.h"
#import "User.h"
#import "NSDate+Addition.h"
#import "CoreDataViewController.h"

@implementation Comment

@dynamic authorFollowedByMe;
@dynamic byMe;
@dynamic commentHeight;
@dynamic commentID;
@dynamic createdAt;
@dynamic mentioningMe;
@dynamic operatable;
@dynamic operatedBy;
@dynamic source;
@dynamic text;
@dynamic toMe;
@dynamic updateDate;
@dynamic currentUserID;
@dynamic author;
@dynamic inReplyToUser;
@dynamic targetStatus;
@dynamic targetUser;

+ (Comment *)insertCommentByMe:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    Comment *result = [Comment configureCommentBasicInfoWithDict:dict managedContext:context];
    
	result.byMe = @(YES);
    
    return result;
}

+ (Comment *)insertCommentToMe:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    Comment *result = [Comment configureCommentBasicInfoWithDict:dict managedContext:context];
    
	result.toMe = @(YES);
    
    return result;
}

+ (Comment *)insertCommentMentioningMe:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    Comment *result = [Comment configureCommentBasicInfoWithDict:dict managedContext:context];
    
	result.mentioningMe = @(YES);
    
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
    result.currentUserID = [CoreDataViewController getCurrentUser].userID;
    result.operatedBy = kCoreDataIdentifierDefault;
    result.operatable = @(NO);
    result.updateDate = [NSDate date];
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    result.text = [dict objectForKey:@"text"];
    
    NSDictionary *statusDict = [dict objectForKey:@"status"];
    if ([statusDict isKindOfClass:[NSDictionary class]] && statusDict.count > 0) {
        result.targetStatus = [Status insertStatus:statusDict inManagedObjectContext:context withOperatingObject:result.operatedBy];
        //        result.targetStatus.operatable = [NSNumber numberWithBool:YES];
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
    result.currentUserID = [CoreDataViewController getCurrentUser].userID;
    result.operatedBy = object;
    result.operatable = @(YES);
    
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
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"commentID == %@ && operatedBy == %@ && currentUserID == %@", commentID, object, currentUserID]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    Comment *res = [items lastObject];
    
    return res;
}

+ (void)deleteCommentsToMeInManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"toMe == %@ && currentUserID == %@", @(YES), currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteCommentsByMeInManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"byMe == %@ && currentUserID == %@", @(YES), currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteCommentsMentioningMeInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"mentioningMe == %@ && currentUserID == %@", @(YES), currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteCommentsOfStatus:(Status *)status ManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@ && currentUserID == %@", status.comments, object, currentUserID]];
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
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@ && currentUserID == %@", @(YES), currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (void)deleteAllCommentsFetchedByCurrentUser:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSString *currentUserID = [CoreDataViewController getCurrentUser].userID;
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@ && currentUserID == %@", @(YES), currentUserID]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }
}

+ (int)getTempCommentCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@", @(YES)]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items.count;
}

+ (int)getUndeletableCommentCount:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"operatable == %@", @(NO)]];
	NSArray *items = [context executeFetchRequest:request error:NULL];
    
    return items.count;
}

- (BOOL)isEqualToComment:(Comment *)comment
{
    return [self.commentID isEqualToString:comment.commentID];
}

@end
