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
    RelationshipViewTypeSelfFriends,
    RelationshipViewTypeSelfFollowers,
    RelationshipViewTypeUserFriends,
    RelationshipViewTypeUserFollowers,
    RelationshipViewTypeSearch,
} RelationshipViewType;


@interface ProfileRelationTableViewController : RefreshableCoreDataTableViewController {
    RelationshipViewType _type;
}

@property (nonatomic, assign) RelationshipViewType  type;
@property (nonatomic, strong) NSString              *searchKey;

- (void)refresh;
- (void)loadMore;

@end
