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

@interface DetailImageViewController : UIViewController <CardViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, PostViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView               *topBarView;
@property (nonatomic, weak) IBOutlet UIView               *bottomBarView;
@property (nonatomic, weak) IBOutlet UIButton             *returnButton;
@property (nonatomic, weak) IBOutlet UIButton             *commentButton;
@property (nonatomic, weak) IBOutlet UIButton             *moreActionButton;
@property (nonatomic, weak) IBOutlet UILabel              *authorNameLabel;
@property (nonatomic, weak) IBOutlet UILabel              *timeStampLabel;
@property (nonatomic, weak) IBOutlet UIScrollView         *scrollView;
@property (nonatomic, weak) IBOutlet UserAvatarImageView  *authorAvatarImageView;

@property (nonatomic, weak) CardViewController              *cardViewController;
@property (nonatomic, weak) CardImageView                   *imageView;
@property (nonatomic, strong) UITapGestureRecognizer        *tapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer        *doubleTapGestureRecognizer;
@property (nonatomic, readonly) BOOL                        hasViewInDetailedMode;

- (void)setUpWithCardViewController:(CardViewController *)cardViewController;
- (IBAction)didClickReturnButton:(id)sender;
- (IBAction)didClickCommentButton:(UIButton *)sender;
- (IBAction)didClickMoreActionButton:(UIButton *)sender;

@end