//
//  PostViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "WBClient.h"
#import "PostNewStatusViewController.h"
#import "PostRepostCommentViewController.h"
#import "EmoticonsViewController.h"
#import "PostAtHintView.h"
#import "PostTopicHintView.h"
#import "UIView+Addition.h"
#import "UIImage+Addition.h"
#import "NSString+Addition.h"
#import "UIApplication+Addition.h"

#define WEIBO_TEXT_MAX_LENGTH   140
#define HINT_VIEW_OFFSET        CGSizeMake(-16, 27)
#define HINT_VIEW_ORIGIN_MIN_Y  108
#define HINT_VIEW_ORIGIN_MAX_Y  234
#define HINT_VIEW_BORDER_MAX_Y  (self.postView.frame.size.height - 10)
#define HINT_VIEW_BORDER_MAX_X  self.postView.frame.size.width

#define FOLD_PAPER_ANIMATION_DURATION   0.5f
#define UNFOLD_PAPER_ANIMATION_DURATION 0.3f
#define FOLD_PAPER_SCALE_RATIO          0.01f
#define PAPER_GLOOM_ALPHA               0.5f

#define MOTIONS_ACTION_SHEET_SHOOT_INDEX    0
#define MOTIONS_ACTION_SHEET_ALBUM_INDEX    1
#define MOTIONS_ACTION_SHEET_EDIT_INDEX     2
#define MOTIONS_ACTION_SHEET_CLEAR_INDEX    3

typedef enum {
    HintViewTypeNone,
    HintViewTypeAt,
    HintViewTypeTopic,
} HintViewType;

typedef enum {
    ActionSheetTypeNone,
    ActionSheetTypeDestruct,
    ActionSheetTypeMotions,
    PopoverAlbumImagePicker,
} ActionSheetType;

@interface PostViewController () {
    ActionSheetType _shouldPresentActionSheetType;
}

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) PostHintView *currentHintView;
@property (nonatomic, readonly) CGPoint cursorPos;
@property (nonatomic, assign) HintViewType currentHintViewType;
@property (nonatomic, strong) EmoticonsViewController *emoticonsViewController;
@property (nonatomic, readonly) PostRootView *postRootView;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, assign) ActionSheetType currentActionSheetType;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, assign) CGRect startButtonFrame;
@property (nonatomic, readonly) CGPoint startButtonCenter;
@property (nonatomic, strong) NSString *prefixText;

@property (nonatomic, strong) UIImage *motionsCompressImage;
@property (nonatomic, strong) NSString *textViewPreserveText;

@end

@implementation PostViewController

@synthesize popoverController = _pc;

+ (id)getRecommendVCardNewStatusViewControllerWithDelegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getNewStatusViewControllerWithPrefixContent:[NSString stringWithFormat:@"@VCard微博 客户端很酷！推荐有 iPad 的童鞋们试试看。%@", kVCardAppStoreURL] image:[UIImage imageNamed:@"tell_friends_image.jpg"] delegate:delegate];
}

+ (id)getNewStatusViewControllerWithDelegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeNewStatus delegate:delegate weiboID:nil replyID:nil weiboOwnerName:nil weiboContent:nil image:nil];
}

+ (id)getNewStatusViewControllerWithAtUserName:(NSString *)name
                                      delegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getNewStatusViewControllerWithPrefixContent:[NSString stringWithFormat:@"@%@ ", name] image:nil delegate:delegate];
}

+ (id)getNewStatusViewControllerWithPrefixContent:(NSString *)prefix
                                            image:(UIImage *)image
                                         delegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeNewStatus delegate:delegate weiboID:nil replyID:nil weiboOwnerName:nil weiboContent:prefix image:image];
    
}

+ (id)getRepostViewControllerWithWeiboID:(NSString *)weiboID
                          weiboOwnerName:(NSString *)ownerName
                                 content:(NSString *)content
                                delegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeRepost delegate:delegate weiboID:weiboID replyID:nil weiboOwnerName:ownerName weiboContent:content image:nil];
}

+ (id)getCommentWeiboViewControllerWithWeiboID:(NSString *)weiboID
                                weiboOwnerName:(NSString *)ownerName
                                delegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeCommentWeibo delegate:delegate weiboID:weiboID replyID:nil weiboOwnerName:ownerName weiboContent:nil image:nil];
}

+ (id)getCommentReplyViewControllerWithWeiboID:(NSString *)weiboID
                                replyID:(NSString *)replyID
                                weiboOwnerName:(NSString *)ownerName
                                      delegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeCommentReply delegate:delegate weiboID:weiboID replyID:replyID weiboOwnerName:ownerName weiboContent:nil image:nil];
}

+ (id)getPostViewControllerViewWithType:(PostViewControllerType)type
                               delegate:(id<PostViewControllerDelegate>)delegate
                                weiboID:(NSString *)weiboID
                                replyID:(NSString *)replyID
                         weiboOwnerName:(NSString *)ownerName
                           weiboContent:(NSString *)content
                                  image:(UIImage *)image {
    PostViewController *vc = nil;
    if(type == PostViewControllerTypeNewStatus) {
        vc = [[PostNewStatusViewController alloc] initWithContent:content];
    } else {
        vc = [[PostRepostCommentViewController alloc] initWithWeiboID:weiboID
                                                              replyID:replyID
                                                       weiboOwnerName:ownerName
                                                          contentText:content];
    }
    
    if(type == PostViewControllerTypeCommentReply) {
        vc.prefixText = [NSString stringWithFormat:@"回复@%@", ownerName];
    } else {
        vc.prefixText = @"";
    }
    
    [vc adjustContentWithEmoticons];
    
    vc.type = type;
    vc.delegate = delegate;
    vc.motionsOriginalImage = image;
    
    return vc;
}

- (void)adjustContentWithEmoticons {
    self.content = [self.content replaceRegExWithEmoticons];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navActivityIndicator.hidden = YES;
    self.navLabel.text = @"";
    _functionRightViewInitFrame = self.functionRightView.frame;
    self.postRootView.delegate = self;
    [ThemeResourceProvider configButtonPaperLight:self.cancelButton];
    
    //恢复view did unload造成的影响
    if(self.textViewPreserveText) {
        self.textView.text = self.textViewPreserveText;
        self.textViewPreserveText = nil;
    }
    [self setMotionsImage:self.motionsOriginalImage];
    
    [self configureViewFrame];
    [self configureMotionsImageView];
    [self configureTextView];
    
    [self unfoldPaperAnimation];
    [self moveFromStartButtonAnimation];
}

- (void)viewDidUnload {
    self.textViewPreserveText = self.textView.text;
    self.textView = nil;
    
    self.motionsImageView = nil;
    self.textCountLabel = nil;
    self.postView = nil;
    self.textContainerView = nil;
    self.navButton = nil;
    self.atButton = nil;
    self.emoticonsButton = nil;
    self.topicButton = nil;
    self.navActivityIndicator = nil;
    self.navLabel = nil;
    self.functionLeftNavView = nil;
    self.functionLeftCheckmarkView = nil;
    self.functionRightView = nil;
    self.motionsButton = nil;
    self.cancelButton = nil;
    self.leftPaperImageView = nil;
    self.rightPaperImageView = nil;
    self.paperImageHolderView = nil;
    self.topBarLabel = nil;
    self.repostCommentCheckmarkButton = nil;
    self.repostCommentButton = nil;
    self.motionsView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(deviceRotationDidChange:) name:kNotificationNameOrientationChanged object:nil];
    [center addObserver:self selector:@selector(deviceRotationWillChange:) name:kNotificationNameOrientationWillChange object:nil];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification handlers

- (void)deviceRotationDidChange:(NSNotification *)notification {
    if(_shouldPresentActionSheetType == ActionSheetTypeDestruct) {
        [self didClickCancelButton:self.cancelButton];
    } else if(_shouldPresentActionSheetType == ActionSheetTypeMotions) {
        [self didClickMotionsButton:self.motionsButton];
    } else if(_shouldPresentActionSheetType == PopoverAlbumImagePicker) {
        [self showAlbumImagePicker];
    }
    _shouldPresentActionSheetType = ActionSheetTypeNone;
}

- (void)deviceRotationWillChange:(NSNotification *)notification {
    [self dismissPopover];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect keyboardBounds = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            keyboardHeight = keyboardBounds.size.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            keyboardHeight = keyboardBounds.size.width;
            break;
    }
        
    CGSize screenSize = [UIApplication sharedApplication].screenSize;
    if(_keyboardHidden) {
        float animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView animateWithDuration:animationDuration animations:^{
            self.postView.center = CGPointMake(self.postView.center.x, (screenSize.height - keyboardHeight) / 2);
            self.paperImageHolderView.center = self.postView.center;
        } completion:^(BOOL finished) {
            _keyboardHidden = !finished;
        }];
    } else {
        self.postView.center = CGPointMake(self.postView.center.x, (screenSize.height - keyboardHeight) / 2);
        self.paperImageHolderView.center = self.postView.center;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {    
    NSDictionary *info = [notification userInfo];
    float animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGSize screenSize = [UIApplication sharedApplication].screenSize;
    if(_playingFoldPaperAnimation == NO) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.postView.center = CGPointMake(self.postView.center.x, screenSize.height / 2);
            self.paperImageHolderView.center = self.postView.center;
        } completion:^(BOOL finished) {
            _keyboardHidden = finished;
        }];
    }
}

#pragma mark - Logic methods

- (PostRootView *)postRootView {
    return (PostRootView *)self.view;
}

- (EmoticonsViewController *)emoticonsViewController {
    if(!_emoticonsViewController) {
        _emoticonsViewController = [[EmoticonsViewController alloc] init];
        _emoticonsViewController.delegate = self.textView;
    }
    return _emoticonsViewController;
}

- (int)textDoubleCount:(NSString*)text {
    int i, n = [text length],l = 0, a = 0, b = 0;
    unichar c;
    for(i = 0;i < n; i++) {
        c = [text characterAtIndex:i];
        if(isblank(c))
            b++;
        else if(isascii(c))
            a++;
        else
            l++;
    }
    int textLength = l * 2 + a + b;
    return textLength;
}

- (int)weiboTextBackwardsCount {
    int textLength = [self textDoubleCount:self.textView.text] + [self textDoubleCount:self.prefixText];
    textLength = floorf((float)textLength / 2.0f);
    return WEIBO_TEXT_MAX_LENGTH - textLength;
}

- (CGPoint)cursorPos {
    CGPoint cursorPos = CGPointZero;
    if(self.textView.selectedTextRange.empty && self.textView.selectedTextRange) {
        cursorPos = [self.textView caretRectForPosition:self.textView.selectedTextRange.start].origin;
        cursorPos.x += self.textContainerView.frame.origin.x + self.textView.frame.origin.x + HINT_VIEW_OFFSET.width;
        CGFloat textScrollViewOffsetY = self.textView.contentOffset.y;
        cursorPos.y += self.textContainerView.frame.origin.y + self.textView.frame.origin.y + HINT_VIEW_OFFSET.height - textScrollViewOffsetY;
    }
    return cursorPos;
}

- (void)setMotionsImage:(UIImage *)image {
    if(image) {
        CGRect imageViewRect = CGRectMake(0, 0, self.motionsImageView.frame.size.width, self.motionsImageView.frame.size.height);
        CGRect imageRect;
        if(image.size.width > image.size.height) {
            imageRect = CGRectMake((image.size.width - image.size.height) / 2, 0, image.size.height, image.size.height);
        } else {
            imageRect = CGRectMake(0, (image.size.height - image.size.width) / 2, image.size.width, image.size.width);
        }
        CGImageRef optimizedImageRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
        UIImage *optimizedImage = [UIImage imageWithCGImage:optimizedImageRef];
        CGImageRelease(optimizedImageRef);
        
        if (NULL != UIGraphicsBeginImageContextWithOptions)
            UIGraphicsBeginImageContextWithOptions(imageViewRect.size, NO, 0);
        else
            UIGraphicsBeginImageContext(imageViewRect.size);
        [optimizedImage drawInRect:CGRectMake(1, 1, imageViewRect.size.width - 2, imageViewRect.size.height - 2)];
        optimizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.motionsImageView.image = optimizedImage;
        self.motionsCompressImage = optimizedImage;
    } else {
        self.motionsImageView.image = nil;
        self.motionsCompressImage = nil;
    }
    self.motionsOriginalImage = image;
    [self updateTextCountAndPostButton];
}

- (void)configurePaperHolderImageView {
    UIGraphicsBeginImageContext(self.postView.bounds.size);
    [self.postView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect leftRect = CGRectMake(0, 0, viewImage.size.width / 2, viewImage.size.height);
    CGRect rightRect = CGRectMake(viewImage.size.width / 2, 0, viewImage.size.width / 2, viewImage.size.height);
    
    CGImageRef leftImageRef = CGImageCreateWithImageInRect(viewImage.CGImage, leftRect);
    CGImageRef rightImageRef = CGImageCreateWithImageInRect(viewImage.CGImage, rightRect);
    
    UIImage *leftImage = [UIImage imageWithCGImage:leftImageRef];
    UIImage *rightImage = [UIImage imageWithCGImage:rightImageRef];
    
    CGImageRelease(leftImageRef);
    CGImageRelease(rightImageRef);
    
    self.leftPaperImageView.image = leftImage;
    self.rightPaperImageView.image = rightImage;
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -1500;
    self.leftPaperImageView.layer.transform = transform;
    self.rightPaperImageView.layer.transform = transform;
    self.leftPaperImageView.layer.anchorPoint = CGPointMake(1, 0.5f);
    self.rightPaperImageView.layer.anchorPoint = CGPointMake(0, 0.5f);
}

- (CGPoint)startButtonCenter {
    return CGPointMake(self.startButtonFrame.origin.x + self.startButtonFrame.size.width / 2,
                       self.startButtonFrame.origin.y + self.startButtonFrame.size.height / 2);
}

#pragma mark - UI methods

- (void)dismissPopover {
    if(self.actionSheet) {
        _shouldPresentActionSheetType = self.currentActionSheetType;
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
    if(self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
        _shouldPresentActionSheetType = PopoverAlbumImagePicker;
    }
}

- (void)configureTextView {
    [self updateTextCountAndPostButton];
    [self.textView becomeFirstResponder];
}

- (void)configureViewFrame {
    CGRect frame = CGRectZero;
    frame.size = [UIApplication sharedApplication].screenSize;
    self.view.frame = frame;
}

- (void)configureMotionsImageView {
    self.motionsImageView.transform = CGAffineTransformMakeRotation(6 * M_PI / 180);
}

- (void)dismissViewAnimated:(BOOL)animated {
    [UIApplication dismissModalViewControllerAnimated:animated];
    if(animated == NO)
        _playingFoldPaperAnimation = YES;
    [self.textView resignFirstResponder];
}

- (void)updateTextCountAndPostButton {
    int weiboTextBackwardsCount = [self weiboTextBackwardsCount];
    self.textCountLabel.text = [NSString stringWithFormat:@"%d", weiboTextBackwardsCount];
    if([self.textView.text isEqualToString:@""] && !self.motionsOriginalImage && self.type != PostViewControllerTypeRepost) {
        self.postButton.userInteractionEnabled = NO;
        self.postButton.alpha = 0.3f;
    } else if(weiboTextBackwardsCount < 0) {
        self.postButton.alpha = 1;
        self.postButton.userInteractionEnabled = NO;
        self.postButton.enabled = NO;
        self.postImageView.highlighted = YES;
        self.textCountLabel.highlighted = YES;
    } else {
        self.postButton.alpha = 1;
        self.postButton.userInteractionEnabled = YES;
        self.postButton.enabled = YES;
        self.postImageView.highlighted = NO;
        self.textCountLabel.highlighted = NO;
    }
}

- (void)presentAtHintView {
    [self dismissHintView];
    CGPoint cursorPos = self.cursorPos;
    if(CGPointEqualToPoint(cursorPos, CGPointZero))
        return;
    PostAtHintView *atView = [[PostAtHintView alloc] initWithCursorPos:cursorPos];
    self.currentHintView = atView;
    atView.delegate = self.textView;
    [self checkCurrentHintViewFrame];
    [self.postView addSubview:atView];
}

- (void)presentTopicHintView {
    [self dismissHintView];
    CGPoint cursorPos = self.cursorPos;
    if(CGPointEqualToPoint(cursorPos, CGPointZero))
        return;
    PostTopicHintView *topicView = [[PostTopicHintView alloc] initWithCursorPos:cursorPos];
    self.currentHintView = topicView;
    topicView.delegate = self.textView;
    [self checkCurrentHintViewFrame];
    [self.postView addSubview:topicView];
    [topicView updateHint:@""];
}

- (void)updateCurrentHintView {
    [self updateCurrentHintViewFrame];
    [self updateCurrentHintViewContent];
}

- (void)updateCurrentHintViewContent {
    if(!self.currentHintView)
        return;
    if([self.currentHintView isMemberOfClass:[PostAtHintView class]]) {
        if(self.textView.isAtHintStringValid)
            [self.currentHintView updateHint:self.textView.currentHintString];
        else {
            [self dismissHintView]; 
        }
    } else if([self.currentHintView isMemberOfClass:[PostTopicHintView class]]) {
        if(self.textView.isTopicHintStringValid)
            [self.currentHintView updateHint:self.textView.currentHintString];
        else {
            [self dismissHintView];
        }    
    }
}

- (void)updateCurrentHintViewFrame {
    if(!self.currentHintView)
        return;
    CGPoint cursorPos = self.cursorPos;
    if(!CGPointEqualToPoint(cursorPos, CGPointZero)) {
        CGRect frame = self.currentHintView.frame;
        frame.origin = cursorPos;
        self.currentHintView.frame = frame;
        [self checkCurrentHintViewFrame];
    }
}

- (void)checkCurrentHintViewFrame {
    CGPoint pos = self.currentHintView.frame.origin;
    CGSize size = self.currentHintView.frame.size;
    
    pos.y = pos.y > HINT_VIEW_ORIGIN_MIN_Y ? pos.y : HINT_VIEW_ORIGIN_MIN_Y;
    pos.y = pos.y < HINT_VIEW_ORIGIN_MAX_Y ? pos.y : HINT_VIEW_ORIGIN_MAX_Y;
    pos.x = pos.x + size.width > HINT_VIEW_BORDER_MAX_X ? HINT_VIEW_BORDER_MAX_X - size.width : pos.x;
    
    self.currentHintView.frame = CGRectMake(pos.x, pos.y, size.width, size.height);
    if([self.currentHintView isKindOfClass:[PostHintView class]])
        self.currentHintView.maxViewHeight = HINT_VIEW_BORDER_MAX_Y - pos.y;
}

- (void)dismissHintView {
    UIView *currentHintView = self.currentHintView;
    self.currentHintView = nil;
    [currentHintView fadeOutWithCompletion:^{
        [currentHintView removeFromSuperview];
    }];
    
    self.textView.currentHintStringRange = NSMakeRange(0, 0);
    self.textView.needFillPoundSign = NO;
    
    self.atButton.selected = NO;
    self.topicButton.selected = NO;
    self.emoticonsButton.selected = NO;
    self.postRootView.observingViewTag = PostRootViewSubviewTagNone;
}

- (void)presentEmoticonsView {
    [self dismissHintView];
    _emoticonsViewController = nil;
    self.postRootView.observingViewTag = PostRootViewSubviewTagEmoticons;
    EmoticonsViewController *vc = self.emoticonsViewController;
    vc.view.alpha = 1;
    CGRect frame = vc.view.frame;
    frame.origin = self.cursorPos;
    vc.view.frame = frame;
    vc.view.tag = PostRootViewSubviewTagEmoticons;
    [self.postView addSubview:vc.view];
    self.currentHintView = (PostHintView *)vc.view;
    self.emoticonsButton.selected = YES;
    self.textView.currentHintStringRange = NSMakeRange(self.textView.selectedRange.location, 0);
    [self checkCurrentHintViewFrame];
}

- (void)showViewFromRect:(CGRect)rect {
    self.startButtonFrame = rect;
    [self viewWillAppear:NO];
    [UIApplication presentModalViewController:self animated:NO];
}

- (void)dismissViewToRect:(CGRect)rect {
    self.startButtonFrame = rect;
    [self moveToStartButtonAnimation];
    [self foldPaperAnimation];
    [self dismissViewAnimated:NO];
}

- (void)dismissViewUpwards {
    [self moveUpwardAnimation];
    [self dismissViewAnimated:NO];
}

- (void)showAlbumImagePicker {
    
    if(!self.textView.isFirstResponder) {
        UIPopoverController *pc =  [UIApplication getAlbumImagePickerFromButton:self.motionsButton delegate:self];
        self.popoverController = pc;
        [pc presentPopoverFromRect:self.motionsButton.bounds inView:self.motionsButton
          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self.textView resignFirstResponder];
        [self performSelector:@selector(showAlbumImagePicker) withObject:nil afterDelay:0.3f];
    }
}

#pragma mark - Animation methods

- (void)moveUpwardAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.postView.frame;
        frame.origin.y = -frame.size.height * 2;
        self.postView.frame = frame;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)moveFromStartButtonAnimation {
    CGPoint originalCenter = self.paperImageHolderView.center;
    self.paperImageHolderView.center = self.startButtonCenter;
    self.paperImageHolderView.transform = CGAffineTransformMakeScale(FOLD_PAPER_SCALE_RATIO, FOLD_PAPER_SCALE_RATIO);
    [UIView animateWithDuration:FOLD_PAPER_ANIMATION_DURATION 
                          delay:0
                        options:UIViewAnimationCurveEaseOut 
                     animations:^{
                         self.paperImageHolderView.center = originalCenter;
                         self.paperImageHolderView.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

- (void)moveToStartButtonAnimation {
    [UIView animateWithDuration:UNFOLD_PAPER_ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.paperImageHolderView.center = self.startButtonCenter;
                         self.paperImageHolderView.transform = CGAffineTransformMakeScale(FOLD_PAPER_SCALE_RATIO, FOLD_PAPER_SCALE_RATIO);
                     } completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
}

- (void)unfoldAnimationDidFinish {
    
}

- (void)unfoldPaperAnimation {
    [self configurePaperHolderImageView];    
    self.postView.hidden = YES;
    
    [CATransaction begin];
    [CATransaction setValue:@FOLD_PAPER_ANIMATION_DURATION forKey: kCATransactionAnimationDuration];
    [CATransaction setCompletionBlock:^{
		self.postView.hidden = NO;
        self.paperImageHolderView.hidden = YES;
        [self unfoldAnimationDidFinish];
	}];
    
    double factor = - 1 * M_PI / 180;
    
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:@"easeOut"]];
	[animation setFromValue:@(-90 * factor)];
	[animation setToValue:@0.0];
    [animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.leftPaperImageView.layer addAnimation:animation forKey:nil];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	[animation setFromValue:@(90 * factor)];
	[animation setToValue:@0.0];
    [animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.rightPaperImageView.layer addAnimation:animation forKey:nil];
    
    [CATransaction commit];
    
    self.leftPaperGloomImageView.alpha = PAPER_GLOOM_ALPHA;
    self.rightPaperGloomImageView.alpha = PAPER_GLOOM_ALPHA;
    [UIView animateWithDuration:FOLD_PAPER_ANIMATION_DURATION - 0.2f
                          delay:0.2f
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         self.leftPaperGloomImageView.alpha = 0;
                         self.rightPaperGloomImageView.alpha = 0;
                     } completion:nil];
}

- (void)foldPaperAnimation {
    [self configurePaperHolderImageView];
    self.postView.hidden = YES;
    self.paperImageHolderView.hidden = NO;
    
    [CATransaction begin];
    [CATransaction setValue:@UNFOLD_PAPER_ANIMATION_DURATION forKey: kCATransactionAnimationDuration];
    
    double factor = - 1 * M_PI / 180;
    
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:@"easeIn"]];
	[animation setFromValue:@0.0];
	[animation setToValue:@(-90 * factor)];
    [animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.leftPaperImageView.layer addAnimation:animation forKey:nil];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	[animation setFromValue:@0.0];
	[animation setToValue:@(90 * factor)];
    [animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.rightPaperImageView.layer addAnimation:animation forKey:nil];
    
    [CATransaction commit];
    
    self.leftPaperGloomImageView.alpha = 0;
    self.rightPaperGloomImageView.alpha = 0;
    [UIView animateWithDuration:UNFOLD_PAPER_ANIMATION_DURATION - 0.1f animations:^{
        self.leftPaperGloomImageView.alpha = PAPER_GLOOM_ALPHA;
        self.rightPaperGloomImageView.alpha = PAPER_GLOOM_ALPHA;
    }];
}

#pragma mark - IBActions

- (IBAction)didClickMotionsButton:(UIButton *)sender {
    UIActionSheet *actionSheet = nil;
    if(![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        if(!self.motionsImageView.image) {
            [self showAlbumImagePicker];
            return;
        }
        else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self 
                                             cancelButtonTitle:nil 
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"重新选取照片", @"编辑", @"清除", nil];
            actionSheet.destructiveButtonIndex = 2;
        }
    } else if(self.motionsImageView.image) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self 
                                         cancelButtonTitle:nil 
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"重新拍照", @"重新选取照片", @"编辑", @"清除", nil];
        actionSheet.destructiveButtonIndex = MOTIONS_ACTION_SHEET_CLEAR_INDEX;
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self 
                                         cancelButtonTitle:nil 
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"拍照", @"选取照片",  nil];
    }
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
       && self.motionsImageView.image) {
        [self.textView resignFirstResponder];
    }
	[actionSheet showFromRect:sender.bounds inView:sender animated:YES];
    self.currentActionSheetType = ActionSheetTypeMotions;
    self.actionSheet = actionSheet;
}

- (IBAction)didClickCancelButton:(UIButton *)sender {
    if([self.textView.text isEqualToString:@""] && self.motionsImageView.image == nil) {
        [self.delegate postViewController:self willDropMessage:self.textView.text];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:nil 
											   destructiveButtonTitle:@"关闭"
													otherButtonTitles:nil];
	[actionSheet showFromRect:sender.bounds inView:sender animated:YES];
    self.currentActionSheetType = ActionSheetTypeDestruct;
    self.actionSheet = actionSheet;
}

- (IBAction)didClickAtButton:(UIButton *)sender {
    BOOL select = !sender.isSelected;
    if(select) {
        [self presentAtHintView];
    } else {
        [self dismissHintView];
    }
    [self.textView initAtHintView:select];
    sender.selected = select;
}

- (IBAction)didClickTopicButton:(UIButton *)sender {
    BOOL select = !sender.isSelected;
    if(select) {
        [self presentTopicHintView];
    } else {
        [self dismissHintView];
    }
    [self.textView initTopicHintView:select];
    sender.selected = select;
}

- (IBAction)didClickEmoticonsButton:(UIButton *)sender {
    BOOL select = !sender.isSelected;
    if(select) {
        [self presentEmoticonsView];
    } else {
        [self dismissHintView];
    }
    sender.selected = select;
}

- (IBAction)didClickNavButton:(UIButton *)sender {
}

- (IBAction)didClickPostButton:(UIButton *)sender {
}

- (IBAction)didClickRepostCommentCheckmarkButton:(UIButton *)sender {
}

#pragma mark - MotionsViewController delegate

- (void)motionViewControllerDidCancel {
    [self.textView becomeFirstResponder];
}

- (void)motionViewControllerDidFinish:(UIImage *)image {
    [self.textView becomeFirstResponder];
    [self setMotionsImage:image];
}

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self.textView shouldChangeTextInRange:range replacementText:text currentHintView:self.currentHintView];
    if([text isEqualToString:@"@"] && !self.currentHintView) {
        [self presentAtHintView];
        self.atButton.selected = YES;
    } else if([text isEqualToString:@"#"] && !self.currentHintView) {
        [self presentTopicHintView];
        self.topicButton.selected = YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.textView textViewDidChangeWithCurrentHintView:self.currentHintView];
    [self updateTextCountAndPostButton];
    [self updateCurrentHintView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self.textView textViewDidChangeSelectionWithCurrentHintView:self.currentHintView];
}

#pragma mark - UIScrollView delegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.textView) {
        [self updateCurrentHintViewFrame];
    }
}

#pragma mark - PostRootView delegate

- (void)postRootView:(PostRootView *)view didObserveTouchOtherView:(UIView *)otherView {
    if(otherView == self.emoticonsButton)
        return;
    [self dismissHintView];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(self.currentActionSheetType == ActionSheetTypeDestruct) {
        if(buttonIndex == actionSheet.destructiveButtonIndex)
            [self.delegate postViewController:self willDropMessage:self.textView.text];
	} else if(self.currentActionSheetType == ActionSheetTypeMotions) {
        if(![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            buttonIndex += 1;
        }
        if(buttonIndex == MOTIONS_ACTION_SHEET_ALBUM_INDEX) {
            [self showAlbumImagePicker];
        } else if(buttonIndex == MOTIONS_ACTION_SHEET_SHOOT_INDEX) {
            MotionsViewController *vc = [[MotionsViewController alloc] init];
            vc.delegate = self;
            [vc show];
        } else if(buttonIndex == MOTIONS_ACTION_SHEET_EDIT_INDEX) {
            MotionsViewController *vc = [[MotionsViewController alloc] initWithImage:self.motionsOriginalImage useForAvatar:NO];
            vc.delegate = self;
            [vc show];
        } else if(buttonIndex == MOTIONS_ACTION_SHEET_CLEAR_INDEX) {
            [self.motionsImageView fadeOutWithCompletion:^{
                [self setMotionsImage:nil];
                self.motionsImageView.alpha = 1;
            }];
        }
    }
    self.actionSheet = nil;
    self.currentActionSheetType = ActionSheetTypeNone;
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.popoverController dismissPopoverAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    MotionsViewController *vc = [[MotionsViewController alloc] initWithImage:image useForAvatar:NO];
    vc.delegate = self;
    [vc show];
    
    self.popoverController = nil;
}

#pragma mark - UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popoverController = nil;
}

#pragma mark - Save image methods

- (void)saveImageInBackground:(UIImage *)image {
    if(image)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - PostHintTextView delegate

- (void)postHintTextViewCallDismissHintView {
    [self dismissHintView];
}

@end
