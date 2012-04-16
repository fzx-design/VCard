//
//  CardViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCardBackgroundView.h"
#import "IFTweetLabel.h"

@interface CardViewController : UIViewController {
    UIImageView *_statusImageView;
    UIView *_statusInfoView;
    IFTweetLabel *_statusTextLabel;
    
    BaseCardBackgroundView *_cardBackground;
    BaseCardBackgroundView *_repostCardBackground;
}

@property (nonatomic, strong) IBOutlet UIImageView *statusImageView;
@property (nonatomic, strong) IBOutlet UIView *statusInfoView;
@property (nonatomic, strong) IBOutlet IFTweetLabel *statusTextLabel;

@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *cardBackground;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *repostCardBackground;

@end
