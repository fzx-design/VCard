//
//  MessageConversationViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "DMConversationTableViewController.h"

@interface MessageConversationViewController : StackViewPageController <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton       *clearHistoryButton;
@property (nonatomic, weak) IBOutlet UIButton       *viewProfileButton;
@property (nonatomic, weak) IBOutlet UILabel        *titleLabel;
@property (nonatomic, strong) NSString              *titleText;
@property (nonatomic, weak) Conversation            *conversation;
@property (nonatomic, strong) DMConversationTableViewController *conversationTableViewController;

@property (nonatomic, weak) IBOutlet UIView         *footerView;
@property (nonatomic, weak) IBOutlet UIImageView    *footerBackgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView    *textViewBackgroundImageView;
@property (nonatomic, strong) IBOutlet UITextView     *textView;
@property (nonatomic, weak) IBOutlet UIButton       *emoticonButton;
@property (nonatomic, weak) IBOutlet UIButton       *sendButton;


- (IBAction)didClickEmoticonButton:(UIButton *)sender;
- (IBAction)didClickSendButton:(UIButton *)sender;

- (IBAction)didClickViewProfileButton:(UIButton *)sender;
- (IBAction)didClickClearHistoryButton:(UIButton *)sender;

@end
