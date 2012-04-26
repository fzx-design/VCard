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
#import "IFTweetLabel.h"
#import "Status.h"

@interface CardViewController : CoreDataViewController {
    UIImageView *_statusImageView;
    UIImageView *_repostUserAvatar;
    UIImageView *_originalUserAvatar;
    UIImageView *_favoredImageView;
    
    UIButton *_commentButton;
    UIButton *_repostButton;
    
    UIView *_statusInfoView;
    
    IFTweetLabel *_originalStatusLabel;
    IFTweetLabel *_repostStatusLabel;
    
    BaseCardBackgroundView *_cardBackground;
    BaseCardBackgroundView *_repostCardBackground;
    
    Status *_status;
}

@property (nonatomic, strong) IBOutlet UIImageView *statusImageView;
@property (nonatomic, strong) IBOutlet UIImageView *repostUserAvatar;
@property (nonatomic, strong) IBOutlet UIImageView *originalUserAvatar;
@property (nonatomic, strong) IBOutlet UIImageView *favoredImageView;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet UIButton *repostButton;
@property (nonatomic, strong) IBOutlet UIView *statusInfoView;
@property (nonatomic, strong) IBOutlet IFTweetLabel *originalStatusLabel;
@property (nonatomic, strong) IBOutlet IFTweetLabel *repostStatusLabel;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *cardBackground;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *repostCardBackground;
@property (nonatomic, strong) Status *status;

- (void)configureCellWithStatus:(Status*)status;

@end
