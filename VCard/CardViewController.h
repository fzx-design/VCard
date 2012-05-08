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
#import "Status.h"

#define StatusImageHeightSmall 200
#define StatusImageHeightLarge 300

@interface CardViewController : CoreDataViewController <TTTAttributedLabelDelegate> {
    CardImageView *_statusImageView;
    UIImageView *_repostUserAvatar;
    UIImageView *_originalUserAvatar;
    UIImageView *_favoredImageView;
    UIImageView *_clipImageView;
    
    UIButton *_commentButton;
    UIButton *_repostButton;
    UIButton *_originalUserNameButton;
    UIButton *_repostUserNameButton;
    
    UIView *_statusInfoView;
    
    TTTAttributedLabel *_originalStatusLabel;
    TTTAttributedLabel *_repostStatusLabel;
    
    BaseCardBackgroundView *_cardBackground;
    BaseCardBackgroundView *_repostCardBackground;
    
    Status *_status;
    
    NSInteger _imageHeight;
}

@property (nonatomic, strong) IBOutlet CardImageView *statusImageView;
@property (nonatomic, strong) IBOutlet UIImageView *repostUserAvatar;
@property (nonatomic, strong) IBOutlet UIImageView *originalUserAvatar;
@property (nonatomic, strong) IBOutlet UIImageView *favoredImageView;
@property (nonatomic, strong) IBOutlet UIImageView *clipImageView;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet UIButton *repostButton;

@property (nonatomic, strong) IBOutlet UIButton *originalUserNameButton;
@property (nonatomic, strong) IBOutlet UIButton *repostUserNameButton;

@property (nonatomic, strong) IBOutlet UIView *statusInfoView;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *originalStatusLabel;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *repostStatusLabel;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *cardBackground;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *repostCardBackground;
@property (nonatomic, strong) Status *status;

@property (nonatomic, assign) NSInteger imageHeight;

+ (CGFloat)heightForStatus:(Status*)status_ andImageHeight:(NSInteger)imageHeight_;

- (void)configureCardWithStatus:(Status*)status_ imageHeight:(CGFloat)imageHeight_;
- (void)loadImage;
- (void)prepareForReuse;

@end
