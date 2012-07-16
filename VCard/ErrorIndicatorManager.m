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

static ErrorIndicatorManager *managerInstance;

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
        [NSNotificationCenter registerChangeCurrentUserNotificationWithSelector:@selector(handleWBClientNotification:) target:self];
    }
    return self;
}

#pragma mark - Handle notification

- (void)handleWBClientNotification:(NSNotification *)notification {
    NSError *error = notification.object;
    NSString *errorMessage = nil;
    if(error.code < 0) {
        [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureFailure contentText:@"网络错误"];
    } else {
        switch (error.code) {
            case 21302:
                errorMessage = @"用户名或密码错误";
                break;
            default:
                break;
        }
        [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureFailure contentText:errorMessage];
    }
}

@end
