//
//  Comment.h
//  VCard
//
//  Created by Gabriel Yeah on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Status, User;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSNumber * authorFollowedByMe;
@property (nonatomic, retain) NSNumber * byMe;
@property (nonatomic, retain) NSNumber * commentHeight;
@property (nonatomic, retain) NSString * commentID;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * toMe;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) id operatedBy;
@property (nonatomic, retain) NSNumber * operatable;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) User *inReplyToUser;
@property (nonatomic, retain) Status *targetStatus;
@property (nonatomic, retain) User *targetUser;

+ (Comment *)insertCommentByMe:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Comment *)insertCommentToMe:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Comment *)insertComment:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (Comment *)commentWithID:(NSString *)commentID inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteCommentsToMeInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteCommentsByMeInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteCommentsOfStatus:(Status *)status ManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;

- (BOOL)isEqualToComment:(Comment *)comment;


@end
