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
    PostViewControllerTypeCommentWeibo,
    PostViewControllerTypeCommentReply,
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
@property (nonatomic, strong) IBOutlet UIButton     *postButton;
@property (nonatomic, strong) IBOutlet UIButton     *repostCommentCheckmarkButton;
@property (nonatomic, strong) IBOutlet UIButton     *repostCommentButton;
@property (nonatomic, strong) IBOutlet UIImageView  *postImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *navActivityView;
@property (nonatomic, strong) IBOutlet UILabel      *navLabel;
@property (nonatomic, strong) IBOutlet UIView       *functionLeftNavView;
@property (nonatomic, strong) IBOutlet UIView       *functionLeftCheckmarkView;
@property (nonatomic, strong) IBOutlet UIView       *functionRightView;
@property (nonatomic, strong) IBOutlet UIView       *motionsView;     
@property (nonatomic, strong) IBOutlet UILabel      *topBarLabel;

@property (nonatomic, strong) IBOutlet UIImageView  *leftPaperImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *rightPaperImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *leftPaperGloomImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *rightPaperGloomImageView;
@property (nonatomic, strong) IBOutlet UIView       *paperImageHolderView;

@property (nonatomic, strong) UIImage *motionsOriginalImage;
@property (nonatomic, weak)   id<PostViewControllerDelegate> delegate;
@property (nonatomic, assign) PostViewControllerType type;
@property (nonatomic, strong) NSString *content;

+ (id)getNewStatusViewControllerWithAtUserName:(NSString *)name
                                      delegate:(id<PostViewControllerDelegate>)delegate;

+ (id)getNewStatusViewControllerWithDelegate:(id<PostViewControllerDelegate>)delegate;

+ (id)getRepostViewControllerWithWeiboID:(NSString *)weiboID
                          weiboOwnerName:(NSString *)ownerName
                                 content:(NSString *)content
                                delegate:(id<PostViewControllerDelegate>)delegate;

+ (id)getCommentWeiboViewControllerWithWeiboID:(NSString *)weiboID
                                weiboOwnerName:(NSString *)ownerName
                                      delegate:(id<PostViewControllerDelegate>)delegate;

+ (id)getCommentReplyViewControllerWithWeiboID:(NSString *)weiboID
                                       replyID:(NSString *)replyID
                                weiboOwnerName:(NSString *)ownerName
                                      delegate:(id<PostViewControllerDelegate>)delegate;

- (IBAction)didClickMotionsButton:(UIButton *)sender;
- (IBAction)didClickCancelButton:(UIButton *)sender;
- (IBAction)didClickPostButton:(UIButton *)sender;
- (IBAction)didClickAtButton:(UIButton *)sender;
- (IBAction)didClickTopicButton:(UIButton *)sender;
- (IBAction)didClickEmoticonsButton:(UIButton *)sender;
- (IBAction)didClickNavButton:(UIButton *)sender;
- (IBAction)didClickRepostCommentCheckmarkButton:(UIButton *)sender;

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
