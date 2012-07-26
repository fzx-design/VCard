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

@property (nonatomic, weak) IBOutlet UIImageView  *motionsImageView;
@property (nonatomic, weak) IBOutlet UITextView   *textView;
@property (nonatomic, weak) IBOutlet UILabel      *textCountLabel;
@property (nonatomic, weak) IBOutlet UIView       *postView;
@property (nonatomic, weak) IBOutlet UIView       *textContainerView;

@property (nonatomic, weak) IBOutlet UIButton     *navButton;
@property (nonatomic, weak) IBOutlet UIButton     *atButton;
@property (nonatomic, weak) IBOutlet UIButton     *emoticonsButton;
@property (nonatomic, weak) IBOutlet UIButton     *topicButton;
@property (nonatomic, weak) IBOutlet UIButton     *motionsButton;
@property (nonatomic, weak) IBOutlet UIButton     *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton     *postButton;
@property (nonatomic, weak) IBOutlet UIButton     *repostCommentCheckmarkButton;
@property (nonatomic, weak) IBOutlet UIButton     *repostCommentButton;
@property (nonatomic, weak) IBOutlet UIImageView  *postImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *navActivityIndicator;
@property (nonatomic, weak) IBOutlet UILabel      *navLabel;
@property (nonatomic, weak) IBOutlet UIView       *functionLeftNavView;
@property (nonatomic, weak) IBOutlet UIView       *functionLeftCheckmarkView;
@property (nonatomic, weak) IBOutlet UIView       *functionRightView;
@property (nonatomic, weak) IBOutlet UIView       *motionsView;     
@property (nonatomic, weak) IBOutlet UILabel      *topBarLabel;

@property (nonatomic, weak) IBOutlet UIImageView  *leftPaperImageView;
@property (nonatomic, weak) IBOutlet UIImageView  *rightPaperImageView;
@property (nonatomic, weak) IBOutlet UIImageView  *leftPaperGloomImageView;
@property (nonatomic, weak) IBOutlet UIImageView  *rightPaperGloomImageView;
@property (nonatomic, weak) IBOutlet UIView       *paperImageHolderView;

@property (nonatomic, weak)   id<PostViewControllerDelegate> delegate;
@property (nonatomic, assign) PostViewControllerType type;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) UIImage *motionsOriginalImage;

+ (id)getNewStatusViewControllerWithAtUserName:(NSString *)name
                                      delegate:(id<PostViewControllerDelegate>)delegate;

+ (id)getNewStatusViewControllerWithPrefixContent:(NSString *)prefix
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
- (void)unfoldAnimationDidFinish;

- (void)saveImageInBackground:(UIImage *)image;

@end

@protocol PostViewControllerDelegate <NSObject>

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message;
- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message;
- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message;
- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message;

@end
