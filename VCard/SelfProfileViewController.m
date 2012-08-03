//
//  SelfProfileViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SelfProfileViewController.h"
#import "SettingViewController.h"
#import "UIApplication+Addition.h"
#import "WBClient.h"
#import "NSNotificationCenter+Addition.h"
#import "ErrorIndicatorViewController.h"

#define MOTIONS_EDIT_ACTION_SHEET_SHOOT_INDEX    0
#define MOTIONS_EDIT_ACTION_SHEET_ALBUM_INDEX    1

typedef enum {
    ActionSheetTypeNone,
    ActionSheetTypeMotions,
    PopoverAlbumImagePicker,
} ActionSheetType;

@interface SelfProfileViewController() {
    ActionSheetType _shouldPresentActionSheetType;
}

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIActionSheet *actionSheet;

@end

@implementation SelfProfileViewController

@synthesize popoverController = _pc;
@synthesize actionSheet = _actionSheet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.user = self.currentUser;
    [super setUpViews];
    if (_shouldShowFollowerList) {
        [self showFollowers:nil];
    } else {
        [self showStatuses:nil];
    }
    [self loadUserAndChangeAvatar];
    
    [ThemeResourceProvider configButtonPaperLight:_accountSettingButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(deviceRotationDidChange:) name:kNotificationNameOrientationChanged object:nil];
    [center addObserver:self selector:@selector(deviceRotationWillChange:) name:kNotificationNameOrientationWillChange object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification handlers

- (void)deviceRotationDidChange:(NSNotification *)notification {
    if(_shouldPresentActionSheetType == ActionSheetTypeMotions)
        [self presentChoosePhotoSourceActionSheet];
    else if(_shouldPresentActionSheetType == PopoverAlbumImagePicker)
        [self showAlbumImagePicker];
    _shouldPresentActionSheetType = ActionSheetTypeNone;
}

- (void)deviceRotationWillChange:(NSNotification *)notification {
    [self dismissPopover];
}

#pragma mark - UI methods 

- (void)showAlbumImagePicker {
    UIPopoverController *pc =  [UIApplication showAlbumImagePickerFromButton:self.changeAvatarButton delegate:self];
    self.popoverController = pc;
}

- (void)presentChoosePhotoSourceActionSheet {
    if(![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        [self showAlbumImagePicker];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:self 
                                     cancelButtonTitle:nil 
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"拍照", @"选取照片",  nil];
    [actionSheet showFromRect:self.changeAvatarButton.bounds inView:self.changeAvatarButton animated:YES];
    self.actionSheet = actionSheet;
}

- (void)dismissPopover {
    if(self.actionSheet) {
        _shouldPresentActionSheetType = ActionSheetTypeMotions;
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
    if(self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
        _shouldPresentActionSheetType = PopoverAlbumImagePicker;
    }
}

#pragma mark - IBActions

- (IBAction)didClickCheckCommentButton:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowSelfCommentList object:@{kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%d", self.pageIndex]}];
}

- (IBAction)didClickCheckMentionButton:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowSelfMentionList object:@{kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%d", self.pageIndex]}];
}

- (IBAction)didClickChangeAvatarButton:(UIButton *)sender {
    [self presentChoosePhotoSourceActionSheet];
}

- (IBAction)didClickAccountSettingButton:(UIButton *)sender {
    SettingViewController *vc = [[SettingViewController alloc] init];
    [vc show];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == MOTIONS_EDIT_ACTION_SHEET_ALBUM_INDEX) {
        [self showAlbumImagePicker];
    } else if(buttonIndex == MOTIONS_EDIT_ACTION_SHEET_SHOOT_INDEX) {
        MotionsViewController *vc = [[MotionsViewController alloc] initWithImage:nil useForAvatar:YES];
        vc.delegate = self;
        [vc show];
    }
    self.actionSheet = nil;
}

#pragma mark -
#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.popoverController dismissPopoverAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.popoverController = nil;
    
    MotionsViewController *vc = [[MotionsViewController alloc] initWithImage:image useForAvatar:YES];
    vc.delegate = self;
    [vc show];
}

#pragma mark -
#pragma mark UIPopoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popoverController = nil;
}

#pragma mark - MotionsViewController delegate

- (void)motionViewControllerDidFinish:(UIImage *)image {
    self.view.userInteractionEnabled = NO;
    
    ErrorIndicatorViewController *vc = [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeLoading contentText:nil];
    
    BlockARCWeakSelf weakSelf = self;
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if(!client.hasError) {
            
            [weakSelf loadUserAndChangeAvatar];
            
            [vc dismissViewAnimated:NO completion:^{
                [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureSuccess contentText:@"修改成功" animated:NO];
            }];
        } else {
            [vc dismissViewAnimated:NO completion:^{
                [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureFailure contentText:@"修改失败" animated:NO];
            }];
        }
        weakSelf.view.userInteractionEnabled = YES;
    }];
    [client uploadAvatar:image];
    [[UIApplication sharedApplication].rootViewController dismissModalViewControllerAnimated:YES];
}

- (void)loadUserAndChangeAvatar
{
    BlockARCWeakSelf weakSelf = self;
    WBClient *userClient = [WBClient client];
    [userClient setCompletionBlock:^(WBClient *client) {
        if (!userClient.hasError && weakSelf) {
            
            NSDictionary *userDict = client.responseJSONObject;
            User *user = [User insertUser:userDict inManagedObjectContext:weakSelf.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeCurrentUser];
            [NSNotificationCenter postChangeUserAvatarNotification];
            [weakSelf.avatarImageView loadImageWithoutFadeFromURL:user.largeAvatarURL completion:nil];
        } else {
        
        }
    }];
    
    [userClient getUser:self.currentUser.userID];
}

- (void)motionViewControllerDidCancel {
    [[UIApplication sharedApplication].rootViewController dismissModalViewControllerAnimated:YES];
}

@end
