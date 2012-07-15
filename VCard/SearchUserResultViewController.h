//
//  SearchUserResultViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-15.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "ProfileRelationTableViewController.h"

@interface SearchUserResultViewController : StackViewPageController

@property (nonatomic, strong) IBOutlet UILabel                      *titleLabel;
@property (nonatomic, strong) ProfileRelationTableViewController    *userListViewController;
@property (nonatomic, strong) NSString                              *searchKey;


@end
