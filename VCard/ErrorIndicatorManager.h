//
//  ErrorIndicatorManager.h
//  VCard
//
//  Created by 王 紫川 on 12-7-16.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorIndicatorManager : NSObject <UIAlertViewDelegate>

+ (ErrorIndicatorManager *)sharedManager;

@end
