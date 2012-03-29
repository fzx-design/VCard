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

