//
//  Conversation.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSString * targetUserID;
@property (nonatomic, retain) NSString * currentUserID;
@property (nonatomic, retain) NSString * targetUserAvatarURL;
@property (nonatomic, retain) User *targetUser;
@property (nonatomic, retain) NSManagedObject *latestMessage;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
