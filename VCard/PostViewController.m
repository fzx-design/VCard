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
#import "UIApplication+Addition.h"
#import "PostAtHintView.h"
#import "PostTopicHintView.h"
#import "UIView+Addition.h"
#import "WBClient.h"
#import "PostNewStatusViewController.h"
#import "PostRepostCommentViewController.h"

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

static NSString *weiboAtRegEx = @"[[a-z][A-Z][0-9][\\u4E00-\\u9FA5]-_\\s]*";
static NSString *weiboTopicRegEx = @"[[a-z][A-Z][0-9][\\u4E00-\\u9FA5]-_]*";

typedef enum {
    HintViewTypeNone,
    HintViewTypeAt,
    HintViewTypeTopic,
} HintViewType;

typedef enum {
    ActionSheetTypeNone,
    ActionSheetTypeDestruct,
    ActionSheetTypeMotions,
} ActionSheetType;

@interface PostViewController ()

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) PostHintView *currentHintView;
@property (nonatomic, readonly) CGPoint cursorPos;
@property (nonatomic, assign) NSRange currentHintStringRange;
@property (nonatomic, readonly) NSString *currentHintString;
@property (nonatomic, assign) HintViewType currentHintViewType;
@property (nonatomic, strong) EmoticonsViewController *emoticonsViewController;
@property (nonatomic, readonly) PostRootView *postRootView;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, assign) ActionSheetType currentActionSheetType;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, assign) CGRect startButtonFrame;
@property (nonatomic, readonly) CGPoint startButtonCenter;
@property (nonatomic, strong) NSString *prefixText;

@end

@implementation PostViewController

@synthesize motionsImageView = _motionsImageView;
@synthesize textView = _textView;
@synthesize textCountLabel = _textCountLabel;
@synthesize postView = _postView;
@synthesize textContainerView = _textContainerView;
@synthesize navButton = _navButton;
@synthesize atButton = _atButton;
@synthesize motionsButton = _motionsButton;
@synthesize emoticonsButton = _emoticonsButton;
@synthesize topicButton = _topicButton;
@synthesize repostCommentCheckmarkButton = _repostCommentCheckmarkButton;
@synthesize navActivityView = _navActivityView;
@synthesize navLabel = _navLabel;
@synthesize functionLeftNavView = _functionLeftNavView;
@synthesize functionLeftCheckmarkView = _functionLeftCheckmarkView;
@synthesize functionRightView = _functionRightView;
@synthesize delegate = _delegate;
@synthesize leftPaperImageView = _leftPaperImageView;
@synthesize rightPaperImageView = _rightPaperImageView;
@synthesize paperImageHolderView = _paperImageHolderView;
@synthesize leftPaperGloomImageView = _leftPaperGloomImageView;
@synthesize rightPaperGloomImageView = _rightPaperGloomImageView;
@synthesize topBarLabel = _topBarLabel;
@synthesize repostCommentButton = _repostCommentButton;
@synthesize motionsView = _motionsView;
@synthesize cancelButton = _cancelButton;
@synthesize postButton = _postButton;
@synthesize type = _type;

@synthesize keyboardHeight = _keyboardHeight;
@synthesize currentHintView = _currentHintView;
@synthesize currentHintStringRange = _currentHintStringRange;
@synthesize currentHintString = _currentHintString;
@synthesize currentHintViewType = _currentHintViewType;
@synthesize emoticonsViewController = _emoticonsViewController;
@synthesize currentActionSheetType = _currentActionSheetType;
@synthesize actionSheet = _actionSheet;
@synthesize popoverController = _pc;
@synthesize motionsOriginalImage = _motionsOriginalImage;
@synthesize startButtonFrame = _startButtonFrame;
@synthesize prefixText = _prefixText;
@synthesize postImageView = _postImageView;

+ (id)getNewStatusViewControllerWithDelegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeNewStatus delegate:delegate weiboID:nil replyID:nil weiboOwnerName:nil weiboContent:nil];
}

+ (id)getRepostViewControllerWithWeiboID:(NSString *)weiboID
                          weiboOwnerName:(NSString *)ownerName
                                 content:(NSString *)content
                                Delegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeRepost delegate:delegate weiboID:weiboID replyID:nil weiboOwnerName:ownerName weiboContent:content];
}

+ (id)getCommentWeiboViewControllerWithWeiboID:(NSString *)weiboID
                                weiboOwnerName:(NSString *)ownerName
                                Delegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeCommentWeibo delegate:delegate weiboID:weiboID replyID:nil weiboOwnerName:ownerName weiboContent:nil];
}

+ (id)getCommentReplyViewControllerWithWeiboID:(NSString *)weiboID
                                replyID:(NSString *)replyID
                                weiboOwnerName:(NSString *)ownerName
                                      Delegate:(id<PostViewControllerDelegate>)delegate {
    return [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeCommentReply delegate:delegate weiboID:weiboID replyID:replyID weiboOwnerName:ownerName weiboContent:nil];
}

+ (id)getPostViewControllerViewWithType:(PostViewControllerType)type
                               delegate:(id<PostViewControllerDelegate>)delegate
                                weiboID:(NSString *)weiboID
                                replyID:(NSString *)replyID
                         weiboOwnerName:(NSString *)ownerName
                           weiboContent:(NSString *)content {
    PostViewController *vc = nil;
    if(type == PostViewControllerTypeNewStatus) {
        vc = [[PostNewStatusViewController alloc] init];
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
    
    vc.type = type;
    vc.delegate = delegate;
    return vc;
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
    
    self.navActivityView.hidden = YES;
    self.navLabel.text = @"";
    _functionRightViewInitFrame = self.functionRightView.frame;
    self.postRootView.delegate = self;
    
    [self configureViewFrame];
    [self configureMotionsImageView];
    [self configureTextView];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(deviceRotateDidChanged:) name:kNotificationNameOrientationChanged object:nil];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self unfoldPaperAnimation];
    [self moveFromStartButtonAnimation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.motionsImageView = nil;
    self.textView = nil;
    self.textCountLabel = nil;
    self.postView = nil;
    self.textContainerView = nil;
    self.navButton = nil;
    self.atButton = nil;
    self.emoticonsButton = nil;
    self.topicButton = nil;
    self.navActivityView = nil;
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Notification handlers

- (void)deviceRotateDidChanged:(NSNotification *)notification {
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
    
    [self dismissPopover];
}

#pragma mark - Logic methods

- (PostRootView *)postRootView {
    return (PostRootView *)self.view;
}

- (EmoticonsViewController *)emoticonsViewController {
    if(!_emoticonsViewController) {
        _emoticonsViewController = [[EmoticonsViewController alloc] init];
        _emoticonsViewController.delegate = self;
    }
    return _emoticonsViewController;
}

- (NSString *)currentHintString {
    return [self.textView.text substringWithRange:self.currentHintStringRange];
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
        //NSLog(@"text scroll view offset y:%f", textScrollViewOffsetY);
        cursorPos.y += self.textContainerView.frame.origin.y + self.textView.frame.origin.y + HINT_VIEW_OFFSET.height - textScrollViewOffsetY;
    }
    //NSLog(@"cursor pos(%@)", NSStringFromCGPoint(cursorPos));
    return cursorPos;
}

- (BOOL)isAtHintStringValid {
    NSLog(@"is at (%@) valid?", self.currentHintString);
    NSRange range = [self.currentHintString rangeOfString:weiboAtRegEx options:NSRegularExpressionSearch];
    return range.length == self.currentHintString.length;
}

- (BOOL)isTopicHintStringValid {
    return YES; // no limit
    NSLog(@"is topic (%@) valid?", self.currentHintString);
    NSRange range = [self.currentHintString rangeOfString:weiboTopicRegEx options:NSRegularExpressionSearch];
    return range.length == self.currentHintString.length;
}

- (void)replaceHintWithResult:(NSString *)text {
    int location = self.currentHintStringRange.location;
    NSString *replaceText = text;
    if([self.currentHintView isMemberOfClass:[PostAtHintView class]]) {
        replaceText = [NSString stringWithFormat:@"%@ ", replaceText];
    } else if([self.currentHintView isMemberOfClass:[PostTopicHintView class]] && _needFillPoundSign) {
        replaceText = [NSString stringWithFormat:@"%@#", replaceText];
    }
    
    UITextPosition *beginning = self.textView.beginningOfDocument;
    UITextPosition *start = [self.textView positionFromPosition:beginning offset:self.currentHintStringRange.location];
    UITextPosition *end = [self.textView positionFromPosition:start offset:self.currentHintStringRange.length];
    UITextRange *textRange = [self.textView textRangeFromPosition:start toPosition:end];
    [self.textView replaceRange:textRange withText:replaceText];
    
    NSRange range = NSMakeRange(location + replaceText.length, 0);
    if([self.currentHintView isMemberOfClass:[PostTopicHintView class]])
        range.location += 1;
    self.textView.selectedRange = range;
    self.currentHintStringRange = range;
    if([self.currentHintView isKindOfClass:[PostHintView class]])
        [self dismissHintView];
}

- (void)setMotionsImage:(UIImage *)image {
    CGRect imageViewRect = CGRectMake(0, 0, self.motionsImageView.frame.size.width, self.motionsImageView.frame.size.height);
    CGRect imageRect;
    if(image.size.width > image.size.height) {
        imageRect = CGRectMake((image.size.width - image.size.height) / 2, 0, image.size.height, image.size.height);
    } else {
        imageRect = CGRectMake(0, (image.size.height - image.size.width) / 2, image.size.width, image.size.width);
    }
    UIImage *optimizedImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, imageRect)];
    
    UIGraphicsBeginImageContext(imageViewRect.size);
    [optimizedImage drawInRect:CGRectMake(2, 2, imageViewRect.size.width - 4, imageViewRect.size.height - 4)];
    optimizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.motionsImageView.image = optimizedImage;
    self.motionsOriginalImage = image;
}

- (void)configurePaperHolderImageView {
    UIGraphicsBeginImageContext(self.postView.bounds.size);
    [self.postView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect leftRect = CGRectMake(0, 0, viewImage.size.width / 2, viewImage.size.height);
    CGRect rightRect = CGRectMake(viewImage.size.width / 2, 0, viewImage.size.width / 2, viewImage.size.height);
    UIImage *leftImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, leftRect)];
    UIImage *rightImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, rightRect)];
    
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
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
    if(self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
}

- (void)configureTextView {
    [self updateTextCountAndPostButton];
    [self.textView becomeFirstResponder];
    self.textView.selectedRange = NSMakeRange(0, 0);
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
    if(weiboTextBackwardsCount < 0) {
        self.postButton.enabled = NO;
        self.postImageView.highlighted = YES;
        self.textCountLabel.highlighted = YES;
    } else {
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
    self.currentHintView.delegate = self;
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
    self.currentHintView.delegate = self;
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
        if([self isAtHintStringValid])
            [self.currentHintView updateHint:self.currentHintString];
        else {
            NSLog(@"at hint not valid");
            [self dismissHintView]; 
        }
    } else if([self.currentHintView isMemberOfClass:[PostTopicHintView class]]) {
        if([self isTopicHintStringValid])
            [self.currentHintView updateHint:self.currentHintString];
        else {
            NSLog(@"topic hint not valid");
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
        //NSLog(@"cursor pos:(%f, %f)", cursorPos.x, cursorPos.y);
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
    //NSLog(@"dismiss hint view");
    self.currentHintStringRange = NSMakeRange(0, 0);
    UIView *currentHintView = self.currentHintView;
    self.currentHintView = nil;
    [currentHintView fadeOutWithCompletion:^{
        [currentHintView removeFromSuperview];
    }];
    self.atButton.selected = NO;
    self.topicButton.selected = NO;
    self.emoticonsButton.selected = NO;
    _needFillPoundSign = NO;
    self.postRootView.observingViewTag = PostRootViewSubviewTagNone;
}

- (void)presentEmoticonsView {
    //NSLog(@"present emoticons view");
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
    self.currentHintStringRange = NSMakeRange(self.textView.selectedRange.location, 0);
    [self checkCurrentHintViewFrame];
}

- (void)showViewFromRect:(CGRect)rect {
    self.startButtonFrame = rect;
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

- (void)unfoldPaperAnimation {
    [self configurePaperHolderImageView];    
    self.postView.hidden = YES;
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:FOLD_PAPER_ANIMATION_DURATION] forKey: kCATransactionAnimationDuration];
    [CATransaction setCompletionBlock:^{
		self.postView.hidden = NO;
        self.paperImageHolderView.hidden = YES;
	}];
    
    double factor = - 1 * M_PI / 180;
    
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:@"easeOut"]];
	[animation setFromValue:[NSNumber numberWithDouble:-90 * factor]];
	[animation setToValue:[NSNumber numberWithDouble:0]];
    [animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.leftPaperImageView.layer addAnimation:animation forKey:nil];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	[animation setFromValue:[NSNumber numberWithDouble:90 * factor]];
	[animation setToValue:[NSNumber numberWithDouble:0]];
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
    [CATransaction setValue:[NSNumber numberWithFloat:UNFOLD_PAPER_ANIMATION_DURATION] forKey: kCATransactionAnimationDuration];
    
    double factor = - 1 * M_PI / 180;
    
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:@"easeIn"]];
	[animation setFromValue:[NSNumber numberWithDouble:0]];
	[animation setToValue:[NSNumber numberWithDouble:-90 * factor]];
    [animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.leftPaperImageView.layer addAnimation:animation forKey:nil];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	[animation setFromValue:[NSNumber numberWithDouble:0]];
	[animation setToValue:[NSNumber numberWithDouble:90 * factor]];
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
    if(self.motionsImageView.image) {
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
        [self.textView insertText:@"@"];
        [self presentAtHintView];
        NSInteger location = self.textView.selectedRange.location;
        NSRange range = NSMakeRange(location, 0);
        self.currentHintStringRange = range;
    } else {
        [self dismissHintView];
    }
    sender.selected = select;
}

- (IBAction)didClickTopicButton:(UIButton *)sender {
    BOOL select = !sender.isSelected;
    if(select) {
        [self.textView insertText:@"##"];
        [self presentTopicHintView];
        NSInteger location = self.textView.selectedRange.location;
        NSRange range = NSMakeRange(location - 1, 0);
        self.currentHintStringRange = range;
        self.textView.selectedRange = range;
        NSLog(@"hint range:(%d, %d)", self.currentHintStringRange.location, self.currentHintStringRange.length);
    } else {
        if(!_needFillPoundSign)
            self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location + 1, 0);
        [self dismissHintView];
    }
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
    [[UIApplication sharedApplication].rootViewController dismissModalViewControllerAnimated:YES];
}

- (void)motionViewControllerDidFinish:(UIImage *)image {
    [self setMotionsImage:image];
    [[UIApplication sharedApplication].rootViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"change text in range(%d, %d), replace text:%@", range.location, range.length, text);
    if(self.currentHintView) {
        if([self.currentHintView isMemberOfClass:[PostAtHintView class]] && [text isEqualToString:@" "]) {
            [self dismissHintView];
            return YES;
        }
    } else if([text isEqualToString:@"@"]) {
        [self presentAtHintView];
        self.atButton.selected = YES;
        self.currentHintStringRange = NSMakeRange(range.location + text.length - range.length, 0);
    } else if([text isEqualToString:@"#"]) {
        [self presentTopicHintView];
        self.topicButton.selected = YES;
        self.currentHintStringRange = NSMakeRange(range.location + text.length - range.length, 0);
        _needFillPoundSign = YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if([self.currentHintView isKindOfClass:[PostHintView class]]) {
        NSLog(@"text view selected range:%@", NSStringFromRange(self.textView.selectedRange));
        NSInteger length = self.textView.selectedRange.location - self.currentHintStringRange.location;
        if(length < 0)
            [self dismissHintView];
        else {
            self.currentHintStringRange = NSMakeRange(self.currentHintStringRange.location, length);
            NSLog(@"hint range:(%d, %d)", self.currentHintStringRange.location, self.currentHintStringRange.length);
        }
    } else if(self.currentHintView) {
        self.currentHintStringRange = NSMakeRange(self.textView.selectedRange.location, 0);
    }
    [self updateTextCountAndPostButton];
    [self updateCurrentHintView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"change selection:(%d, %d)", textView.selectedRange.location, textView.selectedRange.length);
    if([self.currentHintView isKindOfClass:[PostHintView class]]) {
        if(textView.selectedRange.location < self.currentHintStringRange.location
           || textView.selectedRange.location > self.currentHintStringRange.location + self.currentHintStringRange.length) {
            [self dismissHintView];
        }
    }
}

#pragma mark - PostHintView delegate

- (void)postHintView:(PostHintView *)hintView didSelectHintString:(NSString *)text {
    [self replaceHintWithResult:text];
}

#pragma mark - UIScrollView delegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.textView) {
        [self updateCurrentHintViewFrame];
    }
}

#pragma mark - PostRootView delegate

- (void)postRootView:(PostRootView *)view didObserveTouchOtherView:(UIView *)otherView {
    //NSLog(@"touch other view");
    if(otherView == self.emoticonsButton)
        return;
    [self dismissHintView];
}

#pragma mark - EmoticonsViewController delegate

- (void)didClickEmoticonsButtonWithInfoKey:(NSString *)key {
    [self replaceHintWithResult:key];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(self.currentActionSheetType == ActionSheetTypeDestruct) {
        if(buttonIndex == actionSheet.destructiveButtonIndex)
            [self.delegate postViewController:self willDropMessage:self.textView.text];
	} else if(self.currentActionSheetType == ActionSheetTypeMotions) {
        if(buttonIndex == MOTIONS_ACTION_SHEET_ALBUM_INDEX) {
            
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            ipc.delegate = self;
            ipc.allowsEditing = NO;
            
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:ipc];
            self.popoverController = pc;
            self.popoverController.contentViewController.view.autoresizingMask = !UIViewAutoresizingFlexibleTopMargin;
            pc.delegate = self;
            [pc presentPopoverFromRect:self.motionsButton.bounds inView:self.motionsButton
              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else if(buttonIndex == MOTIONS_ACTION_SHEET_SHOOT_INDEX) {
            MotionsViewController *vc = [[MotionsViewController alloc] init];
            vc.delegate = self;
            [[UIApplication sharedApplication].rootViewController presentModalViewController:vc animated:YES];
        } else if(buttonIndex == MOTIONS_ACTION_SHEET_EDIT_INDEX) {
            MotionsViewController *vc = [[MotionsViewController alloc] initWithImage:self.motionsOriginalImage];
            vc.delegate = self;
            [[UIApplication sharedApplication].rootViewController presentModalViewController:vc animated:YES];
        } else if(buttonIndex == MOTIONS_ACTION_SHEET_CLEAR_INDEX) {
            [self.motionsImageView fadeOutWithCompletion:^{
                self.motionsImageView.image = nil;
                self.motionsOriginalImage = nil;
                self.motionsImageView.alpha = 1;
            }];
        }
    }
    NSLog(@"dismiss action sheet");
    self.actionSheet = nil;
    self.currentActionSheetType = ActionSheetTypeNone;
}

#pragma mark -
#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.popoverController dismissPopoverAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    MotionsViewController *vc = [[MotionsViewController alloc] initWithImage:image];
    vc.delegate = self;
    [[UIApplication sharedApplication].rootViewController presentModalViewController:vc animated:YES];
    
    self.popoverController = nil;
}

#pragma mark -
#pragma mark UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"dismiss popover");
    self.popoverController = nil;
}

@end
