//
//  RootViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RootViewController.h"
#import "WBClient.h"
#import "ResourceList.h"
#import "Group.h"
#import "LoginViewController.h"
#import "NSNotificationCenter+Addition.h"
#import "UIApplication+Addition.h"
#import "NSUserDefaults+Addition.h"
#import "GuideBookViewController.h"
#import "TipsViewController.h"

#define kShelfViewControllerFrame CGRectMake(0.0, -150.0, 768.0, 150.0);

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize castViewController = _castViewController;
@synthesize shelfViewController = _shelfViewController;

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
    self.navigationController.navigationBarHidden = YES;
    [self setUpNotifications];
    if(self.currentUser) {
        [self setUpViews];
        [self loadUserAndChangeAvatar];
    }
    
    [NSNotificationCenter registerChangeCurrentUserNotificationWithSelector:@selector(handleChangeCurrentUserNotification:) target:self];
    [NSNotificationCenter postRootViewControllerViewDidLoadNotification];
}

- (void)loadUserAndChangeAvatar
{
    WBClient *userClient = [WBClient client];
    
    [userClient setCompletionBlock:^(WBClient *client) {
        if (!userClient.hasError) {
            NSDictionary *userDict = client.responseJSONObject;
            [User insertUser:userDict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
            [NSNotificationCenter postChangeUserAvatarNotification];
        }
    }];
    
    [userClient getUser:self.currentUser.userID];
}

- (void)loadUserFavouritesID
{
    __block int count = 0;
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSMutableArray *favouriteIDs = [[NSMutableArray alloc] init];
            NSDictionary *result = client.responseJSONObject;
            NSArray *dictArray = [result objectForKey:@"favorites"];
            for (NSDictionary *dict in dictArray) {
                NSString *favouriteID = [dict objectForKey:@"status"];
                [favouriteIDs addObject:favouriteID];
            }
            self.currentUser.favouritesIDs = favouriteIDs;
            [NSUserDefaults setCurrentUserFavouriteIDs:favouriteIDs];
            
        } else {
            if (count < 3) {
                count++;
                [client getFavouriteIDs];
            } else {
                NSArray *favouriteIDs = self.currentUser.favouritesIDs;
                [NSUserDefaults setCurrentUserFavouriteIDs:favouriteIDs];
            }
        }
    }];
    
    [client getFavouriteIDs];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.currentUser == nil) {
        [[[LoginViewController alloc] init] show];
    }
}

#pragma mark - Handle notifications

- (void)showGuideBookView {
    if([NSUserDefaults hasShownGuideBook] == NO) {
        [NSUserDefaults setShownGuideBook:YES];
        [[[GuideBookViewController alloc] init] show];
    }
}

- (void)handleChangeCurrentUserNotification:(NSNotification *)notification {
    NSLog(@"current user name:%@", self.currentUser.screenName);
    self.castViewController = nil;
    self.shelfViewController = nil;
    if(self.currentUser) {
        [Group setUpDefaultGroupWithUserID:self.currentUser.userID defaultImageURL:self.currentUser.largeAvatarURL inManagedObjectContext:self.managedObjectContext];
        [self setUpViews];
        if (![[NSUserDefaults getLoginUserArray] containsObject:self.currentUser.userID]) {
            [self.castViewController clearData];
            [self.managedObjectContext processPendingChanges];
            [self.castViewController refresh];
        }
        [self performSelector:@selector(showGuideBookView) withObject:nil afterDelay:1.0f];
    }
}

#pragma mark - Setup Notifications
- (void)setUpViews
{
    [self.view resetOrigin:CGPointZero];
    [self.view resetSize:CGSizeMake([UIApplication screenWidth], [UIApplication screenHeight])];
    [self.view insertSubview:self.castViewController.view belowSubview:self.detailImageViewController.view];
    [self.view insertSubview:self.shelfViewController.view belowSubview:self.castViewController.view];
    [self.castViewController viewWillAppear:NO];
    [self.shelfViewController viewWillAppear:NO];
    self.shelfViewController.view.hidden = YES;
    
    
    [self loadUserFavouritesID];
}

- (void)setUpNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(showGroup:)
                   name:kNotificationNameShouldShowGroup
                 object:nil];
    [center addObserver:self
               selector:@selector(hideGroup:)
                   name:kNotificationNameShouldHideGroup
                 object:nil];
    [center addObserver:self
               selector:@selector(showDetailImageView:)
                   name:kNotificationNameShouldShowDetailImageView
                 object:nil];
    [center addObserver:self
               selector:@selector(hideDetailImageView:)
                   name:kNotificationNameShouldHideDetailImageView
                 object:nil];
}

#pragma mark - Notifications
#pragma mark Shelf View Controller Notifications
- (void)showGroup:(NSNotification *)notification
{
    self.shelfViewController.view.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [_castViewController.view resetOriginY:_shelfViewController.view.frame.size.height - 2];
        [_shelfViewController.view resetOriginY:0.0];
        _shelfViewController.coverView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(![NSUserDefaults hasShownShelfTips]) {
            [[[TipsViewController alloc] initWithType:TipsViewControllerTypeShelf] show];
            [NSUserDefaults setShownShelfTips:YES];
        }
        [self addBackButtonWhenShelfIsShown];
        self.castViewController.groupButton.selected = YES;
    }];
}

- (void)hideGroup:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [_castViewController.view resetOriginY:0.0];
        [_shelfViewController.view resetOriginY:-_shelfViewController.view.frame.size.height];
        _shelfViewController.coverView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [_shelfViewController exitEditMode];
    }];
}

- (void)addBackButtonWhenShelfIsShown
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 150.0, 1024.0, 1024.0)];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.autoresizingMask = UIViewAutoresizingNone;
    [backButton addTarget:self action:@selector(didClickBackButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backButton];
}

- (void)didClickBackButton:(UIButton *)sender
{
    [sender removeFromSuperview];
    sender = nil;
    [self hideGroup:nil];
    self.castViewController.groupButton.selected = NO;
}

- (void)showDetailImageView:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    CardViewController *vc = [dict objectForKey:kNotificationObjectKeyStatus];
    self.detailImageViewController.view.hidden = NO;
    self.detailImageViewController.view.userInteractionEnabled = YES;
    [self.detailImageViewController setUpWithCardViewController:vc];
}

- (void)hideDetialImageView:(NSNotification *)notification
{
    self.detailImageViewController.view.hidden = YES;
    self.detailImageViewController.view.userInteractionEnabled = NO;
}

#pragma mark - Handle Rotations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    NSString *orientation = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? kOrientationPortrait : kOrientationLandscape;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameOrientationWillChange object:orientation];
    
    [_castViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [_shelfViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [_detailImageViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameOrientationChanged object:nil];
    [_castViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [_shelfViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [_detailImageViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)setCastViewController:(CastViewController *)castViewController
{
    [_castViewController.view removeFromSuperview];
    _castViewController = castViewController;
}

- (void)setShelfViewController:(ShelfViewController *)shelfViewController
{
    [_shelfViewController.view removeFromSuperview];
    _shelfViewController = shelfViewController;
}

#pragma mark - CardViewControllerDelegate
- (void)didDragCastViewWithOffset:(CGFloat)offset
{
    self.shelfViewController.view.hidden = NO;
    if (offset >= 0.0 && offset <= 150.0) {
        [self.castViewController.view resetOriginY:ceilf(offset)];
        [self.shelfViewController.view resetOriginY:ceilf(offset - 150.0)];
        self.shelfViewController.coverView.alpha = (150.0 - offset) / 150.0;
    }
}

- (void)didSwipeCastView
{
    [self showGroup:nil];
}

- (void)didEndDraggingCastViewWithOffset:(CGFloat)offset
{
    if (offset >= 40.0) {
        [self showGroup:nil];
    } else {
        [self hideGroup:nil];
    }
}

#pragma mark - Properties
- (CastViewController*)castViewController
{
    if (_castViewController == nil) {
        _castViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CastViewController"];
        [_castViewController.view resetSize:self.view.frame.size];
        [_castViewController.view resetOrigin:CGPointZero];
        _castViewController.delegate = self;
    }
    return _castViewController;
}

- (ShelfViewController *)shelfViewController
{
    if (_shelfViewController == nil) {
        _shelfViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShelfViewController"];
        _shelfViewController.view.frame = kShelfViewControllerFrame;
        [_shelfViewController.view resetWidth:self.view.bounds.size.width];
    }
    return _shelfViewController;
}

- (DetailImageViewController *)detailImageViewController
{
    if (!_detailImageViewController) {
        _detailImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailImageViewController"];
        _detailImageViewController.view.frame = self.view.bounds;
        _detailImageViewController.view.hidden = YES;
        [self.view addSubview:_detailImageViewController.view];
        [_detailImageViewController viewWillAppear:NO];
    }
    return _detailImageViewController;
}

@end
