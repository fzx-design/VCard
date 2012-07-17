//
//  InnerBrowserViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InnerBrowserViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel                    *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton                   *returnButton;
@property (weak, nonatomic) IBOutlet UIButton                   *backButton;
@property (weak, nonatomic) IBOutlet UIButton                   *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton                   *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton                   *moreActionButton;
@property (weak, nonatomic) IBOutlet UIWebView                  *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *loadingIndicator;
@property (nonatomic, strong) NSURL                             *targetURL;

+ (void)loadLinkWithURL:(NSURL *)url;
+ (void)loadLongLinkWithURL:(NSURL *)url;
- (IBAction)didClickReturnButton:(UIButton *)sender;
- (IBAction)didClickMoreActionButton:(UIButton *)sender;
- (IBAction)didClickReloadButton:(UIButton *)sender;

@end
