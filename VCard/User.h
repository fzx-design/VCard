//
//  User.h
//  VCard
//
//  Created by Gabriel Yeah on 12-7-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Conversation, Status, User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * blogURL;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * domainURL;
@property (nonatomic, retain) NSString * favouritesCount;
@property (nonatomic, retain) id favouritesIDs;
@property (nonatomic, retain) NSString * followersCount;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSNumber * followMe;
@property (nonatomic, retain) NSString * friendsCount;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * largeAvatarURL;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * operatable;
@property (nonatomic, retain) id operatedBy;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * selfDescription;
@property (nonatomic, retain) NSString * statusesCount;
@property (nonatomic, retain) NSNumber * unreadCommentCount;
@property (nonatomic, retain) NSNumber * unreadFollowingCount;
@property (nonatomic, retain) NSNumber * unreadMentionComment;
@property (nonatomic, retain) NSNumber * unreadMentionCount;
@property (nonatomic, retain) NSNumber * unreadMessageCount;
@property (nonatomic, retain) NSNumber * unreadStatusCount;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSNumber * verified;
@property (nonatomic, retain) NSNumber * verifiedType;
@property (nonatomic, retain) NSString * currentUserID;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *commentsToMe;
@property (nonatomic, retain) Conversation *conversation;
@property (nonatomic, retain) NSSet *favorites;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSSet *friendsStatuses;
@property (nonatomic, retain) NSSet *statuses;

+ (User *)getCurrentUserWithID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (User *)insertCurrentUser:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context;
+ (User *)insertUser:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object  operatableType:(int)type;
+ (User *)userWithID:(NSString *)userID inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object operatableType:(int)type;
+ (void)deleteFriendsOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (void)deleteFollowersOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (void)deleteUsersInManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (void)deleteRedundantUsersInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteCommentRelatedUsersInManagedObjectContext:(NSManagedObjectContext *)context operatableType:(int)type;
+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context;
- (BOOL)isEqualToUser:(User *)user;
- (VerifiedType)verifiedTypeOfUser;

+ (void)deleteAllTempUsersInManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)getTempUserCount:(NSManagedObjectContext *)context;
+ (NSArray *)getUndeletableUserCount:(NSManagedObjectContext *)context;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addCommentsToMeObject:(Comment *)value;
- (void)removeCommentsToMeObject:(Comment *)value;
- (void)addCommentsToMe:(NSSet *)values;
- (void)removeCommentsToMe:(NSSet *)values;

- (void)addFavoritesObject:(Status *)value;
- (void)removeFavoritesObject:(Status *)value;
- (void)addFavorites:(NSSet *)values;
- (void)removeFavorites:(NSSet *)values;

- (void)addFollowersObject:(User *)value;
- (void)removeFollowersObject:(User *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFriendsObject:(User *)value;
- (void)removeFriendsObject:(User *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

- (void)addFriendsStatusesObject:(Status *)value;
- (void)removeFriendsStatusesObject:(Status *)value;
- (void)addFriendsStatuses:(NSSet *)values;
- (void)removeFriendsStatuses:(NSSet *)values;

- (void)addStatusesObject:(Status *)value;
- (void)removeStatusesObject:(Status *)value;
- (void)addStatuses:(NSSet *)values;
- (void)removeStatuses:(NSSet *)values;

@end
