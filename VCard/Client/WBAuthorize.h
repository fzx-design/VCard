//
//  WBAuthorize.h
//  VCard
//
//  Created by 海山 叶 on 12-3-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WBRequest.h"

@class WBAuthorize;

@protocol WBAuthorizeDelegate <NSObject>

@required
- (void)authorize:(WBAuthorize *)authorize
didSucceedWithAccessToken:(NSString *)accessToken 
           userID:(NSString *)userID expiresIn:(NSInteger)seconds;

- (void)authorize:(WBAuthorize *)authorize 
 didFailWithError:(NSError *)error;

@end

@interface WBAuthorize : NSObject <WBRequestDelegate> 
{
    
    NSString    *_appKey;
    NSString    *_appSecret;
    
    NSString    *_redirectURI;
    
    WBRequest   *_request;
    
    id<WBAuthorizeDelegate> _delegate;
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, retain) WBRequest *request;
@property (nonatomic, assign) id<WBAuthorizeDelegate> delegate;


- (id)initWithAppKey:(NSString *)theAppKey 
           appSecret:(NSString *)theAppSecret;

- (void)startAuthorizeUsingUserID:(NSString *)userID 
                         password:(NSString *)password;

@end
