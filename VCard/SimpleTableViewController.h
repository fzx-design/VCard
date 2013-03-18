//
//  SimpleTableViewController.h
//  VCard
//
//  Created by Emerson on 13-3-18.
//  Copyright (c) 2013年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#define LOGIN_VIEW_APPEAR_ANIMATION_DURATION  0.5f

@interface SimpleTableViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *listData;

@end
