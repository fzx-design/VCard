//
//  SelfProfileViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserProfileViewController.h"
#import "MotionsViewController.h"

@interface SelfProfileViewController : UserProfileViewController<MotionsViewControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> 

@property (nonatomic, weak) IBOutlet UIButton *changeAvatarButton;
@property (nonatomic, weak) IBOutlet UIButton *checkCommentButton;
@property (nonatomic, weak) IBOutlet UIButton *checkMentionButton;
@property (nonatomic, weak) IBOutlet UIButton *accountSettingButton;
@property (nonatomic, assign) BOOL shouldShowFollowerList;

- (IBAction)didClickCheckCommentButton:(UIButton *)sender;
- (IBAction)didClickCheckMentionButton:(UIButton *)sender;
- (IBAction)didClickAccountSettingButton:(UIButton *)sender;
- (IBAction)didClickChangeAvatarButton:(UIButton *)sender;

@end
