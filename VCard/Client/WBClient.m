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

#import "AppDelegate.h"

#define kWBURLSchemePrefix              @"WB_"

#define kWBKeychainServiceNameSuffix    @"_WeiBoServiceName"
#define kWBKeychainUserID               @"WeiBoUserID"
#define kWBKeychainAccessToken          @"WeiBoAccessToken"
#define kWBKeychainExpireTime           @"WeiBoExpireTime"

typedef enum {
    HTTPMethodPost,
    HTTPMethodForm,
    HTTPMethodGet,
} HTTPMethod;

static NSString *UserID = @"";

@interface WBClient()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, assign) HTTPMethod httpMethod;
@property (nonatomic, assign) WBRequestPostDataType postDataType;

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
@synthesize delegate = _delegate;
@synthesize hasError = _hasError;

@synthesize preCompletionBlock = _preCompletionBlock;

@synthesize responseJSONObject = _responseJSONObject;

@synthesize path = _path;
@synthesize params = _params;
@synthesize httpMethod = _httpMethod;
@synthesize postDataType = _postDataType;

#pragma mark - WBEngine Life Circle

+ (id)client
{
    //autorelease intentially ommited here
    return [[WBClient alloc] init]; 
}

+ (id)currentUserID
{
    return UserID;
}

+ (BOOL)authorized
{
    UserID = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultCurrentUserID];
    return UserID != nil;
}

- (id)init
{
    if (self = [super init]) {
        _appKey = kWBSDKAppKey;
        _appSecret = kWBSDKAppSecret;
        _redirectURI = @"http://";
        
        isUserExclusive = NO;
        
        _params = [[NSMutableDictionary alloc] initWithCapacity:10];
        _hasError = NO;
        _httpMethod = HTTPMethodGet;
        _postDataType = kWBRequestPostDataTypeNone;
        
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
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kUserDefaultAuthorized];
    [[NSUserDefaults standardUserDefaults] setValue:_userID forKey:kUserDefaultCurrentUserID];
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
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kUserDefaultAuthorized];
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

- (void)sendWeiBoWithText:(NSString *)text 
                    image:(UIImage *)image
               longtitude:(NSString *)longtitude 
                 latitude:(NSString *)latitude {
    if(image) {
        self.path = @"statuses/upload.json";
        //NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
		[self.params setObject:image forKey:@"pic"];
        self.postDataType = kWBRequestPostDataTypeMultipart;
    } else {
        self.path = @"statuses/update.json";
        self.postDataType = kWBRequestPostDataTypeNormal;
    }
    
    [self.params setObject:(text ? text : @"") forKey:@"status"];
    if(longtitude && latitude) {
        [self.params setObject:longtitude forKey:@"long"];
        [self.params setObject:latitude forKey:@"lat"];
    }
    self.httpMethod = HTTPMethodPost;
    [self loadNormalRequest];
    
}

- (void)sendWeiBoWithText:(NSString *)text image:(UIImage *)image {
    [self sendWeiBoWithText:text image:image longtitude:nil latitude:nil];
}

- (void)getAtUsersSuggestions:(NSString *)q {
    self.path = @"search/suggestions/at_users.json";
    // 0 for friends, 1 for followers
    [self.params setObject:@"0" forKey:@"type"];
    [self.params setObject:q forKey:@"q"];
    [self loadNormalRequest];
}

- (void)getTopicSuggestions:(NSString *)q {
    self.path = @"search/suggestions/statuses.json";
    [self.params setObject:q forKey:@"q"];
    [self loadNormalRequest];
}

- (void)getUser:(NSString *)userID_
{
    self.path = @"users/show.json";
    [self.params setObject:userID_ forKey:@"uid"];
    [self loadNormalRequest];
}

- (void)getUserByScreenName:(NSString *)screenName_
{
    self.path = @"users/show.json";
    [self.params setObject:screenName_ forKey:@"screen_name"];
    [self loadNormalRequest];
}

- (void)authorizeUsingUserID:(NSString *)userID password:(NSString *)password
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_appKey, @"client_id",
                            _appSecret, @"client_secret",
                            @"password", @"grant_type",
                            _redirectURI, @"redirect_uri",
                            userID, @"username",
                            password, @"password", nil];
    
    self.params = params;
    
    [self setPreCompletionBlock:^(WBClient *client) {
        
        if ([self.responseJSONObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary*)client.responseJSONObject;
            
            self.accessToken = [dict objectForKey:@"access_token"];
            self.userID = [dict objectForKey:@"uid"];
            self.expireTime = [[NSDate date] timeIntervalSince1970] + [[dict objectForKey:@"expires_in"] intValue];
            
            UserID = self.userID;
            
            [self saveAuthorizeDataToKeychain];
        }
    }];
    
    [self loadAuthorizeRequest];
}

- (void)getFriendsTimelineSinceID:(NSString *)sinceID 
                            maxID:(NSString *)maxID 
                   startingAtPage:(int)page 
                            count:(int)count
                          feature:(int)feature
{
    self.path = @"statuses/friends_timeline.json";
	
    if (sinceID) {
        [self.params setObject:sinceID forKey:@"since_id"];
    }
    if (maxID) {
        [self.params setObject:maxID forKey:@"max_id"];
    }
    if (page > 0) {
        [self.params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [self.params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    if (feature > 0) {
        [self.params setObject:[NSString stringWithFormat:@"%d", feature] forKey:@"feature"];
    }
    
    [self setPreCompletionBlock:^(WBClient *client) {
        NSDictionary *dict = self.responseJSONObject;
        self.responseJSONObject = [dict objectForKey:@"statuses"];
    }];
    
    [self loadNormalRequest];
}

- (void)getAddressFromGeoWithCoordinate:(NSString *)coordinate
{
    self.path = @"location/geo/geo_to_address.json";
	
    if (coordinate) {
        [self.params setObject:coordinate forKey:@"coordinate"];
    }
    
    [self setPreCompletionBlock:^(WBClient *client) {
        NSDictionary *dict = self.responseJSONObject;
        self.responseJSONObject = [dict objectForKey:@"geos"];
    }];
    
    [self loadNormalRequest];
}

- (void)getFriendsOfUser:(NSString *)userID cursor:(int)cursor count:(int)count
{
    self.path = @"friendships/friends.json";
    if (userID) {
        [self.params setObject:userID forKey:@"uid"];
    }
    if (cursor) {
        [self.params setObject:[NSString stringWithFormat:@"%d", cursor] forKey:@"cursor"];
    }
    if (count) {
        [self.params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    
    [self loadNormalRequest];
}


- (void)getFollowersOfUser:(NSString *)userID cursor:(int)cursor count:(int)count
{
    self.path = @"friendships/followers.json";
    if (userID) {
        [self.params setObject:userID forKey:@"uid"];
    }
    if (cursor) {
        [self.params setObject:[NSString stringWithFormat:@"%d", cursor] forKey:@"cursor"];
    }
    if (count) {
        [self.params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    
    [self loadNormalRequest];
}

- (void)getUserTimeline:(NSString *)userID 
				SinceID:(NSString *)sinceID 
                  maxID:(NSString *)maxID 
		 startingAtPage:(int)page 
				  count:(int)count
                feature:(int)feature
{
    self.path = @"statuses/user_timeline.json";
    [self.params setObject:userID forKey:@"uid"];
	
    if (sinceID) {
        [self.params setObject:sinceID forKey:@"since_id"];
    }
    if (maxID) {
        [self.params setObject:maxID forKey:@"max_id"];
    }
    if (page > 0) {
        [self.params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [self.params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    if (feature > 0) {
        [self.params setObject:[NSString stringWithFormat:@"%d", feature] forKey:@"feature"];
    }
    
    [self loadNormalRequest];
}

#pragma mark Request

- (void)loadNormalRequest
{
    [_request disconnect];
    
    self.request = [WBRequest requestWithAccessToken:_accessToken
                                                 url:[NSString stringWithFormat:@"%@%@", kWBSDKAPIDomain, self.path]
                                          httpMethod:self.httpMethod == HTTPMethodGet ? @"GET" : @"POST"
                                              params:self.params
                                        postDataType:self.postDataType
                                    httpHeaderFields:nil
                                            delegate:self];
	
	[_request connect];
}

- (void)loadAuthorizeRequest
{
    [_request disconnect];
    
    self.request = [WBRequest requestWithURL:kWBAccessTokenURL
                                  httpMethod:@"POST"
                                      params:self.params
                                postDataType:kWBRequestPostDataTypeNormal
                            httpHeaderFields:nil 
                                    delegate:self];
	
	[_request connect];
}   

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)request didFinishLoadingWithResult:(id)result
{
    self.responseJSONObject = result;
    [self reportCompletion];
    [self autorelease];
}

- (void)request:(WBRequest *)request didFailWithError:(NSError *)error
{
    self.hasError = YES;
    [self reportCompletion];
    [self autorelease];
}

@end
