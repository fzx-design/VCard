//
//  MessageConversationViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "DMConversationTableViewController.h"
#import "PostHintTextView.h"
#import "PostRootView.h"

@interface MessageConversationViewController : StackViewPageController <UITextViewDelegate, PostHintTextViewDelegate, PostRootViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton       *viewProfileButton;
@property (nonatomic, weak) IBOutlet UILabel        *titleLabel;
@property (nonatomic, weak) IBOutlet UIView         *footerView;
@property (nonatomic, weak) IBOutlet UIImageView    *footerBackgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView    *textViewBackgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton       *emoticonsButton;
@property (nonatomic, weak) IBOutlet UIButton       *sendButton;
@property (nonatomic, weak) IBOutlet UIImageView    *topCoverImageView;
@property (nonatomic, weak) IBOutlet PostHintTextView *textView;
@property (nonatomic, unsafe_unretained) BOOL       shouldAutomaticallyBecomeFirstResponder;


@property (nonatomic, strong) NSString              *titleText;
@property (nonatomic, weak) Conversation            *conversation;
@property (nonatomic, strong) DMConversationTableViewController *conversationTableViewController;



- (IBAction)didClickEmoticonButton:(UIButton *)sender;
- (IBAction)didClickSendButton:(UIButton *)sender;

- (IBAction)didClickViewProfileButton:(UIButton *)sender;

@end
