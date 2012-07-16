//
//  FriendProfileViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserProfileViewController.h"
#import "PostViewController.h"

@interface FriendProfileViewController : UserProfileViewController <UIActionSheetDelegate, PostViewControllerDelegate> {
    BOOL _loading;
}

@property (nonatomic, weak) IBOutlet UIButton *relationshipButton;
@property (nonatomic, weak) IBOutlet UIButton *moreInfoButton;
@property (nonatomic, weak) IBOutlet UIButton *mentionButton;
@property (nonatomic, weak) IBOutlet UIButton *messageButton;

- (IBAction)didClickRelationButton:(UIButton *)sender;
- (IBAction)didClickMentionButton:(UIButton *)sender;
- (IBAction)didClickMoreInfoButton:(UIButton *)sender;
- (IBAction)didClickMessageButton:(UIButton *)sender;

@end
