//
//  GroupInfoTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-20.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface GroupInfoTableViewController : CoreDataTableViewController <UIPopoverControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary   *chosenDictionary;
@property (nonatomic, strong) NSDictionary          *originChosenDictionary;
@property (nonatomic, strong) NSString              *userID;

+ (void)showGroupInfoOfUser:(NSString *)userID fromRect:(CGRect)rect inView:(UIView *)view;

@end
