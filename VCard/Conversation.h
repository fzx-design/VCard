//
//  Conversation.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DirectMessage, User;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSString * currentUserID;
@property (nonatomic, retain) NSString * targetUserAvatarURL;
@property (nonatomic, retain) NSString * targetUserID;
@property (nonatomic, retain) NSString * latestMessageText;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSNumber * hasNew;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) User *targetUser;

+ (Conversation *)conversationWithCurrentUserID:(NSString *)currentUserID
                                   targetUserID:(NSString *)targetUserID
                         inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Conversation *)insertConversation:(NSDictionary *)dict toCurrentUser:(NSString *)currentUserID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Conversation *)insertCOnversationWithCurrentUserID:(NSString *)currentUserID
                                           targetUser:(User *)targetUser
                               inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteEmptyConversationsOfUser:(NSString *)currentUserID managedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteAllConversationsOfUser:(NSString *)currentUserID managedObjectContext:(NSManagedObjectContext *)context;

@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(DirectMessage *)value;
- (void)removeMessagesObject:(DirectMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
