//
//  WBClient.h
//  VCard
//
//  Created by 海山 叶 on 12-3-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WBRequest.h"

typedef enum {
    RepostWeiboTypeCommentNone      = 0,
    RepostWeiboTypeCommentCurrent   = 1,
    RepostWeiboTypeCommentOrigin    = 2,
    RepostWeiboTypeCommentBoth      = 3,
} RepostWeiboType;

@class WBClient;

@protocol WBClientDelegate <NSObject>

@optional

// If you try to log in with logIn or logInUsingUserID method, and
// there is already some authorization info in the Keychain,
// this method will be invoked.
// You may or may not be allowed to continue your authorization,
// which depends on the value of isUserExclusive.
- (void)clientAlreadyLoggedIn:(WBClient *)client;

// Log in successfully.
- (void)clientDidLogIn:(WBClient *)client;

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)client:(WBClient *)client didFailToLogInWithError:(NSError *)error;

// Log out successfully.
- (void)clientDidLogOut:(WBClient *)client;

// When you use the WBClient's request methods,
// you may receive the following four callbacks.
- (void)clientNotAuthorized:(WBClient *)client;
- (void)clientAuthorizeExpired:(WBClient *)client;

- (void)client:(WBClient *)client requestDidFailWithError:(NSError *)error;
- (void)client:(WBClient *)client requestDidSucceedWithResult:(id)result;

@end

typedef void (^WCCompletionBlock)(WBClient *client);

@interface WBClient : NSObject<WBRequestDelegate>
{
    NSString        *_appKey;
    NSString        *_appSecret;
    
    NSString        *_userID;
    NSString        *_accessToken;
    NSTimeInterval  _expireTime;
    
    NSString        *_redirectURI;
    
    // Determine whether user must log out before another logging in.
    BOOL            _isUserExclusive;
    
    WBRequest       *_request;
    
    id<WBClientDelegate> _delegate;
    
    id _responseJSONObject;
    WCCompletionBlock _completionBlock;
    
    BOOL _hasError;
    
}

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, assign) BOOL isUserExclusive;
@property (nonatomic, retain) WBRequest *request;
@property (nonatomic, assign) id<WBClientDelegate> delegate;

@property (nonatomic, copy) WCCompletionBlock preCompletionBlock;

@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, retain) id responseJSONObject;

- (void)setCompletionBlock:(void (^)(WBClient* client))completionBlock;
- (WCCompletionBlock)completionBlock;

+ (id)client;
+ (id)currentUserID;
+ (BOOL)authorized;

- (id)init;
- (void)logOut;
- (BOOL)isLoggedIn;
- (BOOL)isAuthorizeExpired;


- (void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image;
- (void)sendWeiBoWithText:(NSString *)text 
                    image:(UIImage *)image
               longtitude:(NSString *)longtitude 
                 latitude:(NSString *)latitude;
- (void)sendRepostWithText:(NSString *)text
             weiboID:(NSString *)originID 
               commentType:(RepostWeiboType)type;
- (void)sendWeiboCommentWithText:(NSString *)text
              weiboID:(NSString *)originID 
               commentOrigin:(BOOL)repost;
- (void)sendReplyCommentWithText:(NSString *)text
                   weiboID:(NSString *)originID
                         replyID:(NSString *)replyID
                   commentOrigin:(BOOL)commentOrigin;

- (void)authorizeUsingUserID:(NSString *)userID password:(NSString *)password;
- (void)getUser:(NSString *)userID_;
- (void)getUserByScreenName:(NSString *)screenName_;
- (void)getFriendsTimelineSinceID:(NSString *)sinceID 
                            maxID:(NSString *)maxID 
                   startingAtPage:(int)page 
                            count:(int)count
                          feature:(int)feature;
- (void)getUserTimeline:(NSString *)userID 
				SinceID:(NSString *)sinceID 
                  maxID:(NSString *)maxID 
		 startingAtPage:(int)page 
				  count:(int)count
                feature:(int)feature;
- (void)getAddressFromGeoWithCoordinate:(NSString *)coordinate;

- (void)getCommentOfStatus:(NSString *)statusID
                    maxID:(NSString *)maxID
                    count:(int)count
             authorFilter:(BOOL)filter;

- (void)getRepostOfStatus:(NSString *)statusID
                    maxID:(NSString *)maxID
                    count:(int)count
             authorFilter:(BOOL)filter;

- (void)getCommentsToMeSinceID:(NSString *)sinceID
                         maxID:(NSString *)maxID
                          page:(int)page
                         count:(int)count;

- (void)getCommentsByMeSinceID:(NSString *)sinceID
                         maxID:(NSString *)maxID
                          page:(int)page
                         count:(int)count;

- (void)getMentionsSinceID:(NSString *)sinceID 
					 maxID:(NSString *)maxID 
					  page:(int)page 
					 count:(int)count;

- (void)getFriendsOfUser:(NSString *)userID cursor:(int)cursor count:(int)count;
- (void)getFollowersOfUser:(NSString *)userID cursor:(int)cursor count:(int)count;

- (void)getAtUsersSuggestions:(NSString *)q;
- (void)getTopicSuggestions:(NSString *)q;

@end
