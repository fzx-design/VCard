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

@implementation Conversation

@dynamic currentUserID;
@dynamic targetUserAvatarURL;
@dynamic targetUserID;
@dynamic updateDate;
@dynamic latestMessage;
@dynamic messages;
@dynamic targetUser;

+ (Conversation *)conversationWithCurrentUserID:(NSString *)currentUserID
                                   targetUserID:(NSString *)targetUserID
                         inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"currentUserID == %@ && targetUserID == %@", currentUserID, targetUserID]];
    
    Conversation *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
}

+ (Conversation *)insertConversation:(NSDictionary *)dict toCurrentUser:(NSString *)currentUserID inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *targetUser = nil;
    
    NSDictionary *userDict = [dict objectForKey:@"user"];
    if ([userDict isKindOfClass:[NSDictionary class]] && userDict.count > 0) {
        targetUser = [User insertUser:userDict inManagedObjectContext:context withOperatingObject:kCoreDataIdentifierDefault];
    } else {
        NSLog(@"Conversation error: %@", dict);
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
        result.latestMessage = [DirectMessage insertMessage:messageDict withConversation:result inManagedObjectContext:context];
        result.updateDate = result.latestMessage.createdAt;
    } else {
        NSLog(@"Conversation has no message %@", dict);
    }
    
    
    return result;
}

@end