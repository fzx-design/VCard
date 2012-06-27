//
//  CardViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "BaseCardBackgroundView.h"
#import "CardImageView.h"
#import "TTTAttributedLabel.h"
#import "UserAvatarImageView.h"
#import "Status.h"
#import "PostViewController.h"
#import <MessageUI/MessageUI.h>

#define CardSizeUserAvatarHeight 25
#define CardSizeImageGap 22
#define CardSizeTextGap 20
#define CardSizeTopViewHeight 20
#define CardSizeBottomViewHeight 20
#define CardSizeRepostHeightOffset -8
#define CardTextLineSpace 8
#define CardTailHeight 24
#define CardTailOffset -55

@interface CardViewController : CoreDataViewController <TTTAttributedLabelDelegate, PostViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    CardImageView *_statusImageView;
    UserAvatarImageView *_repostUserAvatar;
    UserAvatarImageView *_originalUserAvatar;
    UIImageView *_favoredImageView;
    UIImageView *_clipImageView;
    UIImageView *_locationPinImageView;
    
    UILabel *_locationLabel;
    UILabel *_timeStampLabel;
    
    
    UIButton *_commentButton;
    UIButton *_repostButton;
    UIButton *_originalUserNameButton;
    UIButton *_repostUserNameButton;
    
    UIView *_statusInfoView;
    UIView *_repostStatusInfoView;
    
    TTTAttributedLabel *_originalStatusLabel;
    TTTAttributedLabel *_repostStatusLabel;
    
    BaseCardBackgroundView *_cardBackground;
    BaseCardBackgroundView *_repostCardBackground;
    
    Status *_status;
    
    NSInteger _imageHeight;
}

@property (nonatomic, strong) IBOutlet CardImageView *statusImageView;
@property (nonatomic, strong) IBOutlet UserAvatarImageView *repostUserAvatar;
@property (nonatomic, strong) IBOutlet UserAvatarImageView *originalUserAvatar;
@property (nonatomic, strong) IBOutlet UIImageView *favoredImageView;
@property (nonatomic, strong) IBOutlet UIImageView *clipImageView;
@property (nonatomic, strong) IBOutlet UIImageView *locationPinImageView;

@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeStampLabel;

@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet UIButton *repostButton;
@property (nonatomic, strong) IBOutlet UIButton *originalUserNameButton;
@property (nonatomic, strong) IBOutlet UIButton *repostUserNameButton;
@property (nonatomic, strong) IBOutlet UILabel *originalUserNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *repostUserNameLabel;

@property (nonatomic, strong) IBOutlet UIView *statusInfoView;
@property (nonatomic, strong) IBOutlet UIView *repostStatusInfoView;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *originalStatusLabel;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *repostStatusLabel;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *cardBackground;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *repostCardBackground;
@property (nonatomic, strong) Status *status;
@property (nonatomic, weak) Status *previousStatus;
@property (nonatomic, assign) NSInteger imageHeight;
@property (nonatomic, assign) NSInteger pageIndex;

- (IBAction)nameButtonClicked:(id)sender;
- (IBAction)didClickCommentButton:(UIButton *)sender;
- (IBAction)didClickRepostButton:(UIButton *)sender;

+ (CGFloat)heightForStatus:(Status*)status_ andImageHeight:(NSInteger)imageHeight_;
+ (CGFloat)heightForTextContent:(NSString *)text;
+ (void)setStatusTextLabel:(TTTAttributedLabel*)label withText:(NSString*)string;

- (void)configureCardWithStatus:(Status*)status_
                    imageHeight:(CGFloat)imageHeight_
                      pageIndex:(NSInteger)pageIndex_
                    currentUser:(User *)user;
- (void)loadImage;
- (void)prepareForReuse;

@end
