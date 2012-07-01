//
//  FriendProfileViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserProfileViewController.h"

@interface FriendProfileViewController : UserProfileViewController <UIActionSheetDelegate> {
    UIButton *_relationshipButton;
    BOOL _loading;
}

@property (nonatomic, strong) IBOutlet UIButton *relationshipButton;
@property (nonatomic, strong) IBOutlet UIButton *moreInfoButton;
@property (nonatomic, strong) IBOutlet UIButton *mentionButton;

- (IBAction)didClickRelationButton:(UIButton *)sender;
- (IBAction)didClickMentionButton:(UIButton *)sender;

@end
