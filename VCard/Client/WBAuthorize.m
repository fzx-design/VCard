//
//  WBAuthorize.m
//  VCard
//
//  Created by 海山 叶 on 12-3-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WBAuthorize.h"
#import "WBRequest.h"
#import "WBSDKGlobal.h"

#define kWBAuthorizeURL     @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL   @"https://api.weibo.com/oauth2/access_token"

@interface WBAuthorize (Private)

- (void)dismissModalViewController;
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;
- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password;

@end

@implementation WBAuthorize

@synthesize appKey;
@synthesize appSecret;
@synthesize redirectURI;
@synthesize request;
@synthesize rootViewController;
@synthesize delegate;

#pragma mark - WBAuthorize Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init])
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
    }
    
    return self;
}

- (void)dealloc
{
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    
    [redirectURI release], redirectURI = nil;
    
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    
    rootViewController = nil;
    delegate = nil;
    
    [super dealloc];
}

#pragma mark - WBAuthorize Private Methods

- (void)dismissModalViewController
{
    [rootViewController dismissModalViewControllerAnimated:YES];
}

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
                            appSecret, @"client_secret",
                            @"authorization_code", @"grant_type",
                            redirectURI, @"redirect_uri",
                            code, @"code", nil];
    [request disconnect];
    
    self.request = [WBRequest requestWithURL:kWBAccessTokenURL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kWBRequestPostDataTypeNormal
                            httpHeaderFields:nil 
                                    delegate:self];
    
    [request connect];
}

- (void)requestAccessTokenWithUserID:(NSString *)userID password:(NSString *)password
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
                            appSecret, @"client_secret",
                            @"password", @"grant_type",
                            redirectURI, @"redirect_uri",
                            userID, @"username",
                            password, @"password", nil];
    
    [request disconnect];
    
    self.request = [WBRequest requestWithURL:kWBAccessTokenURL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kWBRequestPostDataTypeNormal
                            httpHeaderFields:nil 
                                    delegate:self];
    
    [request connect];
}

#pragma mark - WBAuthorize Public Methods

- (void)startAuthorizeUsingUserID:(NSString *)userID password:(NSString *)password
{
    [self requestAccessTokenWithUserID:userID password:password];
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)theRequest didFinishLoadingWithResult:(id)result
{
    BOOL success = NO;
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        
        NSString *token = [dict objectForKey:@"access_token"];
        NSString *userID = [dict objectForKey:@"uid"];
        NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
        
        success = token && userID;
        
        if (success && [delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)])
        {
            [delegate authorize:self didSucceedWithAccessToken:token userID:userID expiresIn:seconds];
        }
    }
    
    // should not be possible
    if (!success && [delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        NSError *error = [NSError errorWithDomain:kWBSDKErrorDomain 
                                             code:kWBErrorCodeSDK 
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kWBSDKErrorCodeAuthorizeError] 
                                                                              forKey:kWBSDKErrorCodeKey]];
        [delegate authorize:self didFailWithError:error];
    }
}

- (void)request:(WBRequest *)theReqest didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        [delegate authorize:self didFailWithError:error];
    }
}

@end
