//
//  ActionPopoverViewController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionPopoverGestureRecognizeView.h"

#define kActionPopoverOptionShowDeleteButton    @"ActionPopoverOptionShowDeleteButton"
#define kActionPopoverOptionFavoriteButtonOn    @"ActionPopoverOptionFavoriteButtonOn"

typedef enum {
    ActionPopoverButtonIdentifierForward,
    ActionPopoverButtonIdentifierFavorite,
    ActionPopoverButtonIdentifierShowForward,
    ActionPopoverButtonIdentifierCopy,
    ActionPopoverButtonIdentifierDelete,
} ActionPopoverButtonIdentifier;

@protocol ActionPopoverViewControllerDelegate;

@interface ActionPopoverViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIImageView *topBar;
@property (nonatomic, weak) IBOutlet UIView *centerBar;
@property (nonatomic, weak) IBOutlet UIImageView *bottomBar;
@property (nonatomic, weak) IBOutlet UIImageView *shadowView;
@property (nonatomic, weak) id<ActionPopoverViewControllerDelegate> delegate;

- (void)setCropView:(UIView *)view cropPosTopY:(CGFloat)topY cropPosBottomY:(CGFloat)bottomY;
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer;

+ (ActionPopoverViewController *)getActionPopoverViewControllerWithFavoriteButtonOn:(BOOL)favoriteOn
                                                                   showDeleteButton:(BOOL)showDelete;

- (id)initWithOptions:(NSDictionary *)options;

- (void)foldAnimation;

@end

@protocol ActionPopoverViewControllerDelegate <NSObject>

- (void)actionPopoverViewDidDismiss;
- (void)actionPopoverDidClickButtonWithIdentifier:(ActionPopoverButtonIdentifier)identifier;

@end
