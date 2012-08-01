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

@interface DirectMessage : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * recipientID;
@property (nonatomic, retain) NSString * recipientScreenName;
@property (nonatomic, retain) NSString * senderID;
@property (nonatomic, retain) NSString * senderScreenName;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *conversation;
@property (nonatomic, retain) NSNumber * messageHeight;
@property (nonatomic, retain) NSNumber * messageWidth;

+ (DirectMessage *)messageWithID:(NSString *)messageID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (DirectMessage *)insertMessage:(NSDictionary *)dict withConversation:(Conversation *)targetConversation inManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface DirectMessage (CoreDataGeneratedAccessors)

- (void)addConversationObject:(Conversation *)value;
- (void)removeConversationObject:(Conversation *)value;
- (void)addConversation:(NSSet *)values;
- (void)removeConversation:(NSSet *)values;

@end
