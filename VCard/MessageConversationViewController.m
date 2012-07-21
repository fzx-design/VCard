//
//  MessageConversationViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MessageConversationViewController.h"

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
    [self setUpButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)setUpButton
{
    [ThemeResourceProvider configButtonPaperLight:_clearHistoryButton];
    [ThemeResourceProvider configButtonPaperDark:_viewProfileButton];
}

@end
