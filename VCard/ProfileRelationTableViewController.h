//
//  ProfileRelationTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

typedef enum {
    RelationshipViewTypeFriends,
    RelationshipViewTypeFollowers,
} RelationshipViewType;

@class User;

@interface ProfileRelationTableViewController : CoreDataTableViewController {
    User *_user;
    RelationshipViewType _type;
    
    int _stackPageIndex;
}

@property (nonatomic, strong) User *user;
@property (nonatomic, assign) RelationshipViewType type;

@property (nonatomic, assign) int stackPageIndex;

@end
