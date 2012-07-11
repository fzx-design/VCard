//
//  LoginCellViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginCellViewController.h"
#import "WBClient.h"
#import "NSUserDefaults+Addition.h"
#import "NSNotificationCenter+Addition.h"

@interface LoginCellViewController ()

@end

@implementation LoginCellViewController

@synthesize avatarImageView = _avatarImageView;
@synthesize loginButton = _loginButton;
@synthesize gloomImageView = _gloomImageView;
@synthesize avatarBgImageView = _avatarBgImageView;
@synthesize delegate = _delegate;

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.avatarImageView = nil;
    self.loginButton = nil;
    self.gloomImageView = nil;
    self.avatarBgImageView = nil;
}

- (void)loginUsingAccount:(NSString *)account
                 password:(NSString *)password
               completion:(void (^)(BOOL succeeded))compeltion {
    [self.delegate loginCellWillLoginUser];
    
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            User *user = [User insertUser:userDict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
            
            [NSUserDefaults insertUserAccountInfoWithUserID:user.userID account:account password:password];
            
            [NSNotificationCenter postCoreChangeCurrentUserNotificationWithUserID:user.userID];
            
            if(compeltion)
                compeltion(YES);
            
            NSLog(@"login step 3 succeeded");
            [self.delegate loginCellDidLoginUser:user];
        } else {
            if(compeltion)
                compeltion(NO);
            
            NSLog(@"login step 3 failed");
            [self.delegate loginCellDidFailLoginUser];
        }
        self.view.userInteractionEnabled = YES;
    }];
    
    [client authorizeUsingUserID:account password:password];
}

@end
