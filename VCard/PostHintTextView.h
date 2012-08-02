//
//  PostHintTextView.h
//  VCard
//
//  Created by 王 紫川 on 12-8-2.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonsViewController.h"
#import "PostHintView.h"

@protocol PostHintTextViewDelegate;

@interface PostHintTextView : UITextView <EmoticonsViewControllerDelegate, PostHintViewDelegate>

@property (nonatomic, weak) IBOutlet id<PostHintTextViewDelegate> hintDelegate;
@property (nonatomic, assign) NSRange currentHintStringRange;
@property (nonatomic, readonly) NSString *currentHintString;
@property (nonatomic, readonly) BOOL isAtHintStringValid;
@property (nonatomic, readonly) BOOL isTopicHintStringValid;

- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text currentHintView:(id)hintView;
- (void)textViewDidChangeWithCurrentHintView:(id)hintView;
- (void)textViewDidChangeSelectionWithCurrentHintView:(id)hintView;

- (void)initAtHintView:(BOOL)present;
- (void)initTopicHintView:(BOOL)present;

@end

@protocol PostHintTextViewDelegate <NSObject>

- (void)postHintTextViewCallDismissHintView;

@end
