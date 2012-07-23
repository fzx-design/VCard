//
//  ActionPopoverViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "ActionPopoverViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Resize.h"
#import "UIApplication+Addition.h"
#import "MPAnimation.h"

#define CARD_WIDTH  362.
#define CARD_CENTER_BAR_WIDTH  360.
#define FUNCTION_BUTTON_CENTER_Y    49.
#define FUNCTION_LABEL_CENTER_Y     78.

#define CONTENT_SHADOW_VIEW_BOTTOM_OFFSET_Y 69.

#define FOLD_SHADOW_OPACITY 1.4
#define DEFAULT_ANIMATION_DURATION 0.3

#define SKEW_DEPTH 10

static inline double radians (double degrees) {return degrees * M_PI / 180;}
static inline double degrees (double radians) {return radians * 180 / M_PI;}

@interface ActionPopoverViewController () {
    NSMutableArray *_buttonTitleArray;
    NSMutableArray *_buttonIconFileNameArray;
    NSMutableArray *_buttonIndexArray;
}

@property (nonatomic, assign) CGFloat pinchStartGap;
@property (nonatomic, assign, getter = isFolded) BOOL folded;
@property (nonatomic, assign, getter = isFolding) BOOL folding;
@property (assign, nonatomic) CGFloat lastProgress;

@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) CALayer *perspectiveLayer;
@property (strong, nonatomic) CALayer *topSleeve;
@property (strong, nonatomic) CALayer *bottomSleeve;
@property (strong, nonatomic) CAGradientLayer *upperFoldShadow;
@property (strong, nonatomic) CAGradientLayer *lowerFoldShadow;
@property (strong, nonatomic) CALayer *firstJointLayer;
@property (strong, nonatomic) CALayer *secondJointLayer;
@property (assign, nonatomic) CGPoint animationCenter;
@property (assign, nonatomic) CGFloat shadowViewInitPosY;
@property (assign, nonatomic) CGFloat foldShadowViewInitPosY;
@property (strong, nonatomic) UIImageView *foldShadowView;

@end

@implementation ActionPopoverViewController

@synthesize contentView = _contentView;
@synthesize topBar = _topBar;
@synthesize centerBar = _centerBar;
@synthesize bottomBar = _bottomBar;
@synthesize shadowView = _shadowView;

@synthesize pinchStartGap = _pinchStartGap;
@synthesize folded = _folded;
@synthesize folding = _folding;
@synthesize lastProgress = _lastProgress;

@synthesize animationView = _animationView;
@synthesize perspectiveLayer = _perspectiveLayer;
@synthesize topSleeve = _topSleeve;
@synthesize bottomSleeve = _bottomSleeve;
@synthesize upperFoldShadow = _upperFoldShadow;
@synthesize lowerFoldShadow = _lowerFoldShadow;
@synthesize firstJointLayer = _firstJointLayer;
@synthesize secondJointLayer = _secondJointLayer;
@synthesize animationCenter = _animationCenter;
@synthesize foldShadowView = _foldShadowView;
@synthesize shadowViewInitPosY = _shadowViewInitPosY;
@synthesize foldShadowViewInitPosY = _foldShadowViewInitPosY;

+ (ActionPopoverViewController *)getActionPopoverViewControllerWithFavoriteButtonOn:(BOOL)favoriteOn
                                                                   showDeleteButton:(BOOL)showDelete {
    NSNumber *favorite = [NSNumber numberWithBool:favoriteOn];
    NSNumber *delete = [NSNumber numberWithBool:showDelete];
    
    return [[ActionPopoverViewController alloc] initWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:favorite, kActionPopoverOptionFavoriteButtonOn,
                                                                 delete, kActionPopoverOptionShowDeleteButton, nil]];
}

- (id)initWithOptions:(NSDictionary *)options {
    self = [super init];
    if (self) {
        // Custom initialization
        _buttonTitleArray = [NSMutableArray arrayWithObjects:@"转发", @"收藏", @"查看转发", @"复制", @"删除", nil];
        _buttonIconFileNameArray = [NSMutableArray arrayWithObjects:@"button_ap_repost", @"button_ap_fav", @"button_ap_repost_list", @"button_ap_copy", @"button_ap_delete", nil];
        
        NSNumber *favoriteButtonOn = [options objectForKey:kActionPopoverOptionFavoriteButtonOn];
        NSNumber *showDeleteButton = [options objectForKey:kActionPopoverOptionShowDeleteButton];
        
        if(favoriteButtonOn && favoriteButtonOn.boolValue == YES) {
            [_buttonTitleArray replaceObjectAtIndex:ActionPopoverButtonIdentifierFavorite withObject:@"取消收藏"];
        }
        
        _buttonIndexArray = [NSMutableArray array];
        for(NSUInteger i = 0; i < _buttonTitleArray.count; i++) {
            if(i == ActionPopoverButtonIdentifierDelete) {
                if(showDeleteButton && showDeleteButton.boolValue == NO)
                    continue;
            }
            [_buttonIndexArray addObject:[NSNumber numberWithUnsignedInteger:i]];
        }
        
        self.folded = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    
    [self.view resetSize:[UIApplication sharedApplication].screenSize];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGesture.delegate = self;
	[self.view addGestureRecognizer:tapGesture];
	
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	pinchGesture.delegate = self;
	[self.view addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

- (void)viewDidUnload
{
    self.contentView = nil;
    self.topBar = nil;
    self.centerBar = nil;
    self.bottomBar = nil;
    self.shadowView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UI methods

- (void)configureUI {
    
    CGFloat offset = (CARD_WIDTH - CARD_CENTER_BAR_WIDTH) / 2;
    CGFloat segmentWidth = CARD_CENTER_BAR_WIDTH / _buttonIndexArray.count;
    NSUInteger counter = 0;
    
    for(NSNumber *buttonIndexNumber in _buttonIndexArray) {
        NSUInteger buttonIndex = buttonIndexNumber.unsignedIntegerValue;
        
        NSString *iconFileName = [_buttonIconFileNameArray objectAtIndex:buttonIndex];
        NSString *title = [_buttonTitleArray objectAtIndex:buttonIndex];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, segmentWidth, 20)];
        
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:12];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f];
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        
        [button setImage:[UIImage imageNamed:iconFileName] forState:UIControlStateNormal];
        titleLabel.text = title;
        
        CGFloat centerX = offset + segmentWidth * (0.5f + counter);
        
        button.center = CGPointMake(centerX, FUNCTION_BUTTON_CENTER_Y);
        titleLabel.center = CGPointMake(centerX, FUNCTION_LABEL_CENTER_Y);
        
        button.showsTouchWhenHighlighted = YES;
        
        button.tag = buttonIndex;
        [button addTarget:self action:@selector(didClickFunctionButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [button resetOrigin:CGPointMake(floorf(button.frame.origin.x), floorf(button.frame.origin.y))];
        [titleLabel resetOrigin:CGPointMake(floorf(titleLabel.frame.origin.x), floorf(titleLabel.frame.origin.y))];
        
        NSLog(@"center x:%f", centerX);
        
        counter++;
        
        [self.centerBar addSubview:button];
        [self.centerBar addSubview:titleLabel];
    }
    
    self.centerBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"card_bg_body"]];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.011];
    
    [self.view resetOrigin:CGPointMake(0, 20)];
}

#pragma mark - Actions 

- (void)didClickFunctionButton:(UIButton *)sender {
    [self.delegate actionPopoverDidClickButtonWithIdentifier:sender.tag];
}

#pragma mark - Properties

- (CGFloat)foldViewHeight {
    return self.centerBar.frame.size.height;
}

#pragma mark - Animation methods

- (void)startFold {
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
	self.folding = YES;
	[self buildLayers];
	[self doFold:self.isFolded ? 1 : 0];
    
	[CATransaction commit];
}

- (void)doFold:(CGFloat)difference {
	CGFloat progress = fabsf(difference) / self.foldViewHeight;
	if (self.isFolded)
		progress = 1 - progress;
	
	if (progress < 0)
		progress = 0;
	else if (progress > 1)
		progress = 1;
	
	if (progress == self.lastProgress)
		return;
	self.lastProgress = progress;
	
	double angle = radians(90 * progress);
	double cosine = cos(angle);
	double foldHeight = cosine * self.foldViewHeight;
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	self.firstJointLayer.transform = CATransform3DMakeRotation(-1 * angle, 1, 0, 0);
	self.secondJointLayer.transform = CATransform3DMakeRotation(2 * angle, 1, 0, 0);
	self.topSleeve.transform = CATransform3DMakeRotation(1 * angle, 1, 0, 0);
	self.bottomSleeve.transform = CATransform3DMakeRotation(-1 * angle, 1, 0, 0);
	
	self.upperFoldShadow.opacity = FOLD_SHADOW_OPACITY * progress;
	self.lowerFoldShadow.opacity = FOLD_SHADOW_OPACITY * progress;
	
	self.perspectiveLayer.bounds = (CGRect){CGPointMake(0, (self.foldViewHeight - foldHeight) / 2), CGSizeMake(self.perspectiveLayer.bounds.size.width, foldHeight)};
    
	[CATransaction commit];
    
    [self.foldShadowView resetOriginY:self.foldShadowViewInitPosY - (self.foldViewHeight - foldHeight)];
    self.foldShadowView.alpha = 1 - progress;
}

- (void)buildLayers {
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    	
	CGRect bounds = self.centerBar.bounds;
	CGFloat scale = [[UIScreen mainScreen] scale];
	
	// we inset the folding panels 1 point on each side with a transparent margin to antialiase the edges
	UIEdgeInsets foldInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    UIEdgeInsets slideInsets = UIEdgeInsetsMake(0, 2, 0, 2);
	
	CGRect upperRect = bounds;
		upperRect.size.height = bounds.size.height / 2;
	CGRect lowerRect = upperRect;
		lowerRect.origin.y += upperRect.size.height;
    
	// Create 4 images to represent 2 halves of the 2 views
	[self.centerBar setHidden:NO];
	UIImage *foldUpper = [MPAnimation renderImageFromView:self.centerBar withRect:upperRect transparentInsets:foldInsets];
	UIImage *foldLower = [MPAnimation renderImageFromView:self.centerBar withRect:lowerRect transparentInsets:foldInsets];
	UIImage *slideUpper = [MPAnimation renderImageFromView:self.topBar withRect:self.topBar.bounds transparentInsets:slideInsets];
	UIImage *slideLower = [MPAnimation renderImageFromView:self.bottomBar withRect:self.bottomBar.bounds transparentInsets:slideInsets];
	
	UIView *actingSource = self.contentView;
	UIView *containerView = [actingSource superview];
	[actingSource setHidden:YES];
    
	CATransform3D transform = CATransform3DIdentity;	
	CALayer *upperFold;
	CALayer *lowerFold;
	
	CGFloat width = bounds.size.width;
	CGFloat height = bounds.size.height / 2;
	CGFloat upperHeight = roundf(height * scale) / scale; // round heights to integer for odd height
	CGFloat lowerHeight = (height * 2) - upperHeight;

    CGRect shadowFrame = [containerView convertRect:self.shadowView.frame fromView:actingSource];
    self.foldShadowViewInitPosY = shadowFrame.origin.y;
    self.foldShadowView = [[UIImageView alloc] initWithImage:self.shadowView.image];
    self.foldShadowView.backgroundColor = [UIColor clearColor];
    self.foldShadowView.frame = shadowFrame;
    [containerView addSubview:self.foldShadowView];
    
	// view to hold all our sublayers
	CGRect mainRect = [containerView convertRect:self.centerBar.frame fromView:actingSource];
	self.animationView = [[UIView alloc] initWithFrame:mainRect];
	[containerView addSubview:self.animationView];
    self.animationCenter = self.animationView.center;
    self.animationView.layer.contentsScale = scale;
	
	// layer that covers the 2 folding panels in the middle
	self.perspectiveLayer = [CALayer layer];
	self.perspectiveLayer.frame = CGRectMake(0, 0, width, height * 2);
	[self.animationView.layer addSublayer:self.perspectiveLayer];
    self.perspectiveLayer.contentsScale = scale;
	
	// layer that encapsulates the join between the top sleeve (remains flat) and upper folding panel
	self.firstJointLayer = [CATransformLayer layer];
	self.firstJointLayer.frame = self.animationView.bounds;
	[self.perspectiveLayer addSublayer:self.firstJointLayer];
    self.firstJointLayer.contentsScale = scale;
	
	// This remains flat, and is the upper half of the destination view when moving forwards
	// It slides down to meet the bottom sleeve in the center
	self.topSleeve = [CALayer layer];
	self.topSleeve.frame = (CGRect){CGPointZero, slideUpper.size};
	self.topSleeve.anchorPoint = CGPointMake(0.5, 1);
	self.topSleeve.position = CGPointMake(width / 2, 0);
	[self.topSleeve setContents:(id)[slideUpper CGImage]];
	[self.firstJointLayer addSublayer:self.topSleeve];
    self.topSleeve.contentsScale = scale;
	
	// This piece folds away from user along top edge, and is the upper half of the source view when moving forwards
	upperFold = [CALayer layer];
	upperFold.frame = (CGRect){CGPointZero, foldUpper.size};
	upperFold.anchorPoint = CGPointMake(0.5, 0);
	upperFold.position = CGPointMake(width / 2, 0);
	upperFold.contents = (id)[foldUpper CGImage];
	[self.firstJointLayer addSublayer:upperFold];
    upperFold.contentsScale = scale;
	
	// layer that encapsultates the join between the upper and lower folding panels (the V in the fold)
	self.secondJointLayer = [CATransformLayer layer];
	self.secondJointLayer.frame = self.animationView.bounds;
	self.secondJointLayer.frame = CGRectMake(0, 0, width, height * 2);
	self.secondJointLayer.anchorPoint = CGPointMake(0.5, 0);
	self.secondJointLayer.position = CGPointMake(width / 2, upperHeight);
	[self.firstJointLayer addSublayer:self.secondJointLayer];
    self.secondJointLayer.contentsScale = scale;
	
	// This piece folds away from user along bottom edge, and is the lower half of the source view when moving forwards
	lowerFold = [CALayer layer];
	lowerFold.frame = (CGRect){CGPointZero, foldLower.size};
	lowerFold.anchorPoint = CGPointMake(0.5, 0);
	lowerFold.position = CGPointMake(width / 2, 0);
	lowerFold.contents = (id)[foldLower CGImage];
	[self.secondJointLayer addSublayer:lowerFold];
    lowerFold.contentsScale = scale;
	
	// This remains flat, and is the lower half of the destination view when moving forwards
	// It slides up to meet the top sleeve in the center
	self.bottomSleeve = [CALayer layer];
	self.bottomSleeve.frame = (CGRect){CGPointZero, slideLower.size};
	self.bottomSleeve.anchorPoint = CGPointMake(0.5, 0);
	self.bottomSleeve.position = CGPointMake(width / 2, lowerHeight);
	[self.bottomSleeve setContents:(id)[slideLower CGImage]];
	[self.secondJointLayer addSublayer:self.bottomSleeve];
    self.bottomSleeve.contentsScale = scale;
	
	self.firstJointLayer.anchorPoint = CGPointMake(0.5, 0);
	self.firstJointLayer.position = CGPointMake(width / 2, 0);
	
    
	// Shadow layers to add shadowing to the 2 folding panels
	self.upperFoldShadow = [CAGradientLayer layer];
	[upperFold addSublayer:self.upperFoldShadow];
	self.upperFoldShadow.frame = CGRectInset(upperFold.bounds, 5, 0);
	//self.upperFoldShadow.backgroundColor = [UIColor blackColor].CGColor;
	self.upperFoldShadow.colors = [NSArray arrayWithObjects:(id)[UIColor darkGrayColor].CGColor, (id)[[UIColor darkGrayColor] colorWithAlphaComponent:0.5].CGColor, nil];
	self.upperFoldShadow.startPoint = CGPointMake(0.5, 0);
	self.upperFoldShadow.endPoint = CGPointMake(0.5, 1);
	self.upperFoldShadow.opacity = 0;
    self.upperFoldShadow.contentsScale = scale;
	
	self.lowerFoldShadow = [CAGradientLayer layer];
	[lowerFold addSublayer:self.lowerFoldShadow];
	self.lowerFoldShadow.frame = CGRectInset(lowerFold.bounds, 5, 0);
	self.lowerFoldShadow.colors = [NSArray arrayWithObjects:(id)[UIColor darkGrayColor].CGColor, (id)[[UIColor darkGrayColor] colorWithAlphaComponent:0.7].CGColor, nil];
	self.lowerFoldShadow.startPoint = CGPointMake(0.5, 0);
	self.lowerFoldShadow.endPoint = CGPointMake(0.5, 1);
	self.lowerFoldShadow.opacity = 0;
    self.lowerFoldShadow.contentsScale = scale;
	
	CGRect topBounds = CGRectInset(self.topSleeve.bounds, slideInsets.left, slideInsets.top);
	[self.topSleeve setShadowPath:[[UIBezierPath bezierPathWithRect:topBounds] CGPath]];
	
	CGRect upperFoldBounds = CGRectInset([upperFold bounds], foldInsets.left, foldInsets.top);
	[upperFold setShadowPath:[[UIBezierPath bezierPathWithRect:upperFoldBounds] CGPath]];
	
	CGRect lowerFoldBounds = CGRectInset([lowerFold bounds], foldInsets.left, foldInsets.top);
	[lowerFold setShadowPath:[[UIBezierPath bezierPathWithRect:lowerFoldBounds] CGPath]];
	
    CGRect bottomBounds = CGRectInset(self.bottomSleeve.bounds, slideInsets.left, slideInsets.top);
	[self.bottomSleeve setShadowPath:[[UIBezierPath bezierPathWithRect:bottomBounds] CGPath]];
	
	// Perspective is best proportional to the height of the pieces being folded away, rather than a fixed value
	// the larger the piece being folded, the more perspective distance (zDistance) is needed.
	// m34 = -1/zDistance
	transform.m34 = -1 / ((self.foldViewHeight / 2) *  SKEW_DEPTH);
	self.perspectiveLayer.sublayerTransform = transform;
	
	[CATransaction commit];
}

- (void)endFold {	
	BOOL finish = NO;
	if (self.isFolded) {
		finish = 1 - cosf(radians(90 * self.lastProgress)) <= 0.5;
	}
	else {
		finish = 1 - cosf(radians(90 * self.lastProgress)) >= 0.5;
	}
	
	if (self.lastProgress > 0 && self.lastProgress < 1)
		[self animateFold:finish];
	else
		[self postFold:finish];
}

- (void)postFold:(BOOL)finish {
	self.folding = NO;
	
	// final animation completed
	if (finish)
		self.folded = !self.isFolded;
	
	// remove the animation view and restore the center bar
	[self.animationView removeFromSuperview];
    [self.foldShadowView removeFromSuperview];
    self.foldShadowView = nil;
	self.animationView = nil;
	self.perspectiveLayer = nil;
	self.topSleeve = nil;
	self.bottomSleeve = nil;
	self.upperFoldShadow = nil;
	self.lowerFoldShadow = nil;
	self.firstJointLayer = nil;
	self.secondJointLayer = nil;
	
	if (self.isFolded) {
		self.topBar.transform = CGAffineTransformMakeTranslation(0, 0);
		self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -self.foldViewHeight);
        self.shadowView.transform = CGAffineTransformMakeTranslation(0, -self.foldViewHeight);
		[self.centerBar setHidden:YES];
	}
	else {
		self.topBar.transform = CGAffineTransformIdentity;
		self.bottomBar.transform = CGAffineTransformIdentity;
        self.shadowView.transform = CGAffineTransformIdentity;

		[self.centerBar setHidden:NO];
	}
	[self.contentView setHidden:NO];
	
    if(self.isFolded)
        [self.delegate actionPopoverViewDidDismiss];
}

- (void)animateFold:(BOOL)finish {
	self.folding = YES;
	
	// Figure out how many frames we want
	CGFloat duration = DEFAULT_ANIMATION_DURATION;
	NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS
    
	// Create a transaction
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault] forKey:kCATransactionAnimationTimingFunction];
	[CATransaction setCompletionBlock:^{
		[self postFold:finish];
	}];
	
	self.animationView.center = self.animationCenter;
    
	BOOL forwards = finish != self.isFolded;
	NSString *rotationKey = @"transform.rotation.x";
	double factor = M_PI / 180;
	CGFloat fromProgress = self.lastProgress;
	if (finish == self.isFolded)
		fromProgress = 1 - fromProgress;
    
	// fold the first (top) joint away from us
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
        
	[animation setFromValue:forwards ? [NSNumber numberWithDouble:-90 * factor * fromProgress] : [NSNumber numberWithDouble:-90 * factor * (1 - fromProgress)]];
	[animation setToValue:forwards ? [NSNumber numberWithDouble:-90 * factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.firstJointLayer addAnimation:animation forKey:nil];
	
	// fold the second joint back towards us at twice the angle (since it's connected to the first fold we're folding away)
	animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards ? [NSNumber numberWithDouble:180 * factor * fromProgress] : [NSNumber numberWithDouble:180 * factor * (1 - fromProgress)]];
	[animation setToValue:forwards ? [NSNumber numberWithDouble:180 * factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.secondJointLayer addAnimation:animation forKey:nil];
	
	// fold the bottom sleeve (3rd joint) away from us, so that net result is it lays flat from user's perspective
	animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards ? [NSNumber numberWithDouble:-90 * factor * fromProgress] : [NSNumber numberWithDouble:-90 * factor * (1 - fromProgress)]];
	[animation setToValue:forwards ? [NSNumber numberWithDouble:-90 * factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.bottomSleeve addAnimation:animation forKey:nil];
	
	// fold top sleeve towards us, so that net result is it lays flat from user's perspective
	animation = [CABasicAnimation animationWithKeyPath:rotationKey];
	[animation setFromValue:forwards ? [NSNumber numberWithDouble:90 * factor * fromProgress] : [NSNumber numberWithDouble:90 * factor * (1 - fromProgress)]];
	[animation setToValue:forwards ? [NSNumber numberWithDouble:90 * factor] : [NSNumber numberWithDouble:0]];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:NO];
	[self.topSleeve addAnimation:animation forKey:nil];
    
	// Build an array of keyframes for perspectiveLayer.bounds.size.height
	NSMutableArray* arrayHeight = [NSMutableArray arrayWithCapacity:frameCount + 1];
	NSMutableArray* arrayShadow = [NSMutableArray arrayWithCapacity:frameCount + 1];
    NSMutableArray* arrayOriginY = [NSMutableArray arrayWithCapacity:frameCount + 1];
	CGFloat progress;
	CGFloat cosine;
	CGFloat cosHeight;
	CGFloat cosShadow;
    CGFloat cosOriginY;
    
	for (int frame = 0; frame <= frameCount; frame++) {
		progress = fromProgress + (((1 - fromProgress) * frame) / frameCount);
		//progress = (((float)frame) / frameCount);
		cosine = forwards ? 1 - progress : progress;
		if ((forwards && frame == frameCount) || (!forwards && frame == 0 && fromProgress == 0))
			cosine = 0;
		cosHeight = ((cosine) * self.foldViewHeight); // range from 2*height to 0 along a cosine curve
		[arrayHeight addObject:[NSNumber numberWithFloat:cosHeight]];
		
		cosShadow = FOLD_SHADOW_OPACITY * (1 - cosine);
		[arrayShadow addObject:[NSNumber numberWithFloat:cosShadow]];
        
        cosOriginY = self.foldViewHeight * (1 - cosine) / 2;
        [arrayOriginY addObject:[NSNumber numberWithFloat:cosOriginY]];
	}
	
	// resize height of the 2 folding panels along a cosine curve.  This is necessary to maintain the 2nd joint in the center
	// Since there's no built-in sine timing curve, we'll use CAKeyframeAnimation to achieve it
    
	CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size.height"];
	[keyAnimation setValues:[NSArray arrayWithArray:arrayHeight]];
	[keyAnimation setFillMode:kCAFillModeForwards];
	[keyAnimation setRemovedOnCompletion:NO];
	[self.perspectiveLayer addAnimation:keyAnimation forKey:nil];
    
    keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.origin.y"];
    [keyAnimation setValues:[NSArray arrayWithArray:arrayOriginY]];
    [keyAnimation setFillMode:kCAFillModeForwards];
    [keyAnimation setRemovedOnCompletion:NO];
    [self.perspectiveLayer addAnimation:keyAnimation forKey:nil];
	
	// Dim the 2 folding panels as they fold away from us
	keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	[keyAnimation setValues:arrayShadow];
	[keyAnimation setFillMode:kCAFillModeForwards];
	[keyAnimation setRemovedOnCompletion:NO];
	[self.upperFoldShadow addAnimation:keyAnimation forKey:nil];
	
	keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	[keyAnimation setValues:arrayShadow];
	[keyAnimation setFillMode:kCAFillModeForwards];
	[keyAnimation setRemovedOnCompletion:NO];
	[self.lowerFoldShadow addAnimation:keyAnimation forKey:nil];
    
	// commit the transaction
	[CATransaction commit];
    
    [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION delay:0 options:UIViewAnimationCurveLinear animations:^{
        self.foldShadowView.alpha = forwards ? 0 : 1;
        [self.foldShadowView resetOriginY:forwards ? self.foldShadowViewInitPosY - self.foldViewHeight : self.foldShadowViewInitPosY];
    } completion:nil];
}

#pragma mark - Gesture recognizer

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
        [self foldAnimation];
}

- (void)handlePan:(UITapGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
        [self foldAnimation];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
	
	CGFloat currentGap = self.pinchStartGap;
	if (state != UIGestureRecognizerStateEnded && gestureRecognizer.numberOfTouches == 2) {
		CGPoint p1 = [gestureRecognizer locationOfTouch:0 inView:self.view];
		CGPoint p2 = [gestureRecognizer locationOfTouch:1 inView:self.view];
		currentGap = fabsf(p1.y - p2.y);
    }
	
    if (state == UIGestureRecognizerStateBegan) {		
		self.pinchStartGap = currentGap;
		[self startFold];
    }
	
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
		[self endFold];
    } else if (state == UIGestureRecognizerStateChanged && gestureRecognizer.numberOfTouches == 2) {
		if (self.isFolded) {
			// pinching out, want + diff
			if (currentGap < self.pinchStartGap)
				currentGap = self.pinchStartGap; // min
			
			if (currentGap > self.pinchStartGap + self.foldViewHeight)
				currentGap = self.pinchStartGap + self.foldViewHeight; // max
		} else {
			// pinching in, want - diff
			if (currentGap < self.pinchStartGap - self.foldViewHeight)
				currentGap = self.pinchStartGap - self.foldViewHeight; // min
			
			if (currentGap > self.pinchStartGap)
				currentGap = self.pinchStartGap; // max
		}
		
		[self doFold:currentGap - self.pinchStartGap];
	}
}

- (void)foldAnimation {
    self.lastProgress = 0;
	[self startFold];
	[self animateFold:YES];
}

#pragma mark - Crop view methods

- (void)configureCropImageView:(UIView *)cropView cropPosTopY:(CGFloat)topY cropPosBottomY:(CGFloat)bottomY {
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(cropView.frame.size, NO, 0);
    else
        UIGraphicsBeginImageContext(cropView.frame.size);
    [cropView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect topRect = CGRectMake(0, topY, cropView.frame.size.width, bottomY - topY);
    CGRect bottomRect = CGRectMake(0, bottomY, cropView.frame.size.width, cropView.frame.size.height - bottomY);
    
    CGRect topCropRect = CGRectMake(0, topY * scale, cropView.frame.size.width * scale, (bottomY - topY) * scale);
    CGRect bottomCropRect = CGRectMake(0, bottomY * scale, cropView.frame.size.width * scale, (cropView.frame.size.height - bottomY) * scale);
    UIImage *topImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, topCropRect)];
    UIImage *bottomImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, bottomCropRect)];
    
    self.topBar.image = topImage;
    self.bottomBar.image = bottomImage;
    
    [self.topBar resetSize:topRect.size];
    [self.bottomBar resetSize:bottomRect.size];
}

- (void)setCropView:(UIView *)view cropPosTopY:(CGFloat)topY cropPosBottomY:(CGFloat)bottomY {
    topY = floorf(topY);
    bottomY = ceilf(bottomY);
    [self configureCropImageView:view cropPosTopY:topY cropPosBottomY:bottomY];
    [self.contentView resetSize:CGSizeMake(view.frame.size.width, view.frame.size.height - topY + self.centerBar.frame.size.height)];
    [self.topBar resetOrigin:CGPointMake(0, 0)];
    [self.centerBar resetOrigin:CGPointMake(0, bottomY - topY)];
    [self.bottomBar resetOrigin:CGPointMake(0, bottomY - topY + self.centerBar.frame.size.height)];
    self.shadowViewInitPosY = self.contentView.frame.size.height + CONTENT_SHADOW_VIEW_BOTTOM_OFFSET_Y - self.shadowView.frame.size.height;
    [self.shadowView resetOriginY:self.shadowViewInitPosY];
}

#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return ![self isFolding];
}

@end