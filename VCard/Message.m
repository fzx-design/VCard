//
//  Message.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "Message.h"
#import "User.h"
#import "Conversation.h"
#import "NSDateAddition.h"


@implementation Message

@dynamic messageID;
@dynamic text;
@dynamic createdAt;
@dynamic recipientID;
@dynamic recipientScreenName;
@dynamic senderID;
@dynamic senderScreenName;
@dynamic conversation;

+ (Message *)messageWithID:(NSString *)messageID inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"messageID == %@", messageID]];
    
    Message *res = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return res;
}

+ (Message *)insertMessage:(NSDictionary *)dict withConversation:(Conversation *)targetConversation inManagedObjectContext:(NSManagedObjectContext *)context
{    
    NSString *messageID = [[dict objectForKey:@"id"] stringValue];
    
    if (!messageID || [messageID isEqualToString:@""]) {
        return nil;
    }
    
    Message *result = [Message messageWithID:messageID inManagedObjectContext:context];
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    }
    
    result.messageID = messageID;
    result.text = [dict objectForKey:@"text"];
    result.conversation = targetConversation;
    
    NSString *dateString = [dict objectForKey:@"created_at"];
    result.createdAt = [NSDate dateFromStringRepresentation:dateString];
    
    NSDictionary *senderDict = [dict objectForKey:@"sender"];
    if ([senderDict isKindOfClass:[NSDictionary class]] && senderDict > 0) {
        User *sender = [User insertUser:senderDict inManagedObjectContext:context withOperatingObject:kCoreDataIdentifierDefault];
        result.senderID = sender.userID;
        result.senderScreenName = sender.screenName;
    }
    
    NSDictionary *recipientDict = [dict objectForKey:@"recipient"];
    if ([recipientDict isKindOfClass:[NSDictionary class]] && recipientDict > 0) {
        User *recipient = [User insertUser:recipientDict inManagedObjectContext:context withOperatingObject:kCoreDataIdentifierDefault];
        result.recipientID = recipient.userID;
        result.recipientScreenName = recipient.screenName;
    }
    
    return result;
}


@end
