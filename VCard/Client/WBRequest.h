//
//  WBRequest.h
//  VCard
//
//  Created by 海山 叶 on 12-3-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    kWBRequestPostDataTypeNone,
	kWBRequestPostDataTypeNormal,			// for normal data post, such as "user=name&password=psd"
	kWBRequestPostDataTypeMultipart,        // for uploading images and files.
} WBRequestPostDataType;


@class WBRequest;

@protocol WBRequestDelegate <NSObject>

@optional

- (void)request:(WBRequest *)request didReceiveResponse:(NSURLResponse *)response;

- (void)request:(WBRequest *)request didReceiveRawData:(NSData *)data;

- (void)request:(WBRequest *)request didFailWithError:(NSError *)error;

- (void)request:(WBRequest *)request didFinishLoadingWithResult:(id)result;

@end

@interface WBRequest : NSObject
{
    NSString                *url;
    NSString                *httpMethod;
    NSDictionary            *params;
    WBRequestPostDataType   postDataType;
    NSDictionary            *httpHeaderFields;
    
    NSURLConnection         *connection;
    NSMutableData           *responseData;
    
    id<WBRequestDelegate>   delegate;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSDictionary *params;
@property WBRequestPostDataType postDataType;
@property (nonatomic, retain) NSDictionary *httpHeaderFields;
@property (nonatomic, assign) id<WBRequestDelegate> delegate;

+ (WBRequest *)requestWithURL:(NSString *)url 
                   httpMethod:(NSString *)httpMethod 
                       params:(NSDictionary *)params
                 postDataType:(WBRequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<WBRequestDelegate>)delegate;

+ (WBRequest *)requestWithAccessToken:(NSString *)accessToken
                                  url:(NSString *)url
                           httpMethod:(NSString *)httpMethod 
                               params:(NSDictionary *)params
                         postDataType:(WBRequestPostDataType)postDataType
                     httpHeaderFields:(NSDictionary *)httpHeaderFields
                             delegate:(id<WBRequestDelegate>)delegate;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;

- (void)connect;
- (void)disconnect;

@end
