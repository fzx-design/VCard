//
//  PostCommentViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-6-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostCommentViewController.h"
#import "WBClient.h"

@interface PostCommentViewController ()

@property (nonatomic, strong) NSString *weiboOwnerName;
@property (nonatomic, strong) NSString *weiboID;

@end

@implementation PostCommentViewController

@synthesize weiboOwnerName = _weiboOwnerName;
@synthesize weiboID = _weiboID;

- (id)initWithWeiboID:(NSString *)weiboID weiboOwnerName:(NSString *)ownerName {
    self = [super init];
    if(self) {
        self.weiboID = weiboID;
        self.weiboOwnerName = ownerName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.functionLeftCheckmarkView.hidden = NO;
    self.functionLeftNavView.hidden = YES;
    self.motionsView.hidden = YES;
    self.topBarLabel.text = self.weiboOwnerName;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)didClickPostButton:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        ;
    }];
    [client sendCommentWithText:self.textView.text originWeiboID:nil commentOrigin:NO];
}

@end
