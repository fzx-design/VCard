//
//  PostRepostCommentViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-6-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostRepostCommentViewController.h"
#import "WBClient.h"

@interface PostRepostCommentViewController ()

@property (nonatomic, strong) NSString *weiboOwnerName;
@property (nonatomic, strong) NSString *weiboID;
@property (nonatomic, strong) NSString *replyID;

@end

@implementation PostRepostCommentViewController

@synthesize weiboOwnerName = _weiboOwnerName;
@synthesize weiboID = _weiboID;
@synthesize replyID = _replyID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"PostViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithWeiboID:(NSString *)weiboID
              replyID:(NSString *)replyID
       weiboOwnerName:(NSString *)ownerName
          contentText:(NSString *)content {
    self = [super init];
    if(self) {
        self.weiboID = weiboID;
        self.weiboOwnerName = ownerName;
        self.replyID = replyID;
        self.content = content;
    }
    return self;
}

- (void)viewDidLoad
{
    self.functionLeftCheckmarkView.hidden = NO;
    self.functionLeftNavView.hidden = YES;
    self.motionsView.hidden = YES;
    self.textView.text = @"";
    CGRect frame = self.functionRightView.frame;
    frame.origin.x = self.functionLeftCheckmarkView.frame.origin.x + self.functionLeftCheckmarkView.frame.size.width;
    self.functionRightView.frame = frame;
    if(self.type == PostViewControllerTypeRepost) {
        [self.repostCommentButton setTitle:@"同时评论" forState:UIControlStateNormal];
        self.topBarLabel.text = [NSString stringWithFormat:@"转发 %@ 的微博", self.weiboOwnerName];
        if(self.content)
            self.textView.text = [NSString stringWithFormat:@" //@%@:%@", self.weiboOwnerName, self.content];
    }
    else {
        [self.repostCommentButton setTitle:@"同时转发" forState:UIControlStateNormal];
        self.topBarLabel.text = [NSString stringWithFormat:@"回复 %@", self.weiboOwnerName];
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)didClickPostButton:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    [self.delegate postViewController:self willPostMessage:self.textView.text];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowPostIndicator object:nil];
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if(!client.hasError) {
            NSLog(@"post succeeded");
            [self.delegate postViewController:self didPostMessage:self.textView.text];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldHidePostIndicator object:nil];
        } else {
            NSLog(@"post failed");
            [self.delegate postViewController:self didFailPostMessage:self.textView.text];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldHidePostIndicator object:nil];
        }
        sender.userInteractionEnabled = YES;
    }];
    
    if(self.repostCommentCheckmarkButton.selected == NO) {
        if(self.type == PostViewControllerTypeRepost)
            [client sendRepostWithText:self.textView.text weiboID:self.weiboID commentType:RepostWeiboTypeCommentNone];
        else if(self.type == PostViewControllerTypeCommentWeibo)
            [client sendWeiboCommentWithText:self.textView.text weiboID:self.weiboID commentOrigin:NO];
        else if(self.type == PostViewControllerTypeCommentReply)
            [client sendReplyCommentWithText:self.textView.text weiboID:self.weiboID replyID:self.replyID commentOrigin:NO];
    } else {
        if(self.type == PostViewControllerTypeCommentReply) {
            [client sendReplyCommentWithText:self.textView.text weiboID:self.weiboID replyID:self.replyID commentOrigin:NO];
            WBClient *repostClient = [WBClient client];
            [repostClient sendRepostWithText:self.textView.text weiboID:self.weiboID commentType:RepostWeiboTypeCommentNone];
        } else
            [client sendRepostWithText:self.textView.text weiboID:self.weiboID commentType:RepostWeiboTypeCommentCurrent];
    }
}

- (IBAction)didClickRepostCommentCheckmarkButton:(UIButton *)sender {
    BOOL select = !sender.isSelected;
    self.repostCommentButton.selected = select;
    self.repostCommentCheckmarkButton.selected = select;
}

@end
