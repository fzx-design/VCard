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

#define CARD_WIDTH  362.
#define CARD_CENTER_BAR_WIDTH  360.
#define FUNCTION_BUTTON_CENTER_Y    48.
#define FUNCTION_LABEL_CENTER_Y     78.

typedef enum {
    ActionPopoverButtonIdentifierForward,
    ActionPopoverButtonIdentifierFavorite,
    ActionPopoverButtonIdentifierShowForward,
    ActionPopoverButtonIdentifierCopy,
    ActionPopoverButtonIdentifierDelete,
} ActionPopoverButtonIdentifier;

@interface ActionPopoverViewController () {
    NSMutableArray *_buttonTitleArray;
    NSMutableArray *_buttonIconFileNameArray;
    NSMutableArray *_buttonIndexArray;
}

@end

@implementation ActionPopoverViewController

@synthesize contentView = _contentView;
@synthesize topBar = _topBar;
@synthesize centerBar = _centerBar;
@synthesize bottomBar = _bottomBar;

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGesture.delegate = self;
	[self.view addGestureRecognizer:tapGesture];
	
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	pinchGesture.delegate = self;
	[self.contentView addGestureRecognizer:pinchGesture];
}

- (void)viewDidUnload
{
    self.contentView = nil;
    self.topBar = nil;
    self.centerBar = nil;
    self.bottomBar = nil;
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
        
        [button resetOrigin:CGPointMake(floorf(button.frame.origin.x), floorf(button.frame.origin.y))];
        [titleLabel resetOrigin:CGPointMake(floorf(titleLabel.frame.origin.x), floorf(titleLabel.frame.origin.y))];
        
        NSLog(@"center x:%f", centerX);
        
        counter++;
        
        [self.centerBar addSubview:button];
        [self.centerBar addSubview:titleLabel];
    }
    
    self.centerBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"card_bg_body"]];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.011];
}

#pragma mark - Properties

- (CGFloat)foldViewHeight {
    return self.centerBar.frame.size.height;
}

#pragma mark - Gesture recognizer

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self.delegate actionPopoverViewDidDismiss];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    //UIGestureRecognizerState state = [gestureRecognizer state];
}

#pragma mark - Crop view methods

- (void)configureCropImageView:(UIView *)cropView cropPosTopY:(CGFloat)topY cropPosBottomY:(CGFloat)bottomY {
    UIGraphicsBeginImageContext(cropView.bounds.size);
    [cropView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect topRect = CGRectMake(0, topY, cropView.frame.size.width, bottomY - topY);
    CGRect bottomRect = CGRectMake(0, bottomY, cropView.frame.size.width, cropView.frame.size.height - bottomY);
    UIImage *topImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, topRect)];
    UIImage *bottomImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, bottomRect)];
    
    self.topBar.image = topImage;
    self.bottomBar.image = bottomImage;
    
    [self.topBar resetSize:topImage.size];
    [self.bottomBar resetSize:bottomImage.size];
}

- (void)setCropView:(UIView *)view cropPosTopY:(CGFloat)topY cropPosBottomY:(CGFloat)bottomY {
    [self configureCropImageView:view cropPosTopY:topY cropPosBottomY:bottomY];
    [self.contentView resetSize:CGSizeMake(view.frame.size.width, view.frame.size.height - topY)];
    [self.topBar resetOrigin:CGPointMake(0, 0)];
    [self.centerBar resetOrigin:CGPointMake(0, bottomY - topY)];
    [self.bottomBar resetOrigin:CGPointMake(0, bottomY - topY + self.centerBar.frame.size.height)];
}

#pragma mark - ActionPopoverGestureRecognizeView delegate

- (void)actionPopoverGestureRecognizeViewDidDetectDismissTouch {
    
}

@end
