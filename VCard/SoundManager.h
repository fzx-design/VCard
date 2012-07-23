//
//  SoundManager.h
//  VCard
//
//  Created by 王 紫川 on 12-7-23.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundManager : NSObject

+ (id)sharedManager;

- (void)playNewMessageSound;
- (void)playReloadSound;

@end
