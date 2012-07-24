//
//  Status.h
//  VCard
//
//  Created by 海山 叶 on 12-7-20.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kStatusTypeNone     @"kStatusTypeNone"
#define kStatusTypeNormal   @"kStatusTypeNormal"
#define kStatusTypeMedia    @"kStatusTypeMedia"
#define kStatusTypeVote     @"kStatusTypeVote"

@class Comment, Status, User;

@interface Status : NSManagedObject

@property (nonatomic, retain) NSString * bmiddlePicURL;
@property (nonatomic, retain) NSNumber * cardSizeCardHeight;
@property (nonatomic, retain) NSNumber * cardSizeImageHeight;
@property (nonatomic, retain) NSString * commentsCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSNumber * featureMusic;
@property (nonatomic, retain) NSNumber * featureOrigin;
@property (nonatomic, retain) NSNumber * featurePic;
@property (nonatomic, retain) NSNumber * featureVideo;
@property (nonatomic, retain) NSNumber * forCastView;
@property (nonatomic, retain) NSNumber * forTableView;
@property (nonatomic, retain) NSNumber * isMentioned;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * mediaLink;
@property (nonatomic, retain) NSNumber * operatable;
@property (nonatomic, retain) id operatedBy;
@property (nonatomic, retain) NSString * originalPicURL;
@property (nonatomic, retain) NSString * repostsCount;
@property (nonatomic, retain) NSString * searchKey;
@property (nonatomic, retain) NSString * searchString;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * statusID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * thumbnailPicURL;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) id cacheTextLabel;
@property (nonatomic, retain) id cacheDateString;
@property (nonatomic, retain) id cacheLinks;
@property (nonatomic, retain) NSNumber * cached;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) User *favoritedBy;
@property (nonatomic, retain) User *isFriendsStatusOf;
@property (nonatomic, retain) NSSet *repostedBy;
@property (nonatomic, retain) Status *repostStatus;

- (BOOL)isEqualToStatus:(Status *)status;
+ (Status *)insertStatus:(NSDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (Status *)statusWithID:(NSString *)statudID inManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (void)deleteObjectsEarlierThan:(NSDate *)updateDate inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteAllObjectsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteRepostsOfStatus:(Status *)status ManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (int)countOfStatuseInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllTempStatusesInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteObject:(Status *)object inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteStatusWithID:(NSString *)statusID inManagedObjectContext:(NSManagedObjectContext *)context withObject:(id)object;
+ (void)deleteStatusesOfUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (void)deleteStatusesWithSearchKey:(NSString *)searchKey InManagedObjectContext:(NSManagedObjectContext *)context withOperatingObject:(id)object;
+ (void)deleteMentionStatusesInManagedObjectContext:(NSManagedObjectContext *)context;
- (BOOL)hasLocationInfo;
- (BOOL)locationInfoAlreadyLoaded;

+ (NSArray *)getTempStatusCount:(NSManagedObjectContext *)context;
+ (NSArray *)getUndeletableStatusCount:(NSManagedObjectContext *)context;

@end

@interface Status (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addRepostedByObject:(Status *)value;
- (void)removeRepostedByObject:(Status *)value;
- (void)addRepostedBy:(NSSet *)values;
- (void)removeRepostedBy:(NSSet *)values;

@end
