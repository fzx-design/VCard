//
//  Comment.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-25.
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
@dynamic source;
@dynamic text;
@dynamic toMe;
@dynamic updateDate;
@dynamic operatedBy;
@dynamic operatable;
@dynamic author;
@dynamic inReplyToUser;
@dynamic targetStatus;
@dynamic targetUser;

+ (Comment *)insertCommentByMe:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *commentID = [[dict objectForKey:@"id"] stringValue];
    
    if (!commentID || [commentID isEqualToString:@""]) {
        return nil;
    }
    
    Comment *result = [Comment commentWithID:commentID inManagedObjectContext:context withOperatingObject:@""];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
    }
    
    result.commentID = commentID;
    result.operatedBy = nil;
    result.operatable = [NSNumber numberWithBool:NO];
    
    result.updateDate = [NSDate date];
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.text = [dict objectForKey:@"text"];
	result.toMe = [NSNumber numberWithBool:NO];
	result.byMe = [NSNumber numberWithBool:YES];
    
    NSDictionary *statusDict = [dict objectForKey:@"status"];
    
    if (statusDict) {
        result.targetStatus = [Status insertStatus:statusDict inManagedObjectContext:context];
        result.targetUser = result.targetStatus.author;
    }
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    
    if (userDict) {
        result.author = [User insertUser:userDict inManagedObjectContext:context withOperatingObject:@""];
    }
    
    return result;
}

+ (Comment *)insertCommentToMe:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *commentID = [[dict objectForKey:@"id"] stringValue];
    
    if (!commentID || [commentID isEqualToString:@""]) {
        return nil;
    }
    
    Comment *result = [Comment commentWithID:commentID inManagedObjectContext:context withOperatingObject:@""];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
    }
    
    result.commentID = commentID;
    result.operatedBy = nil;
    result.operatable = [NSNumber numberWithBool:NO];
    
    result.updateDate = [NSDate date];
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    result.text = [dict objectForKey:@"text"];
	result.toMe = [NSNumber numberWithBool:YES];
	result.byMe = [NSNumber numberWithBool:NO];
    
    NSDictionary *statusDict = [dict objectForKey:@"status"];
    
    if (statusDict) {
        result.targetStatus = [Status insertStatus:statusDict inManagedObjectContext:context];
        result.targetUser = result.targetStatus.author;
    }
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    
    if (userDict) {
        result.author = [User insertUser:userDict inManagedObjectContext:context withOperatingObject:@""];
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
    
    if (statusDict) {
        result.targetStatus = [Status insertStatus:statusDict inManagedObjectContext:context];
        result.targetUser = result.targetStatus.author;
    }
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    
    if (userDict) {
        result.author = [User insertUser:userDict inManagedObjectContext:context withOperatingObject:object];
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

- (BOOL)isEqualToComment:(Comment *)comment
{
    return [self.commentID isEqualToString:comment.commentID];
}

@end
