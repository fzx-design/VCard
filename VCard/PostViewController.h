//
//  PostViewController.h
//  VCard
//
//  Created by 紫川 王 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionsViewController.h"
#import "PostAtHintView.h"
#import <CoreLocation/CoreLocation.h>
#import "PostRootView.h"
#import "EmoticonsViewController.h"

@interface PostViewController : UIViewController <MotionsViewControllerDelegate, UITextViewDelegate, PostHintViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, PostRootViewDelegate, EmoticonsViewControllerDelegate> {
    BOOL _keyboardHidden;
    BOOL _located;
    CLLocationCoordinate2D _location2D;
    BOOL _needFillPoundSign;
    CGRect _functionRightViewInitFrame;
}

@property (nonatomic, strong) IBOutlet UIImageView  *motionsImageView;
@property (nonatomic, strong) IBOutlet UITextView   *textView;
@property (nonatomic, strong) IBOutlet UILabel      *textCountLabel;
@property (nonatomic, strong) IBOutlet UIView       *postView;
@property (nonatomic, strong) IBOutlet UIView       *textContainerView;

@property (nonatomic, strong) IBOutlet UIButton     *navButton;
@property (nonatomic, strong) IBOutlet UIButton     *atButton;
@property (nonatomic, strong) IBOutlet UIButton     *emoticonsButton;
@property (nonatomic, strong) IBOutlet UIButton     *topicButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *navActivityView;
@property (nonatomic, strong) IBOutlet UILabel *navLabel;
@property (nonatomic, strong) IBOutlet UIView *functionLeftView;
@property (nonatomic, strong) IBOutlet UIView *functionRightView;

- (IBAction)didClickMotionsButton:(UIButton *)sender;
- (IBAction)didClickReturnButton:(UIButton *)sender;
- (IBAction)didClickPostButton:(UIButton *)sender;
- (IBAction)didClickAtButton:(UIButton *)sender;
- (IBAction)didClickTopicButton:(UIButton *)sender;
- (IBAction)didClickEmoticonsButton:(UIButton *)sender;
- (IBAction)didClickNavButton:(UIButton *)sender;

@end
