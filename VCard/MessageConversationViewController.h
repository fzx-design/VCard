//
//  MessageConversationViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"

@interface MessageConversationViewController : StackViewPageController

@property (nonatomic, weak) IBOutlet UIButton   *clearHistoryButton;
@property (nonatomic, weak) IBOutlet UIButton   *viewProfileButton;
@property (nonatomic, weak) IBOutlet UILabel    *titleLabel;
@property (nonatomic, strong) NSString          *titleText;

@end
