//
//  FriendProfileViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserProfileViewController.h"

@interface FriendProfileViewController : UserProfileViewController {
    UIButton *_relationshipButton;
}

@property (nonatomic, strong) IBOutlet UIButton *relationshipButton;
@property (nonatomic, strong) IBOutlet UIButton *moreInfoButton;

@end
