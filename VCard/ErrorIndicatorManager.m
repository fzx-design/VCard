//
//  ErrorIndicatorManager.m
//  VCard
//
//  Created by 王 紫川 on 12-7-16.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ErrorIndicatorManager.h"
#import "ErrorIndicatorViewController.h"
#import "LoginViewController.h"
#import "NSNotificationCenter+Addition.h"
#import "NSUserDefaults+Addition.h"
#import "CoreDataTableViewController.h"
#import "WBClient.h"

static ErrorIndicatorManager *managerInstance = nil;

@interface ErrorIndicatorManager() {
    BOOL _handlingTokenFailureSituation;
}

@end

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

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        [[[LoginViewController alloc] initWithType:LoginViewControllerTypeDeleteCurrentUser] show];
    } else {
        UserAccountInfo *accountInfo = [NSUserDefaults getUserAccountInfoWithUserID:[CoreDataViewController getCurrentUser].userID];
        NSString *newPassword = [alertView textFieldAtIndex:0].text;
        
        WBClient *client = [WBClient client];
        [client setCompletionBlock:^(WBClient *client) {
            if (!client.hasError) {
                NSLog(@"login step 3 succeeded(wrong password expired)");
                _handlingTokenFailureSituation = NO;
                [NSUserDefaults insertUserAccountInfoWithUserID:accountInfo.userID account:accountInfo.account password:newPassword];
            } else {
                NSLog(@"login step 3 failed(wrong password expired)");
                [self handleWrongPasswordSituation];
            }
        }];
        [client authorizeUsingUserID:accountInfo.account password:newPassword];
    }
}

#pragma mark - Token methods

- (void)handleWrongPasswordSituation {
    _handlingTokenFailureSituation = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新浪微博"
                                                    message:[NSString stringWithFormat:@"%@，您的密码可能已经更改，请重新输入。", [CoreDataViewController getCurrentUser].screenName]
                                                   delegate:self
                                          cancelButtonTitle:@"取消" 
                                          otherButtonTitles:@"继续", nil];

    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

- (void)handleTokenExpireSituation {
    _handlingTokenFailureSituation = YES;
    
    UserAccountInfo *accountInfo = [NSUserDefaults getUserAccountInfoWithUserID:[CoreDataViewController getCurrentUser].userID];
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSLog(@"login step 3 succeeded(token expired)");
            _handlingTokenFailureSituation = NO;
        } else {
            NSLog(@"login step 3 failed(token expired)");
            [self handleWrongPasswordSituation];
        }
    }];
    
    [client authorizeUsingUserID:accountInfo.account password:accountInfo.password];
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
                errorMessage = @"无法发表重复内容";
                break;
            case 20016:
                errorMessage = @"发送速度过快";
                break;
            case 20003:
                errorMessage = @"用户不存在";
                break;
            case 20506:
                errorMessage = @"已经关注";
                break;
            case 21315:
            case 21327:
                if(!_handlingTokenFailureSituation)
                    [self handleTokenExpireSituation];
                return;
            case 21314:
            case 21316:
            case 21317:
                if(!_handlingTokenFailureSituation)
                    [self handleWrongPasswordSituation];
                return;
            case 20034:
                errorMessage = @"用户被锁定";
                break;
            case 20704:
                errorMessage = @"已经收藏";
                break;
            case 20705:
                errorMessage = @"还未收藏";
                break;
            case 20101:
                errorMessage = @"不存在的微博";
                break;
            default:
                break;
        }
        
        if(errorMessage == nil) {
            if([requsetAPI isEqualToString:@"/oauth2/access_token"]) {
                errorMessage = @"用户名或密码错误";
            }
        }
        if(!_handlingTokenFailureSituation)
            [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureFailure contentText:errorMessage];
    }
}

@end
