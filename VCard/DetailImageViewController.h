//
//  DetailImageViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-6.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAvatarImageView.h"
#import "CardViewController.h"
#import "Status.h"

@interface DetailImageViewController : UIViewController <CardViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIView               *topBarView;
@property (nonatomic, strong) IBOutlet UIView               *bottomBarView;
@property (nonatomic, strong) IBOutlet UIButton             *returnButton;
@property (nonatomic, strong) IBOutlet UIButton             *commentButton;
@property (nonatomic, strong) IBOutlet UIButton             *moreActionButton;
@property (nonatomic, strong) IBOutlet UILabel              *authorNameLabel;
@property (nonatomic, strong) IBOutlet UILabel              *timeStampLabel;
@property (nonatomic, strong) IBOutlet UIScrollView         *scrollView;
@property (nonatomic, strong) IBOutlet UserAvatarImageView  *authorAvatarImageView;

@property (nonatomic, strong) UIImageView                   *imageView;
@property (nonatomic, weak) CardViewController            *cardViewController;

- (void)setUpWithCardViewController:(CardViewController *)cardViewController;
- (IBAction)didClickReturnButton:(id)sender;

@end