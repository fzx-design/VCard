//
//  PostRepostViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-6-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostRepostViewController.h"

@interface PostRepostViewController ()

@property (nonatomic, strong) NSString *weiboOwnerName;
@property (nonatomic, strong) NSString *weiboID;

@end

@implementation PostRepostViewController

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

#pragma mark - IBActions

- (IBAction)didClickPostButton:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
}

@end
