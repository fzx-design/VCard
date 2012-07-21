//
//  MessageConversationViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MessageConversationViewController.h"
#import "Conversation.h"

@interface MessageConversationViewController ()

@end

@implementation MessageConversationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.backgroundView addSubview:self.conversationTableViewController.view];
    [self.topShadowImageView resetOriginY:[self frameForTableView].origin.y];
    [self.topShadowImageView resetOriginX:0.0];
    [self.view addSubview:self.topShadowImageView];
    self.titleLabel.text = _conversation.targetUser.screenName;
    [ThemeResourceProvider configButtonPaperLight:_clearHistoryButton];
    [ThemeResourceProvider configButtonPaperDark:_viewProfileButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (IBAction)didClickViewProfileButton:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:[NSDictionary dictionaryWithObjectsAndKeys:_conversation.targetUser.screenName, kNotificationObjectKeyUserName, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (IBAction)didClickClearHistoryButton:(UIButton *)sender {
}

#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 50;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (DMConversationTableViewController *)conversationTableViewController
{
    if (!_conversationTableViewController) {
        _conversationTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DMConversationTableViewController"];
        _conversationTableViewController.view.frame = [self frameForTableView];
        _conversationTableViewController.tableView.frame = [self frameForTableView];
        _conversationTableViewController.conversation = _conversation;
    }
    return _conversationTableViewController;
}

@end
