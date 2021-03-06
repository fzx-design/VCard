//
//  Conversation.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Conversation.h"
#import "DirectMessage.h"
#import "User.h"
#import "NSDate+Addition.h"
#import "NSUserDefaults+Addition.h"

@implementation Conversation

@dynamic currentUserID;
@dynamic targetUserAvatarURL;
@dynamic targetUserID;
@dynamic latestMessageText;
@dynamic updateDate;
@dynamic hasNew;
@dynamic messages;
@dynamic targetUser;

+ (Conversation *)conversationWithCurrentUserID:(NSString *)currentUserID
                                   targetUserID:(NSString *)targetUserID
                         inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"currentUserID == %@ && targetUserID == %@", currentUserID, targetUserID]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    Conversation *res = [items lastObject];
    
    return res;
}

+ (Conversation *)insertConversation:(NSDictionary *)dict toCurrentUser:(NSString *)currentUserID inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *targetUser = nil;
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    if ([userDict isKindOfClass:[NSDictionary class]] && userDict.count > 0) {
        targetUser = [User insertUser:userDict inManagedObjectContext:context withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeMessage];
    } else {
        return nil;
    }
    
    Conversation *result = [Conversation conversationWithCurrentUserID:currentUserID targetUserID:targetUser.userID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:context];
    }
    
    result.targetUser = targetUser;
    result.targetUserAvatarURL = targetUser.largeAvatarURL;
    result.targetUserID = targetUser.userID;
    result.currentUserID = currentUserID;
    
    NSDictionary *messageDict = [dict objectForKey:@"direct_message"];
    if ([messageDict isKindOfClass:[NSDictionary class]] && messageDict.count > 0) {
        NSString *dateString = [messageDict objectForKey:@"created_at"];
        result.updateDate = [NSDate dateFromStringRepresentation:dateString];
        NSString *text = [messageDict objectForKey:@"text"];
        result.hasNew = @(![text isEqualToString:result.latestMessageText] && [NSUserDefaults hasFetchedMessages]);
        result.latestMessageText = [messageDict objectForKey:@"text"];
    }
    
    return result;
}

+ (Conversation *)insertCOnversationWithCurrentUserID:(NSString *)currentUserID
                                           targetUser:(User *)targetUser
                               inManagedObjectContext:(NSManagedObjectContext *)context
{
    Conversation *result = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:context];
    
    result.targetUser = targetUser;
    result.targetUserAvatarURL = targetUser.largeAvatarURL;
    result.targetUserID = targetUser.userID;
    result.currentUserID = currentUserID;
    result.updateDate = [NSDate date];
    result.hasNew = @(NO);
    result.latestMessageText = @"";
    
    return result;
}

+ (void)deleteEmptyConversationsOfUser:(NSString *)currentUserID managedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"currentUserID == %@", currentUserID]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    for (Conversation *object in items) {
        if ([object.latestMessageText isEqualToString:@""]) {
            [context deleteObject:object];
        }
    }
    items = nil;
}

+ (void)deleteAllConversationsOfUser:(NSString *)currentUserID managedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"currentUserID == %@", currentUserID]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
        
    for (Conversation *object in items) {
        [context deleteObject:object];
    }
    items = nil;
}

@end
