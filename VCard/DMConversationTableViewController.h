//
//  DMConversationTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"

@interface DMConversationTableViewController : RefreshableCoreDataTableViewController

@property (nonatomic, weak) Conversation *conversation;

- (void)initialLoadMessageData;

@end
