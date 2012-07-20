//
//  InnerBrowserViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "InnerBrowserViewController.h"
#import "UIApplication+Addition.h"
#import "UIView+Resize.h"
#import "WBClient.h"

@interface InnerBrowserViewController () {
    BOOL _loading;
    BOOL _firstLoad;
}

@end

@implementation InnerBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (void)loadLinkWithURL:(NSURL *)url
{
    [[InnerBrowserViewController createBrowser] loadLink:url];
}

+ (void)loadLongLinkWithURL:(NSURL *)url
{
    [[InnerBrowserViewController createBrowser] loadLongLink:url];
}

+ (InnerBrowserViewController *)createBrowser
{
    InnerBrowserViewController *vc = [[UIApplication sharedApplication].rootViewController.storyboard instantiateViewControllerWithIdentifier:@"InnerBrowserViewController"];
    
    vc.view.frame = [UIApplication sharedApplication].rootViewController.view.bounds;
    [vc.view resetWidth:[UIApplication screenWidth]];
    [vc.view resetHeight:[UIApplication screenHeight] - 20.0];
    
    [UIApplication presentModalViewController:vc animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:kUserDefaultKeyShouldScrollToTop];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ThemeResourceProvider configButtonDark:_returnButton];
    _webView.delegate = self;
}

- (void)viewDidUnload
{
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setReloadButton:nil];
    [self setMoreActionButton:nil];
    [super viewDidUnload];
}

- (void)viewWillLayoutSubviews
{
    [_webView resetHeight:[UIApplication screenHeight] - 105.0];
}

- (void)loadLink:(NSURL *)link
{
    _firstLoad = YES;
    _targetURL = link;
    _titleLabel.text = link.absoluteString;
    _webView.scrollView.scrollsToTop = NO;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *dict = client.responseJSONObject;
            if ([dict isKindOfClass:[NSDictionary class]]) {
                NSString *url = [dict objectForKey:@"url_long"];
                _targetURL = [NSURL URLWithString:url];
                _titleLabel.text = url;
            }
        }
        
        [_webView loadRequest:[[NSURLRequest alloc] initWithURL:_targetURL]];
    }];
    
    [client getLongURLWithShort:link.absoluteString];
}

- (void)loadLongLink:(NSURL *)link
{
    _firstLoad = YES;
    _targetURL = link;
    _webView.scrollView.scrollsToTop = NO;
    _titleLabel.text = link.absoluteString;
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:_targetURL]];
}

#pragma mark - IBActions
- (IBAction)didClickReturnButton:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kUserDefaultKeyShouldScrollToTop];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UIApplication relayoutRootViewController];
    [UIApplication dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(resetWebview) withObject:nil afterDelay:0.3];
}

- (void)resetWebview
{
    _targetURL = nil;
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (IBAction)didClickMoreActionButton:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self 
                                                    cancelButtonTitle:nil 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"复制链接", @"在 Safari 中打开", nil];
    actionSheet.delegate = self;
    [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
}

- (IBAction)didClickReloadButton:(UIButton *)sender
{
    if (_loading) {
        [_webView stopLoading];
    } else {
        [_webView reload];
    }
    [self resetButtonStatus];
}

- (void)resetButtonStatus
{
    NSString *imageName = _loading ? @"button_stop_pale.png" : @"button_reload_pale.png";
    [_reloadButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    _forwardButton.enabled = _webView.canGoForward;
    _backButton.enabled = _webView.canGoBack;
}

#pragma - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _loading = YES;
    [self resetButtonStatus];
    [_loadingIndicator startAnimating];
    _loadingIndicator.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _loading = NO;
    [self resetButtonStatus];
    [_loadingIndicator stopAnimating];
    _loadingIndicator.hidden = YES;
    _titleLabel.text = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _loading = NO;
    [self resetButtonStatus];
    [_loadingIndicator stopAnimating];
    _loadingIndicator.hidden = YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0) {
        [self copyLink];
    } else if(buttonIndex == 1) {
        [self openInSafari];
    }
}

- (void)copyLink
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    NSURL *url = _webView.canGoBack ? _webView.request.URL : _targetURL;
    [pb setString:url.absoluteString];
}

- (void)openInSafari
{
    NSURL *url = _webView.canGoBack ? _webView.request.URL : _targetURL;
    [[UIApplication sharedApplication] openURL:url];
}

@end
