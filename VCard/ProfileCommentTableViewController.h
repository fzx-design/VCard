//
//  ProfileCommentTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"
#import "Status.h"

typedef enum {
    ViewingUserTypeAll,
    ViewingUserTypeFollowing,
} ViewingUserType;

@interface ProfileCommentTableViewController : RefreshableCoreDataTableViewController {
    int _nextCursor;
    int _page;
}

@property (nonatomic, strong) Status *status;
@property (nonatomic, assign) ViewingUserType viewingUserType;

@end
