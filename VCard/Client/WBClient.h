//
//  WBClient.h
//  VCard
//
//  Created by 海山 叶 on 12-3-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WBRequest.h"
#import "WBAuthorize.h"

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

@interface WBClient : NSObject<WBAuthorizeDelegate, WBRequestDelegate>
{
    NSString        *appKey;
    NSString        *appSecret;
    
    NSString        *userID;
    NSString        *accessToken;
    NSTimeInterval  expireTime;
    
    NSString        *redirectURI;
    
    // Determine whether user must log out before another logging in.
    BOOL            isUserExclusive;
    
    WBRequest       *request;
    WBAuthorize     *authorize;
    
    id<WBClientDelegate> delegate;
    
    UIViewController *rootViewController;
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, assign) BOOL isUserExclusive;
@property (nonatomic, retain) WBRequest *request;
@property (nonatomic, retain) WBAuthorize *authorize;
@property (nonatomic, assign) id<WBClientDelegate> delegate;
@property (nonatomic, assign) UIViewController *rootViewController;

// Initialize an instance with the AppKey and the AppSecret you have for your client.
- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;

// Log in using OAuth Client authorization.
// If succeed, engineDidLogIn will be called.
- (void)logInUsingUserID:(NSString *)theUserID password:(NSString *)thePassword;

// Log out.
// If succeed, engineDidLogOut will be called.
- (void)logOut;

// Check if user has logged in, or the authorization is expired.
- (BOOL)isLoggedIn;
- (BOOL)isAuthorizeExpired;

// @methodName: The interface you are trying to visit, exp, "statuses/public_timeline.json" for the newest timeline.
// See 
// http://open.weibo.com/wiki/API%E6%96%87%E6%A1%A3_V2
// for more details.
// @httpMethod: "GET" or "POST".
// @params: A dictionary that contains your request parameters.
// @postDataType: "GET" for kWBRequestPostDataTypeNone, "POST" for kWBRequestPostDataTypeNormal or kWBRequestPostDataTypeMultipart.
// @httpHeaderFields: A dictionary that contains HTTP header information.
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields;

// Send a Weibo, to which you can attach an image.
- (void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image;

@end
