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
    self.avatarImageView = nil;
    self.loginButton = nil;
    self.gloomImageView = nil;
    self.avatarBgImageView = nil;
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
}

- (void)loginUsingAccount:(NSString *)account
                 password:(NSString *)password
               completion:(void (^)(BOOL succeeded))compeltion {
    [self.delegate loginCellWillLoginUser];
    
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            User *user = [User insertCurrentUser:userDict inManagedObjectContext:self.managedObjectContext];
            
            [NSUserDefaults insertUserAccountInfoWithUserID:user.userID account:account password:password];
            
            [NSNotificationCenter postCoreChangeCurrentUserNotificationWithUserID:user.userID];
            
            [self.delegate loginCellDidLoginUser:user];
            
            
            if(compeltion)
                compeltion(YES);
            
            NSLog(@"login step 3 succeeded");
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

- (void)swingOnceThenHaltToAngle:(CGFloat)angle
{
    self.view.layer.anchorPoint = CGPointMake(0.5, 0.074);
    self.view.layer.position = CGPointMake(self.view.frame.origin.x + self.view.frame.size.width / 2 , 14);
    
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    NSMutableArray* animationArray = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i < 5; i++) {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:((4-i)/5.0)*((4-i)/5.0)*angle*(-1+2*(i%2))];
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.duration = 0.4;
        rotationAnimation.beginTime = i * 0.4;
        
        [animationArray addObject:rotationAnimation];
    }
    [animationGroup setAnimations:animationArray];
    [animationGroup setDuration:2.0];
    
    [self.view.layer removeAllAnimations];
    [self.view.layer addAnimation:animationGroup forKey:@"swingAnimation"];
}

@end
