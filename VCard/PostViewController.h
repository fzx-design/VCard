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
#import "PostRootView.h"
#import "EmoticonsViewController.h"

typedef enum {
    PostViewControllerTypeNewStatus,
    PostViewControllerTypeRepost,
    PostViewControllerTypeReply,
} PostViewControllerType;

@protocol PostViewControllerDelegate;
@interface PostViewController : UIViewController <MotionsViewControllerDelegate, UITextViewDelegate, PostHintViewDelegate, UIScrollViewDelegate, PostRootViewDelegate, EmoticonsViewControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL _keyboardHidden;
    BOOL _needFillPoundSign;
    CGRect _functionRightViewInitFrame;
    BOOL _playingFoldPaperAnimation;
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
@property (nonatomic, strong) IBOutlet UIButton     *motionsButton;
@property (nonatomic, strong) IBOutlet UIButton     *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton     *checkmarkButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *navActivityView;
@property (nonatomic, strong) IBOutlet UILabel      *navLabel;
@property (nonatomic, strong) IBOutlet UIView       *functionLeftNavView;
@property (nonatomic, strong) IBOutlet UIView       *functionLeftCheckmarkView;
@property (nonatomic, strong) IBOutlet UIView       *functionRightView;
@property (nonatomic, strong) IBOutlet UILabel      *topBarLabel;
@property (nonatomic, strong) IBOutlet UILabel      *repostReplyLabel;

@property (nonatomic, strong) IBOutlet UIImageView  *leftPaperImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *rightPaperImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *leftPaperGloomImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *rightPaperGloomImageView;
@property (nonatomic, strong) IBOutlet UIView       *paperImageHolderView;

@property (nonatomic, strong) UIImage *motionsOriginalImage;
@property (nonatomic, weak)   id<PostViewControllerDelegate> delegate;

+ (id)getPostViewControllerViewWithType:(PostViewControllerType)type;

- (IBAction)didClickMotionsButton:(UIButton *)sender;
- (IBAction)didClickCancelButton:(UIButton *)sender;
- (IBAction)didClickPostButton:(UIButton *)sender;
- (IBAction)didClickAtButton:(UIButton *)sender;
- (IBAction)didClickTopicButton:(UIButton *)sender;
- (IBAction)didClickEmoticonsButton:(UIButton *)sender;
- (IBAction)didClickNavButton:(UIButton *)sender;
- (IBAction)didClickRepostReplyCheckmarkButton:(UIButton *)sender;

- (void)showViewFromRect:(CGRect)rect;
- (void)dismissViewToRect:(CGRect)rect;
- (void)dismissViewUpwards;

@end

@protocol PostViewControllerDelegate <NSObject>

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message;
- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message;
- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message;
- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message;

@end
