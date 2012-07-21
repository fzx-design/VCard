//
//  Message.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * recipientID;
@property (nonatomic, retain) NSString * recipientScreenName;
@property (nonatomic, retain) NSString * senderID;
@property (nonatomic, retain) NSString * senderScreenName;
@property (nonatomic, retain) Conversation *conversation;

+ (Message *)messageWithID:(NSString *)messageID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Message *)insertMessage:(NSDictionary *)dict withConversation:(Conversation *)targetConversation inManagedObjectContext:(NSManagedObjectContext *)context;

@end
