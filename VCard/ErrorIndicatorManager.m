//
//  ErrorIndicatorManager.m
//  VCard
//
//  Created by 王 紫川 on 12-7-16.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ErrorIndicatorManager.h"
#import "ErrorIndicatorViewController.h"
#import "NSNotificationCenter+Addition.h"

static ErrorIndicatorManager *managerInstance = nil;

@implementation ErrorIndicatorManager

+ (ErrorIndicatorManager *)sharedManager {
    if(!managerInstance) {
        managerInstance = [[ErrorIndicatorManager alloc] init];
    }
    return managerInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        [NSNotificationCenter registerWBClientErrorNotificationWithSelector:@selector(handleWBClientNotification:) target:self];
    }
    return self;
}

#pragma mark - Handle notification

- (void)handleWBClientNotification:(NSNotification *)notification {
    NSError *error = notification.object;
    NSString *errorMessage = nil;
    if(error.code < 0) {
        [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeConnectFailure contentText:nil];
    } else {
        NSNumber *weiboErrorCode = [error.userInfo objectForKey:@"error_code"];
        NSString *requsetAPI = [error.userInfo objectForKey:@"request"];
        NSLog(@"weibo error code %d, request %@", weiboErrorCode.intValue, requsetAPI);
        switch (weiboErrorCode.intValue) {
            case 21302:
                errorMessage = @"用户名或密码错误";
                break;
            case 20017:
            case 20019:
                errorMessage = @"发表重复内容";
                break;
            case 20016:
                errorMessage = @"发送速度过快";
                break;
            default:
                break;
        }
        
        if(errorMessage == nil) {
            if([requsetAPI isEqualToString:@"/oauth2/access_token"]) {
                errorMessage = @"用户名或密码错误";
            }
        }
        
        [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureFailure contentText:errorMessage];
    }
}

@end
