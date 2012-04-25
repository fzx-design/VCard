//
//  WBClient.m
//  VCard
//
//  Created by 海山 叶 on 12-3-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WBClient.h"
#import "SFHFKeychainUtils.h"
#import "WBSDKGlobal.h"
#import "WBUtil.h"

#define kWBURLSchemePrefix              @"WB_"

#define kWBKeychainServiceNameSuffix    @"_WeiBoServiceName"
#define kWBKeychainUserID               @"WeiBoUserID"
#define kWBKeychainAccessToken          @"WeiBoAccessToken"
#define kWBKeychainExpireTime           @"WeiBoExpireTime"

static NSString *UserID = @"";

@interface WBClient (Private)

- (NSString *)urlSchemeString;

- (void)saveAuthorizeDataToKeychain;
- (void)readAuthorizeDataFromKeychain;
- (void)deleteAuthorizeDataInKeychain;

@end

@implementation WBClient

@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize userID = _userID;
@synthesize accessToken = _accessToken;
@synthesize expireTime = _expireTime;
@synthesize redirectURI = _redirectURI;
@synthesize isUserExclusive = isUserExclusive;
@synthesize request = _request;
@synthesize authorize = _authorize;
@synthesize delegate = _delegate;
@synthesize hasError = _hasError;

@synthesize preCompletionBlock = _preCompletionBlock;

@synthesize responseJSONObject = _responseJSONObject;

#pragma mark - WBEngine Life Circle

+ (id)client
{
    //autorelease intentially ommited here
    return [[WBClient alloc] init]; 
}

+ (id)CurrentUserID
{
    return UserID;
}

- (id)init
{
    if (self = [super init]) {
        _appKey = kWBSDKAppKey;
        _appSecret = kWBSDKAppSecret;
        _redirectURI = @"http://";
        _hasError = NO;
        
        isUserExclusive = NO;
        
        [self readAuthorizeDataFromKeychain];
    }
    
    return self;
}

- (void)dealloc
{
    [_appKey release], _appKey = nil;
    [_appSecret release], _appSecret = nil;
    
    [_userID release], _userID = nil;
    [_accessToken release], _accessToken = nil;
    
    [_redirectURI release], _redirectURI = nil;
    
    [_request setDelegate:nil];
    [_request disconnect];
    [_request release], _request = nil;
    
    [_authorize setDelegate:nil];
    [_authorize release], _authorize = nil;
    
    _delegate = nil;
    
    [super dealloc];
}

#pragma mark - WBEngine Private Methods

- (NSString *)urlSchemeString
{
    return [NSString stringWithFormat:@"%@%@", kWBURLSchemePrefix, _appKey];
}

- (void)saveAuthorizeDataToKeychain
{
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
    [SFHFKeychainUtils storeUsername:kWBKeychainUserID andPassword:_userID forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:kWBKeychainAccessToken andPassword:_accessToken forServiceName:serviceName updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:kWBKeychainExpireTime andPassword:[NSString stringWithFormat:@"%lf", _expireTime] forServiceName:serviceName updateExisting:YES error:nil];
}

- (void)readAuthorizeDataFromKeychain
{
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
    self.userID = [SFHFKeychainUtils getPasswordForUsername:kWBKeychainUserID andServiceName:serviceName error:nil];
    self.accessToken = [SFHFKeychainUtils getPasswordForUsername:kWBKeychainAccessToken andServiceName:serviceName error:nil];
    self.expireTime = [[SFHFKeychainUtils getPasswordForUsername:kWBKeychainExpireTime andServiceName:serviceName error:nil] doubleValue];
}

- (void)deleteAuthorizeDataInKeychain
{
    self.userID = nil;
    self.accessToken = nil;
    self.expireTime = 0;
    
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kWBKeychainServiceNameSuffix];
    [SFHFKeychainUtils deleteItemForUsername:kWBKeychainUserID andServiceName:serviceName error:nil];
	[SFHFKeychainUtils deleteItemForUsername:kWBKeychainAccessToken andServiceName:serviceName error:nil];
	[SFHFKeychainUtils deleteItemForUsername:kWBKeychainExpireTime andServiceName:serviceName error:nil];
}

#pragma mark - WBEngine Public Methods

- (void)setCompletionBlock:(void (^)(WBClient* client))completionBlock
{
    [_completionBlock autorelease];
    _completionBlock = [completionBlock copy];
}

- (void)setPreCompletionBlock:(WCCompletionBlock)preCompletionBlock
{
    [_preCompletionBlock autorelease];
    _preCompletionBlock = [preCompletionBlock copy];
}

- (WCCompletionBlock)completionBlock
{
    return _completionBlock;
}

- (void)reportCompletion
{
    if (_preCompletionBlock) {
        _preCompletionBlock(self);
    }
    if (_completionBlock) {
        _completionBlock(self);
    }
}


#pragma mark Authorization


- (void)logOut
{
    [self deleteAuthorizeDataInKeychain];
    
    if ([_delegate respondsToSelector:@selector(engineDidLogOut:)]) {
        [_delegate clientDidLogOut:self];
    }
}

- (BOOL)isLoggedIn
{
    //    return userID && accessToken && refreshToken;
    return _userID && _accessToken && (_expireTime > 0);
}

- (BOOL)isAuthorizeExpired
{
    if ([[NSDate date] timeIntervalSince1970] > _expireTime)
    {
        // force to log out
        [self deleteAuthorizeDataInKeychain];
        return YES;
    }
    return NO;
}

- (void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
    //NSString *sendText = [text URLEncodedString];
    
	[params setObject:(text ? text : @"") forKey:@"status"];
	
    if (image)
    {
		[params setObject:image forKey:@"pic"];
        
        [self loadRequestWithMethodName:@"statuses/upload.json"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kWBRequestPostDataTypeMultipart
                       httpHeaderFields:nil];
    }
    else
    {
        [self loadRequestWithMethodName:@"statuses/update.json"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kWBRequestPostDataTypeNormal
                       httpHeaderFields:nil];
    }
}

#pragma mark - WBAuthorizeDelegate Methods

- (void)authorizeUsingUserID:(NSString *)userID password:(NSString *)password
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_appKey, @"client_id",
                            _appSecret, @"client_secret",
                            @"password", @"grant_type",
                            _redirectURI, @"redirect_uri",
                            userID, @"username",
                            password, @"password", nil];
    
    
    [self setCompletionBlock:^(WBClient *client) {
        
        if ([self.responseJSONObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary*)client.responseJSONObject;
            
            self.accessToken = [dict objectForKey:@"access_token"];
            self.userID = [dict objectForKey:@"uid"];
            self.expireTime = [[NSDate date] timeIntervalSince1970] + [[dict objectForKey:@"expires_in"] intValue];
            
            [self saveAuthorizeDataToKeychain];
        }
    }];
    
    [_request disconnect];
    
    self.request = [WBRequest requestWithURL:kWBAccessTokenURL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kWBRequestPostDataTypeNormal
                            httpHeaderFields:nil 
                                    delegate:self];
    
    
    [_request connect];
}


#pragma mark Request

- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
{
    // Step 1.
    // Check if the user has been logged in.
	if (![self isLoggedIn]) {
        if ([_delegate respondsToSelector:@selector(engineNotAuthorized:)]) {
            [_delegate clientNotAuthorized:self];
        }
        return;
	}
    
	// Step 2.
    // Check if the access token is expired.
    if ([self isAuthorizeExpired]) {
        if ([_delegate respondsToSelector:@selector(engineAuthorizeExpired:)]) {
            [_delegate clientAuthorizeExpired:self];
        }
        return;
    }
    
    [_request disconnect];
    
    self.request = [WBRequest requestWithAccessToken:_accessToken
                                                 url:[NSString stringWithFormat:@"%@%@", kWBSDKAPIDomain, methodName]
                                          httpMethod:httpMethod
                                              params:params
                                        postDataType:postDataType
                                    httpHeaderFields:httpHeaderFields
                                            delegate:self];
	
	[_request connect];
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([_delegate respondsToSelector:@selector(engine:requestDidSucceedWithResult:)]) {
        [_delegate client:self requestDidSucceedWithResult:result];
    }
    
    self.responseJSONObject = result;
    
    [self reportCompletion];
    
    [self autorelease];
}

- (void)request:(WBRequest *)request didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(engine:requestDidFailWithError:)]) {
        [_delegate client:self requestDidFailWithError:error];
    }
    
    self.hasError = YES;
    
    [self reportCompletion];
    
    [self autorelease];
}


@end
