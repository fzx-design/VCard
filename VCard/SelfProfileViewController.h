//
//  SelfProfileViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserProfileViewController.h"

@interface SelfProfileViewController : UserProfileViewController {
    
    UIButton *_changeAvatarButton;
    UIButton *_checkCommentButton;
    UIButton *_checkMentionButton;
}


@property (nonatomic, strong) IBOutlet UIButton *changeAvatarButton;
@property (nonatomic, strong) IBOutlet UIButton *checkCommentButton;
@property (nonatomic, strong) IBOutlet UIButton *checkMentionButton;
@property (nonatomic, strong) IBOutlet UIButton *accountSettingButton;
@property (nonatomic, assign) BOOL shouldShowFollowerList;

- (IBAction)didClickCheckCommentButton:(id)sender;
- (IBAction)didClickCheckMentionButton:(id)sender;

@end
