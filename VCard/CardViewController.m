//
//  CardViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CardViewController.h"
#import "UIImageView+Addition.h"
#import "UIApplication+Addition.h"
#import "NSDateAddition.h"
#import "ResourceProvider.h"
#import "User.h"
#import "Comment.h"
#import "WBClient.h"
#import "UIApplication+Addition.h"
#import "UIView+Resize.h"
#import "EmoticonsInfoReader.h"
#import "InnerBrowserViewController.h"
#import "NSUserDefaults+Addition.h"
#import "RootViewController.h"
#import "ErrorIndicatorViewController.h"
#import "DirectMessage.h"
#import "TTTAttributedLabelConfiguer.h"

#define ACTION_POPOVER_CONTAINER_CONTAINER_VIEW 3002

#define CARD_CROP_INSETS UIEdgeInsetsMake(-10, -10, 0, -10);

@interface CardViewController () {
    BOOL _doesImageExist;
    BOOL _alreadyConfigured;
    BOOL _imageAlreadyLoaded;
    CGFloat _scale;
    CGFloat _lastScale;
    CGFloat _currentScale;
    CGPoint _lastPoint;
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
    UIRotationGestureRecognizer *_rotationGestureRecognizer;
    UITapGestureRecognizer *_tapGestureRecognizer;
}

@property (readonly) BOOL isCardDeletable;
@property (readonly) BOOL isCardFavorited;
@property (nonatomic, weak) UIAlertView *deleteStatusAlertView;

@end

@implementation CardViewController

@synthesize status = _status;
@synthesize imageHeight = _imageHeight;
@synthesize actionPopoverViewController = _actionPopoverViewController;
@synthesize deleteStatusAlertView = _deleteStatusAlertView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _alreadyConfigured = NO;
        _imageAlreadyLoaded = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.originalStatusLabel.delegate = self;
    self.repostStatusLabel.delegate = self;
    
    self.statusInfoView.clipsToBounds = NO;
    self.repostStatusInfoView.clipsToBounds = NO;
    
    self.locationLabel.hidden = YES;
    self.locationPinImageView.hidden = YES;
    self.clipImageView.layer.anchorPoint = CGPointMake(0.9, 0.05);
    [self.clipImageView resetOrigin:CGPointMake(300.0, -4.0)];
    
    self.repostUserNameButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    UITapGestureRecognizer *originalTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewUserInfo)];
    [self.originalUserAvatar addGestureRecognizer:originalTapGesture];
    
    UITapGestureRecognizer *repostTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewUserInfo)];
    [self.originalUserAvatar addGestureRecognizer:repostTapGesture];
    
    _rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
    _rotationGestureRecognizer.delegate = self;
    [self.statusImageView addGestureRecognizer:_rotationGestureRecognizer];
    
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    _pinchGestureRecognizer.delegate = self;
    [self.statusImageView addGestureRecognizer:_pinchGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    _tapGestureRecognizer.numberOfTouchesRequired = 1;
    _tapGestureRecognizer.delegate = self;
    [self.statusImageView addGestureRecognizer:_tapGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionPopoverPinchGesture:)];
    [self.view addGestureRecognizer:pinchGesture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(recoverFromPause)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Functional Method

+ (CGFloat)heightForStatus:(Status *)status_ andImageHeight:(NSInteger)imageHeight_ isWaterflowCard:(BOOL)isWaterflowCard
{
    status_.text = [TTTAttributedLabelConfiguer replaceEmotionStrings:status_.text];
    if (status_.repostStatus) {
        status_.repostStatus.text = [TTTAttributedLabelConfiguer replaceEmotionStrings:status_.repostStatus.text];
    }
    
    BOOL isReposted = status_.repostStatus != nil;
    BOOL hasCardTail = [status_ hasLocationInfo] || YES;
    Status *targetStatus = isReposted ? status_.repostStatus : status_;
    
    BOOL isPictureEnabled = !isWaterflowCard || [NSUserDefaults isPictureEnabled];
    BOOL doesImageExist = targetStatus.bmiddlePicURL && ![targetStatus.bmiddlePicURL isEqualToString:@""] && isPictureEnabled;

    CGFloat height = CardSizeTopViewHeight + CardSizeBottomViewHeight + CardSizeUserAvatarHeight;
    height += [TTTAttributedLabelConfiguer heightForCellWithText:status_.text] + CardSizeTextGap;
        
    if (isReposted) {
        height +=  CardSizeTopViewHeight + CardSizeBottomViewHeight + CardSizeUserAvatarHeight + CardSizeRepostHeightOffset;
        height += [TTTAttributedLabelConfiguer heightForCellWithText:status_.repostStatus.text] + CardSizeTextGap;
    }
    
    if (doesImageExist) {
        height += imageHeight_ + CardSizeImageGap;
    }
    
    if (hasCardTail) {
        height += CardTailHeight;
    }
    
    return height;
}

+ (CGFloat)heightForTextContent:(NSString *)text
{    
    CGFloat height = 0.0;
    height +=  CardSizeTopViewHeight + CardSizeBottomViewHeight + CardSizeUserAvatarHeight + CardSizeRepostHeightOffset;
    height += [TTTAttributedLabelConfiguer heightForCellWithText:text] + CardSizeTextGap + 24.0;
    
    return height;
}

- (void)configureCardWithStatus:(Status*)status_
                    imageHeight:(CGFloat)imageHeight_
                      pageIndex:(NSInteger)pageIndex_
                    currentUser:(User *)user
             coreDataIdentifier:(NSString *)identifier
{
    if (_alreadyConfigured) {
        return;
    }
    
    _alreadyConfigured = YES;
    _coreDataIdentifier = identifier;
    self.statusImageView.imageViewMode = CastViewImageViewModeNormal;
    _pageIndex = pageIndex_;
    
    [self setUpStatus:status_];
    
    self.imageHeight = _doesImageExist ? imageHeight_ : 0.0;
    
    [self setUpStatusView];
    
    [self setUpRepostView];
    
    [self setUpStatusImageView];
    
    [self setUpButtonPosition];
    
    [self setUpCardTail];
        
}

- (void)setUpStatus:(Status*)status_
{
    self.status = status_;
    _isReposted = self.status.repostStatus != nil;
    
    BOOL isPictureEnabled = _isNotWaterflowCard || [NSUserDefaults isPictureEnabled];
    Status *imageStatus = _isReposted ? self.status.repostStatus : self.status;
    _doesImageExist = imageStatus.bmiddlePicURL && ![imageStatus.bmiddlePicURL isEqualToString:@""] && isPictureEnabled;
    
}

- (void)setUpStatusImageView
{
    self.statusImageView.hidden = !_doesImageExist;
    self.clipImageView.hidden = !_doesImageExist;
    
    if (_doesImageExist) {
        
        CGRect frame = self.statusImageView.frame;
        frame.origin = CGPointMake(-4.0, 13.0);
        frame.size = CGSizeMake(StatusImageWidth, 200);
        
        self.statusImageView.frame = frame;
        
        [self.statusImageView resetHeight:self.imageHeight];
        
        [self.statusImageView clearCurrentImage];
        
        [self updateImageButtonWithType:self.status.type URLString:self.status.mediaLink];
    }
}

- (void)loadImage
{
    if (_doesImageExist && !_imageAlreadyLoaded) {
        
        _imageAlreadyLoaded = YES;
        
        Status *targetStatus = _isReposted ? self.status.repostStatus : self.status;
        
        NSString *imageURL = [UIApplication isRetinaDisplayiPad] ? targetStatus.originalPicURL : targetStatus.bmiddlePicURL;
        
        [self.statusImageView loadImageFromURL:imageURL completion:nil];
    }
}

- (void)prepareForReuse
{
    _alreadyConfigured = NO;
    _imageAlreadyLoaded = NO;
    
    self.locationPinImageView.hidden = YES;
    self.locationLabel.hidden = YES;
    self.locationLabel.text = @"";
    
    [self.originalUserAvatar reset];
    [self.repostUserAvatar reset];
    [self.statusImageView reset];
}

- (void)setUpStatusView
{
    self.favoredImageView.hidden = ![self.status.favorited boolValue];
    
    CGFloat originY = _doesImageExist ? self.imageHeight + 30 : 20;
    Status *targetStatus = _isReposted ? self.status.repostStatus : self.status;
    
    [TTTAttributedLabelConfiguer setCardViewController:self StatusTextLabel:self.originalStatusLabel withText:targetStatus.text];
    
    [self.originalUserAvatar loadImageFromURL:targetStatus.author.profileImageURL completion:nil];
    [self.originalUserAvatar setVerifiedType:[targetStatus.author verifiedTypeOfUser]];
    
    [self.originalUserNameLabel setText:targetStatus.author.screenName];
    
    //Save the screen name
    [self.originalUserNameButton setTitle:targetStatus.author.screenName forState:UIControlStateDisabled];
        
    CGFloat statusViewHeight = CardSizeTopViewHeight + CardSizeBottomViewHeight +
                            CardSizeUserAvatarHeight + CardSizeTextGap + 
                            self.originalStatusLabel.frame.size.height;
    if (_doesImageExist) {
        statusViewHeight += CardSizeImageGap;
    }
    
    if (!_isReposted) {
        statusViewHeight += CardTailHeight;
    }
    
    [self.statusInfoView resetFrameWithOrigin:CGPointMake(0.0, originY) 
                                         size:CGSizeMake(self.view.frame.size.width, statusViewHeight)];
    
    [self.cardBackground resetHeight:self.imageHeight + statusViewHeight];
    
}

- (void)setUpRepostView
{
    self.repostCardBackground.hidden = !_isReposted;
    if (_isReposted) {
        self.repostCardBackground.hidden = NO;
        
        Status *targetStatus = self.status;
        
        [TTTAttributedLabelConfiguer setCardViewController:self StatusTextLabel:self.repostStatusLabel withText:targetStatus.text];
        [self.repostUserAvatar loadImageFromURL:targetStatus.author.profileImageURL completion:nil];
        [self.repostUserAvatar setVerifiedType:[targetStatus.author verifiedTypeOfUser]];
        
        NSString *screenName = [NSString stringWithFormat:@"%@ 转发并评论了以上卡片", targetStatus.author.screenName];
        
        [self.repostUserNameLabel setText:screenName];
        
        //Save the screen name
        [self.repostUserNameButton setTitle:targetStatus.author.screenName forState:UIControlStateDisabled];
        
        
        CGPoint newOrigin = CGPointMake(self.cardBackground.frame.origin.x, self.cardBackground.frame.origin.y + self.cardBackground.frame.size.height - 8);
        [self.repostCardBackground resetOrigin:newOrigin];
        
        CGFloat repostStatusViewHeight = CardSizeTopViewHeight + CardSizeBottomViewHeight +
                                        CardSizeUserAvatarHeight + CardSizeTextGap + 
                                        self.repostStatusLabel.frame.size.height;
        
        repostStatusViewHeight += CardTailHeight;
        
        [self.repostCardBackground resetHeight:repostStatusViewHeight];
        [self.repostStatusInfoView resetHeight:repostStatusViewHeight];

    }
}

- (void)setUpButtonPosition
{
    CGPoint origin = _isReposted ? self.repostCardBackground.frame.origin : self.statusInfoView.frame.origin;
    CGFloat offset = _isReposted ? 7.0 : -8.0;
    
    [self.repostButton resetOriginY:origin.y + offset];
    [self.commentButton resetOriginY:origin.y + offset];
    
    self.commentButton.hidden = _isNotWaterflowCard;
    
}

- (void)setUpCardTail
{
    CGFloat cardTailOriginY = self.view.frame.size.height + CardTailOffset;
    
    [self.locationPinImageView resetOriginY:cardTailOriginY + 2];
    [self.locationLabel resetOriginY:cardTailOriginY];
    [self.timeStampLabel resetOriginY:cardTailOriginY];

    if (self.status.cacheDateString == nil) {
        self.status.cacheDateString = [self.status.createdAt stringRepresentation];
    }
    
    [self.timeStampLabel setText:self.status.cacheDateString];
    
    [self setUpLocationInfo];
}

- (void)setUpLocationInfo
{
    if ([self.status locationInfoAlreadyLoaded]) {
        [self showLocationInfo];
    }
    
    if ([self.status hasLocationInfo]) {
        
        WBClient *client = [WBClient client];
        [client setCompletionBlock:^(WBClient *client) {
            if (!client.hasError) {
                
                NSString *locationString;
                NSArray* array = (NSArray*)client.responseJSONObject;
                if (array.count > 0) {
                    NSDictionary *dic = (NSDictionary *)[array objectAtIndex:0];

                    NSString *city = [dic objectForKey:@"city_name"];
                    NSString *disctrict = [dic objectForKey:@"district_name"];
                    NSString *name = [dic objectForKey:@"name"];
                    
                    locationString = city == nil ? @"" : city;
                    locationString = disctrict == nil ? locationString : [locationString stringByAppendingString:disctrict];
                    locationString = name == nil ? locationString : [locationString stringByAppendingString:name];
                }
                
                if ([self.status.statusID isEqualToString:_previousStatus.statusID]) {
                    self.status.location = locationString;
                } else {
                    if (_previousStatus) {
                        _previousStatus.location = locationString;
                    }
                }
                
                [self showLocationInfo];
            }
        }];
        float lat = [self.status.lat floatValue];
        float lon = [self.status.lon floatValue];
        
        _previousStatus = self.status;
        [client getAddressFromGeoWithCoordinate:[[NSString alloc] initWithFormat:@"%f,%f", lon, lat]];
    }
}

- (void)showLocationInfo
{
    self.locationPinImageView.hidden = NO;
    self.locationLabel.hidden = NO;
    self.locationLabel.text = self.status.location;
}

- (void)recognizerLinkType:(NSString *)url
{
    if ([self.status.type isEqualToString:kStatusTypeNone]) {
        WBClient *client = [WBClient client];
        
        [client setCompletionBlock:^(WBClient *client) {
            if (!client.hasError) {
                NSArray *array = client.responseJSONObject;
                NSDictionary *dict = [array lastObject];
                if ([dict isKindOfClass:[NSDictionary class]] && [[dict objectForKey:@"result"] boolValue]) {
                    
                    int type = [[dict objectForKey:@"type"] intValue];
                    NSString *urlLong = [dict objectForKey:@"url_long"];
                    Status *status = [Status statusWithID:client.statusID inManagedObjectContext:self.managedObjectContext withOperatingObject:_coreDataIdentifier];
                    
                    if ([status.type isEqualToString:kStatusTypeMedia] || [status.type isEqualToString:kStatusTypeVote]) {
                        return ;
                    }
                    
                    if (type == 5) {
                        status.type = kStatusTypeVote;
                    } else if (type == 1 || type == 2) {
                        status.type = kStatusTypeMedia;
                    } else {
                        status.type = kStatusTypeNormal;
                    }
                             
                    status.mediaLink = urlLong;
                                        
                    if ([status.statusID isEqualToString:self.status.statusID]) {
                        [self updateImageButtonWithType:status.type URLString:urlLong];
                    }
                }
            }
        }];
        
        client.statusID = self.status.statusID;        
        [client getLongURLWithShort:url];
    }
}

- (void)updateImageButtonWithType:(NSString *)type URLString:(NSString *)url
{
    if ([type isEqualToString:kStatusTypeMedia]) {
        [self.statusImageView setUpPlayButtonWithURL:url type:kActionButtonTypeMedia];
    } else if ([type isEqualToString:kStatusTypeVote]) {
        [self.statusImageView setUpPlayButtonWithURL:url type:kActionButtonTypeVote];
    }
}


#pragma mark - IBActions

- (IBAction)nameButtonClicked:(id)sender
{
    NSString *userName = [((UIButton *)sender) titleForState:UIControlStateDisabled];
    [self sendUserNameClickedNotificationWithName:userName];
}

- (IBAction)didClickCommentButton:(UIButton *)sender
{
    [self sendCommentButtonClickedNotification];
}

- (IBAction)didClickRepostButton:(UIButton *)sender {
    sender.highlighted = NO;
    [self showActionPopoverAnimated:YES];
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)userName
{
    [self sendUserNameClickedNotificationWithName:userName];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithQuate:(NSString *)quate
{
    [self sendShowTopicNotification:quate];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [InnerBrowserViewController loadLinkWithURL:url];
}


#pragma mark - Send Notification
- (void)sendUserNameClickedNotificationWithName:(NSString *)userName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:[NSDictionary dictionaryWithObjectsAndKeys:userName, kNotificationObjectKeyUserName, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (void)sendCommentButtonClickedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowCommentList object:[NSDictionary dictionaryWithObjectsAndKeys:self.status, kNotificationObjectKeyStatus, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (void)sendShowRepostListNotification
{
    Status *targetStatus = _isReposted ? self.status.repostStatus : self.status;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowRepostList object:[NSDictionary dictionaryWithObjectsAndKeys:targetStatus, kNotificationObjectKeyStatus, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (void)sendShowTopicNotification:(NSString *)searchKey
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowTopic object:[NSDictionary dictionaryWithObjectsAndKeys:searchKey, kNotificationObjectKeySearchKey, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

#pragma mark - PostViewController Delegate

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message {
    [vc dismissViewUpwards];
}

- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message {
    if(vc.type == PostViewControllerTypeRepost)
        [vc dismissViewToRect:[self.view convertRect:self.repostButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
    else
        [vc dismissViewToRect:[self.view convertRect:self.commentButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
}

#pragma mark - ActionPopover Operations

- (void)repostStatus
{
    NSString *targetUserName = self.status.author.screenName;
    NSString *targetStatusID = self.status.statusID;
    NSString *targetStatusContent = nil;
    if(self.status.repostStatus)
        targetStatusContent = self.status.text;
    CGRect frame = [self.view convertRect:self.repostButton.frame toView:[UIApplication sharedApplication].rootViewController.view];
    PostViewController *vc = [PostViewController getRepostViewControllerWithWeiboID:targetStatusID
                                                                     weiboOwnerName:targetUserName
                                                                            content:targetStatusContent
                                                                           delegate:self];
    [vc showViewFromRect:frame];
}

- (void)copyStatus
{
    NSString *statusText = [NSString stringWithFormat:@"%@", self.status.text];
    if (_isReposted) {
        statusText = [statusText stringByAppendingFormat:@":@%@:%@", self.status.repostStatus.author.screenName, self.status.repostStatus.text];
    }
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:statusText];
    
    [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureSuccess contentText:@"已复制"];
}

- (void)shareStatusByMail
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    picker.modalPresentationStyle = UIModalPresentationPageSheet;
    
    NSString *subject = [NSString stringWithFormat:@"分享一条来自新浪的微博，作者：%@", self.status.author.screenName];
    
    [picker setSubject:subject];
    
    NSString *emailBody = [NSString stringWithFormat:@"%@", self.status.text];
    if (_isReposted) {
        emailBody = [emailBody stringByAppendingFormat:@" %@", self.status.repostStatus.text];
    }
    [picker setMessageBody:emailBody isHTML:NO];
    
    if (_doesImageExist) {
        NSData *imageData = UIImageJPEGRepresentation(self.statusImageView.image, 0.8);
        [picker addAttachmentData:imageData mimeType:@"image/jpeg" fileName:NSLocalizedString(@"微博图片", nil)];
    }
    
    [[[UIApplication sharedApplication] rootViewController] presentModalViewController:picker animated:YES];
}


- (void)deleteStatus
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldDeleteStatus object:self.status.statusID];
        } else {
            //TODO: Handle Error
        }
    }];
    
    [client deleteStatus:self.status.statusID];
}


#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError*)error
{
	NSString *message = nil;
	switch (result)
	{
		case MFMailComposeResultSaved:
			message = NSLocalizedString(@"保存成功", nil);
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
			break;
		case MFMailComposeResultSent:
			message = NSLocalizedString(@"发送成功", nil);
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
			break;
		case MFMailComposeResultFailed:
			message = NSLocalizedString(@"发送失败", nil);
			break;
		default:
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
			return;
	}
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message 
														message:nil
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"确定", nil)
											  otherButtonTitles:nil];
	[alertView show];
}

#pragma mark - Handle Pinch Gesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    return YES;
}

#pragma mark Pinch
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender
{
    [self recordPinchGestureInitialStatus:sender];
    
    [self handleImageViewPinchWithGesture:sender];
}

- (void)recordPinchGestureInitialStatus:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
        _currentScale = 1.0;
        _scale = 1.0;
        _lastPoint = [sender locationInView:[UIApplication sharedApplication].rootViewController.view];
        
        [self.statusImageView resetCurrentScale];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                
        if (self.statusImageView.imageViewMode == CastViewImageViewModeNormal) {
            if (sender.velocity > 2.0) {
                [self willOpenDetailImageViewDirectly];
            } else {
                [self willOpenDetailImageView];
            }
            return;
        }
    }
}

- (void)handleImageViewPinchWithGesture:(UIPinchGestureRecognizer *)sender
{
    BOOL gestureEnd = [self checkAndHanlePinchGestureEnd:sender];
    
    if (!gestureEnd) {
        [self resetScaleWithPinchGesture:sender];
        
        [self resetPositionWithPinchGesture:sender];
        
        [self.statusImageView pinchResizeToScale:self.statusImageView.currentScale];
        
        if ([_delegate respondsToSelector:@selector(didChangeImageScale:)]) {
            [_delegate didChangeImageScale:sender.scale];
        }
    }
}

- (BOOL)checkAndHanlePinchGestureEnd:(UIPinchGestureRecognizer *)sender
{
    BOOL result = NO;
    if (sender.state == UIGestureRecognizerStateEnded || (sender.state == UIGestureRecognizerStateChanged && sender.numberOfTouches < 2) || sender.numberOfTouches > 2) {
        
        self.statusImageView.userInteractionEnabled = NO;
        _pinchGestureRecognizer.enabled = NO;
        _rotationGestureRecognizer.enabled = NO;
        
        BOOL shouldReturn = YES;
        
        shouldReturn = [self.statusImageView scaleOffset] < 0.2 && sender.velocity < 2;
        
        if (shouldReturn) {
            [self returnToInitialImageView];
        } else {
            if ([_delegate respondsToSelector:@selector(enterDetailedImageViewMode)]) {
                [_delegate enterDetailedImageViewMode];
            }
        }
        
        result = YES;
    }
    return result;
}

- (void)resetScaleWithPinchGesture:(UIPinchGestureRecognizer *)sender
{
    CGFloat scale = 1.0 - (_lastScale - sender.scale);
    [self.statusImageView setTransform:CGAffineTransformScale(self.statusImageView.transform, scale, scale)];
    self.statusImageView.currentScale += sender.scale - _lastScale;
    _lastScale = sender.scale;
}

- (void)resetPositionWithPinchGesture:(UIPinchGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:[UIApplication sharedApplication].rootViewController.view];
    
    if (point.x == 0.0 && point.y == 0.0) {
        return;
    }
    
    CGFloat deltaX = point.x - _lastPoint.x;
    CGFloat deltaY = point.y - _lastPoint.y;
        
    CGPoint _lastCenter = self.statusImageView.center;
    _lastCenter.x += deltaX;
    _lastCenter.y += deltaY;
    
    self.statusImageView.center = _lastCenter;
    _lastPoint = [sender locationInView:[UIApplication sharedApplication].rootViewController.view];
}

#pragma mark Rotation
- (void)handleRotationGesture:(UIRotationGestureRecognizer *)sender
{
    if (self.statusImageView.imageViewMode == CastViewImageViewModeDetailedZooming || self.statusImageView.imageViewMode == CastViewImageViewModeDetailedNormal) {
        return;
    }
    
    if ([sender state] == UIGestureRecognizerStateBegan) {
        if (self.statusImageView.imageViewMode == CastViewImageViewModeNormal) {
            [self playClipLooseAnimation];
            [self willOpenDetailImageView];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        sender.view.transform = CGAffineTransformRotate(sender.view.transform, sender.rotation);
        sender.rotation = 0;
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (self.statusImageView.actionButton.hidden) {
        if (self.statusImageView.imageViewMode == CastViewImageViewModeNormal) {
            [self willOpenDetailImageViewDirectly];
        } else if (self.statusImageView.imageViewMode != CastViewImageViewModePinchingOut){
            if ([_delegate respondsToSelector:@selector(imageViewTapped)]) {
                [_delegate imageViewTapped];
            }
        }
    } else {
        [self.statusImageView didClickActionButton];
    }
    
    
}

- (void)returnToInitialImageView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.statusImageView playReturnAnimation];
        self.statusImageView.gifIcon.alpha = 1.0;
        self.statusImageView.actionButton.alpha = 1.0;
        [_delegate willReturnImageView];
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:@selector(didReturnImageView)]) {
            [_delegate didReturnImageView];
        }
        [self.statusImageView returnToInitialPosition];
        [self.cardBackground insertSubview:self.statusImageView belowSubview:self.clipImageView];
        [self playClipTightenAnimation];
        self.statusImageView.imageViewMode = CastViewImageViewModeNormal;
        self.statusImageView.userInteractionEnabled = YES;
        _pinchGestureRecognizer.enabled = YES;
        _rotationGestureRecognizer.enabled = YES;
    }];
}

- (void)resetFailedImageView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.statusImageView.transform = CGAffineTransformIdentity;
        [self.statusImageView playReturnAnimation];
        [self.statusImageView returnToInitialPosition];
        self.statusImageView.gifIcon.alpha = 1.0;
        self.statusImageView.actionButton.alpha = 1.0;
    }];
    [self playClipTightenAnimation];
    self.statusImageView.imageViewMode = CastViewImageViewModeNormal;
    self.statusImageView.userInteractionEnabled = YES;
    _pinchGestureRecognizer.enabled = NO;
    _rotationGestureRecognizer.enabled = NO;
    _pinchGestureRecognizer.enabled = YES;
    _rotationGestureRecognizer.enabled = YES;
}

- (void)recoverFromPause
{
    if (self.statusImageView.imageViewMode == CastViewImageViewModePinchingOut) {
        [self returnToInitialImageView];
    }
}

- (void)willOpenDetailImageViewDirectly
{
    self.statusImageView.imageViewMode = CastViewImageViewModeDetailedNormal;
    [self sendShowDetailImageViewNotification];
    
}

- (void)willOpenDetailImageView
{
    self.statusImageView.imageViewMode = CastViewImageViewModePinchingOut;
    [self sendShowDetailImageViewNotification];
}

- (void)sendShowDetailImageViewNotification
{
    self.statusImageView.gifIcon.alpha = 0.0;
    self.statusImageView.actionButton.alpha = 0.0;
    [self playClipLooseAnimation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowDetailImageView object:[NSDictionary dictionaryWithObjectsAndKeys:self, kNotificationObjectKeyStatus,self.statusImageView, kNotificationObjectKeyImageView, nil]];
}

#pragma mark Adjust Clip Behavior

- (void)playClipLooseAnimation
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:0.7];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.duration = 0.3;
    
    [self.clipImageView.layer removeAllAnimations];
    [self.clipImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
    
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:1];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0];
    fadeOutAnimation.duration = 0.3;
    fadeOutAnimation.removedOnCompletion = NO;
    
    [self.clipImageView.layer addAnimation:fadeOutAnimation forKey:@"opacity"];
    self.clipImageView.layer.opacity = 0;
}

- (void)playClipTightenAnimation
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.7];
    rotationAnimation.toValue = [NSNumber numberWithFloat:0.0];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.duration = 0.3;
    
    [self.clipImageView.layer removeAllAnimations];
    [self.clipImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
    
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:0];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:1];
    fadeOutAnimation.duration = 0.3;
    fadeOutAnimation.removedOnCompletion = NO;
    
    [self.clipImageView.layer addAnimation:fadeOutAnimation forKey:@"opacity"];
    self.clipImageView.layer.opacity = 1;
}

#pragma mark - Action popover

- (BOOL)isCardDeletable {
    return [self.status.author isEqualToUser:self.currentUser];
}

- (BOOL)isCardFavorited {
    return self.status.favorited.boolValue;
}

- (ActionPopoverViewController *)actionPopoverViewController {
    if(!_actionPopoverViewController) {
        _actionPopoverViewController = [ActionPopoverViewController getActionPopoverViewControllerWithFavoriteButtonOn:self.isCardFavorited showDeleteButton:self.isCardDeletable];
        _actionPopoverViewController.delegate = self;
    }
    return _actionPopoverViewController;
}

- (void)adjustScrollView:(UIScrollView *)scrollView cropBottomY:(CGFloat)cropPosBottomY cellPosY:(CGFloat)cellPosY {
    CGFloat scrollViewHeight = scrollView.frame.size.height;
    CGFloat scrollViewContentHeight = scrollView.contentSize.height;
    CGFloat scrollViewContentOffsetY = scrollView.contentOffset.y;
    
    CGFloat scrollUp = 50 + cellPosY + cropPosBottomY + self.actionPopoverViewController.foldViewHeight - scrollViewContentOffsetY - scrollViewHeight;
    
    if(scrollUp > 0 && scrollViewContentOffsetY + scrollUp + scrollViewHeight < scrollViewContentHeight) {
        [scrollView setContentOffset:CGPointMake(0, scrollViewContentOffsetY + scrollUp) animated:YES];
    }
}

- (void)showActionPopoverAnimated:(BOOL)animated {
    
    CGFloat cropPosTopY = self.repostButton.frame.origin.y;
    CGFloat cropPosBottomY = self.repostButton.frame.origin.y + self.repostButton.frame.size.height;
    
    UIView *superView = self.view.superview;
    WaterflowView *superSuperView = (WaterflowView *)self.view.superview.superview;
    
    [superView removeFromSuperview];
    if([superSuperView respondsToSelector:@selector(addCellToWaterflowView:)])
        [superSuperView addCellToWaterflowView:superView];
    else
        [superSuperView addSubview:superView];
    
    CGRect cardFrame = self.view.frame;
    
    UIEdgeInsets cardInsets = CARD_CROP_INSETS;
    CGRect insetFrame = CGRectMake(cardFrame.origin.x + cardInsets.left, cardFrame.origin.y + cardInsets.top, cardFrame.size.width - cardInsets.left - cardInsets.right, cropPosTopY - cardInsets.top - cardInsets.bottom);
    
    UIView *cropCardView = [[UIView alloc] initWithFrame:insetFrame];
    cropCardView.backgroundColor = [UIColor clearColor];
    cropCardView.clipsToBounds = YES;
    
    [self.view resetOrigin:CGPointMake(-cardInsets.left, -cardInsets.top)];
    
    [self.view removeFromSuperview];
    [cropCardView addSubview:self.view];
    [superView addSubview:cropCardView];
    
    [[UIApplication sharedApplication].rootViewController.view addSubview:self.actionPopoverViewController.view];
    
    cardFrame.origin.y += cropPosTopY;
    UIView *nonCropCardView = [[UIView alloc] initWithFrame:cardFrame];
    nonCropCardView.backgroundColor = [UIColor clearColor];
    [nonCropCardView addSubview:self.actionPopoverViewController.contentView];
    [self.actionPopoverViewController.contentView resetOrigin:CGPointMake(0, 0)];
    [superView addSubview:nonCropCardView];
    
    [self.actionPopoverViewController setCropView:self.view cropPosTopY:cropPosTopY cropPosBottomY:cropPosBottomY];
    
    if(animated)
        [self.actionPopoverViewController foldAnimation];
    
    // 设置tag以被ActionPopoverGestureRecognizeView识别。
    self.view.tag = ACTION_POPOVER_CONTAINER_VIEW;
    superView.tag = ACTION_POPOVER_CONTAINER_CONTAINER_VIEW;
    
    UIScrollView *scrollView = (UIScrollView *)superSuperView;
    if([scrollView isKindOfClass:[UIScrollView class]]) {
        scrollView.scrollEnabled = NO;
        [self adjustScrollView:scrollView cropBottomY:cropPosBottomY cellPosY:superView.frame.origin.y];
    } else {
        NSLog(@"not scrollview");
    }
}

- (void)handleActionPopoverPinchGesture:(UIPinchGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan)
        [self showActionPopoverAnimated:YES];
}

#pragma mark - ActionPopoverViewController delegate

- (void)actionPopoverViewDidDismiss {
    UIView *cropCardView = self.view.superview;
    UIView *superView = self.view.superview.superview;
    [cropCardView removeFromSuperview];
    
    UIEdgeInsets cardInsets = CARD_CROP_INSETS;
    
    [self.view removeFromSuperview];
    [self.view resetOrigin:CGPointMake(cropCardView.frame.origin.x - cardInsets.left, cropCardView.frame.origin.y - cardInsets.top)];
    [superView addSubview:self.view];
    
    UIView *nonCropCardView = self.actionPopoverViewController.contentView.superview;
    [nonCropCardView removeFromSuperview];
    [self.actionPopoverViewController.view removeFromSuperview];
    self.actionPopoverViewController = nil;
    
    self.view.tag = 0;
    superView.tag = 0;
    
    UIScrollView *scrollView = (UIScrollView *)self.view.superview.superview;
    if([scrollView isKindOfClass:[UIScrollView class]]) {
        scrollView.scrollEnabled = YES;
    }
}

- (void)actionPopoverDidClickButtonWithIdentifier:(ActionPopoverButtonIdentifier)identifier {
    BOOL dismissPopover = YES;
    if(identifier == ActionPopoverButtonIdentifierForward) {
        [self repostStatus];
    } else if(identifier == ActionPopoverButtonIdentifierShowForward) {
        [self sendShowRepostListNotification];
    } else if(identifier == ActionPopoverButtonIdentifierCopy) {
        [self copyStatus];
        dismissPopover = NO;
    } else if(identifier == ActionPopoverButtonIdentifierDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除微博"
                                                        message:@"删除后将无法还原该微博。"
                                                       delegate:self
                                              cancelButtonTitle:@"删除"
                                              otherButtonTitles:@"取消", nil];
        self.deleteStatusAlertView = alert;
        [alert show];
    } else if(identifier == ActionPopoverButtonIdentifierFavorite) {
        //TODO:
    }
    
    if(dismissPopover) {
        [self.actionPopoverViewController foldAnimation];
    }
}

#pragma mark - UIAlertView delegate 

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == self.deleteStatusAlertView) {
        self.deleteStatusAlertView = nil;
        if(buttonIndex == 0) {
            [self deleteStatus];
        }
    }
}

@end
