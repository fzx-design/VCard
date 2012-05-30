//
//  ProfileRelationTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshableCoreDataTableViewController.h"

typedef enum {
    RelationshipViewTypeFriends,
    RelationshipViewTypeFollowers,
} RelationshipViewType;

@class User;

@interface ProfileRelationTableViewController : RefreshableCoreDataTableViewController {
    int _stackPageIndex;
    
    User *_user;
    RelationshipViewType _type;
    BaseLayoutView *_backgroundView;
}


@property (nonatomic, assign) int stackPageIndex;

@property (nonatomic, strong) User *user;
@property (nonatomic, assign) RelationshipViewType type;
@property (nonatomic, retain) BaseLayoutView *backgroundView;

- (void)refresh;
- (void)loadMore;

@end
