//
//  DMConversationTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"
#import "DMConversationTableViewCell.h"

@interface DMConversationTableViewController : RefreshableCoreDataTableViewController <DMConversationTableViewCellDelegate>

@property (nonatomic, weak) Conversation *conversation;

- (void)initialLoadMessageData;
- (void)scrollToBottom:(BOOL)animated;
- (void)receivedNewMessage:(NSDictionary *)dict;
- (void)getUnreadMessage;
- (void)getUnreadMessageThroughTimer;

@end
