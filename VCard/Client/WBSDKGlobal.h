//
//  Header.h
//  VCard
//
//  Created by 海山 叶 on 12-3-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#define kWBSDKErrorDomain           @"WeiBoSDKErrorDomain"
#define kWBSDKErrorCodeKey          @"WeiBoSDKErrorCodeKey"

#define kWBSDKAPIDomain             @"https://api.weibo.com/2/"

#define kWBAuthorizeURL             @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL           @"https://api.weibo.com/oauth2/access_token"

#define kWBSDKAppKey                @"1965726745"
#define kWBSDKAppSecret             @"55377ca138fa49b63b7767778ca1fb5a"

#define kWBSDKAdvancedAppKey        @"82966982"
#define kWBSDKAdvancedAppSecret     @"72d4545a28a46a6f329c4f2b1e949e6a"

typedef enum
{
	kWBErrorCodeInterface	= 100,
	kWBErrorCodeSDK         = 101,
}WBErrorCode;

typedef enum
{
	kWBSDKErrorCodeParseError       = 200,
	kWBSDKErrorCodeRequestError     = 201,
	kWBSDKErrorCodeAccessError      = 202,
	kWBSDKErrorCodeAuthorizeError	= 203,
}WBSDKErrorCode;

