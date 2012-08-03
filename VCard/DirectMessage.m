//
//  Message.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DirectMessage.h"
#import "Conversation.h"
#import "User.h"
#import "NSDate+Addition.h"


@implementation DirectMessage

@dynamic createdAt;
@dynamic messageID;
@dynamic recipientID;
@dynamic recipientScreenName;
@dynamic senderID;
@dynamic senderScreenName;
@dynamic text;
@dynamic conversation;
@dynamic messageHeight;
@dynamic messageWidth;

+ (DirectMessage *)messageWithID:(NSString *)messageID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"DirectMessage" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"messageID == %@", messageID]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    DirectMessage *res = [items lastObject];
    
    return res;
}

+ (DirectMessage *)insertMessage:(NSDictionary *)dict withConversation:(Conversation *)targetConversation inManagedObjectContext:(NSManagedObjectContext *)context
{    
    NSString *messageID = [[dict objectForKey:@"id"] stringValue];
    
    if (!messageID || [messageID isEqualToString:@""]) {
        return nil;
    }
    
    DirectMessage *result = [DirectMessage messageWithID:messageID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"DirectMessage" inManagedObjectContext:context];
    }
    
    result.messageID = messageID;
    result.text = [dict objectForKey:@"text"];
    [result addConversationObject:targetConversation];
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    NSDictionary *senderDict = [dict objectForKey:@"sender"];
    if ([senderDict isKindOfClass:[NSDictionary class]] && senderDict > 0) {
        User *sender = [User insertUser:senderDict inManagedObjectContext:context withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeMessage];
        result.senderID = sender.userID;
        result.senderScreenName = sender.screenName;
    }
    
    NSDictionary *recipientDict = [dict objectForKey:@"recipient"];
    if ([recipientDict isKindOfClass:[NSDictionary class]] && recipientDict > 0) {
        User *recipient = [User insertUser:recipientDict inManagedObjectContext:context withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeMessage];
        result.recipientID = recipient.userID;
        result.recipientScreenName = recipient.screenName;
    }
    
    return result;
}

+ (void)deleteMessagesOfConversion:(Conversation *)conversion inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"DirectMessage" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@", conversion.messages]];
    
    NSArray *items = [context executeFetchRequest:request error:NULL];
    for (NSManagedObject *object in items) {
        [context deleteObject:object];
    }
}

@end
