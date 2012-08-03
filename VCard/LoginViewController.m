//
//  LoginViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-9.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginViewController.h"
#import "UIApplication+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "NSNotificationCenter+Addition.h"
#import "NSUserDefaults+Addition.h"
#import "UIView+Resize.h"
#import "LoginInputCellViewController.h"
#import "LoginUserCellViewController.h"
#import "InnerBrowserViewController.h"
#import "Status.h"
#import "Comment.h"
#import "Conversation.h"
#import "Group.h"

#define kSinaWeiboRegisterURL @"http://weibo.com/signup/signup.php?ps=u3&lang=zh-cn"

#define LOGO_VIEW_LANDSCAPE_CENTER      CGPointMake(512, 90)
#define LOGO_VIEW_PORTRAIT_CENTER       CGPointMake(384, 125)

#define SCROLL_VIEW_LANDSCAPE_CENTER    CGPointMake(512, 400)
#define SCROLL_VIEW_PORTRAIT_CENTER     CGPointMake(384, 480)

#define MAX_USER_COUNT  3

@interface LoginViewController () {
    LoginViewControllerType _controllerType;
    CGFloat _previousOffset;
    BOOL _bounceBack;
    BOOL _shouldRecordDeceleratingFirst;
    BOOL _shouldRecordDeceleratingSecond;
}

@property (nonatomic, strong) NSMutableArray *cellControllerArray;
@property (nonatomic, strong) NSMutableArray *loginUserInfoArray;
@property (nonatomic, assign) NSUInteger currentCellIndex;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, readonly) LoginInputCellViewController *loginInputCellViewController;

@end

@implementation LoginViewController

@synthesize registerButton = _registerButton;
@synthesize bgView = _bgView;
@synthesize scrollView = _scrollView;
@synthesize logoImageView = _logoImageView;

@synthesize cellControllerArray = _cellControllerArray;
@synthesize loginUserInfoArray = _loginUserInfoArray;
@synthesize keyboardHeight = _keyboardHeight;

- (id)initWithType:(LoginViewControllerType)type {
    self = [self init];
    if(self) {
        _controllerType = type;
        if(_controllerType == LoginViewControllerTypeDeleteCurrentUser) {
            [self deleteUser:self.currentUser];
        }
    }
    return self;
}

- (id)init {
    self = [super init];
    if(self) {
        NSArray *storedArray = [NSUserDefaults getLoginUserArray];
        
        self.loginUserInfoArray = [NSMutableArray array];
        [storedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            User *user = [User getCurrentUserWithID:obj inManagedObjectContext:self.managedObjectContext];
            [self.loginUserInfoArray addObject:user];
        }];
        
        self.cellControllerArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(_controllerType == LoginViewControllerTypeCreateNewUser) {
        self.currentCellIndex = [self numberOfCellsInScrollView] - 1;
    } else if(_controllerType == LoginViewControllerTypeDeleteCurrentUser) {
        [self performSelector:@selector(postDeleteCurrentUserNotification) withObject:nil afterDelay:LOGIN_VIEW_APPEAR_ANIMATION_DURATION];
    }
    
    [self configureUI];
    [self viewAppearAnimation];
}

- (void)viewDidUnload
{
    self.bgView = nil;
    self.registerButton = nil;
    self.scrollView = nil;
    self.logoImageView = nil;
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillLayoutSubviews {
    [self layoutSubviews];
}

#pragma mark - Notification handlers

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect keyboardBounds = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = [UIApplication isCurrentOrientationLandscape] ? keyboardBounds.size.width : keyboardBounds.size.height;
    self.keyboardHeight = keyboardHeight;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutOtherComponent];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardHeight = 0;
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutOtherComponent];
    }];
}

#pragma mark - UI methods

- (void)configureUI {
    [ThemeResourceProvider configButtonPaperLight:self.registerButton];
    [self.view resetSize:[UIApplication sharedApplication].screenSize];
    
    [self configureScrollView];
    [self configureCellGloom];
}

- (void)configureScrollView {
    for(NSUInteger i = 0; i < [self numberOfCellsInScrollView]; i++) {
        UIViewController *vc = [self cellControllerAtIndex:i];
        [self.scrollView addSubview:vc.view];
    }
    [self layoutScrollView];
    
    if([self numberOfCellsInScrollView] > MAX_USER_COUNT) {
        [self.loginInputCellViewController setTooManyUsers:YES];
    }
}

- (void)layoutScrollView {
    CGFloat scrollViewContentWidth = [self numberOfCellsInScrollView] > 1 ? self.scrollView.frame.size.width * [self numberOfCellsInScrollView] : self.scrollView.frame.size.width + 1;
    self.scrollView.contentSize = CGSizeMake(scrollViewContentWidth, self.scrollView.frame.size.height);
    
    for(NSUInteger i = 0; i < [self numberOfCellsInScrollView]; i++) {
        UIViewController *vc = [self cellControllerAtIndex:i];
        
        vc.view.center = CGPointMake(self.scrollView.frame.size.width * (i + 0.5f), self.scrollView.frame.size.height / 2);
        vc.view.layer.anchorPoint = CGPointMake(0.5, 0.074);
        vc.view.layer.position = CGPointMake(vc.view.frame.origin.x + vc.view.frame.size.width / 2, 14);
    }
    
    self.scrollView.contentOffset = CGPointMake(self.currentCellIndex * self.scrollView.frame.size.width, 0);
}

- (void)layoutSubviews {
    [self layoutScrollView];
    [self layoutOtherComponent];
}

- (void)layoutOtherComponent {
    self.logoImageView.center = [UIApplication isCurrentOrientationLandscape] ? CGPointMake(LOGO_VIEW_LANDSCAPE_CENTER.x, LOGO_VIEW_LANDSCAPE_CENTER.y) : LOGO_VIEW_PORTRAIT_CENTER;
    
    self.scrollView.center = [UIApplication isCurrentOrientationLandscape] ? CGPointMake(SCROLL_VIEW_LANDSCAPE_CENTER.x, SCROLL_VIEW_LANDSCAPE_CENTER.y) : SCROLL_VIEW_PORTRAIT_CENTER;
    
    [self.bgView resetOriginY:-self.keyboardHeight / 5 * 3];
}

- (void)show {
    [UIApplication presentModalViewController:self animated:NO duration:LOGIN_VIEW_APPEAR_ANIMATION_DURATION];
    [self viewWillAppear:NO];
}

- (void)removeCellAtIndex:(NSUInteger)index {
    LoginCellViewController *middle = [self.cellControllerArray objectAtIndex:index];
    LoginCellViewController *right = index < self.cellControllerArray.count - 1 ?  [self.cellControllerArray objectAtIndex:index + 1] : nil;
    [self.cellControllerArray removeObject:middle];
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        middle.gloomImageView.alpha = 1;
        right.gloomImageView.alpha = 0;
        [middle.view resetOriginY:1000];
        [right.view resetOriginX:middle.view.frame.origin.x];
    } completion:^(BOOL finished) {
        [self layoutScrollView];
        [middle.view removeFromSuperview];
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)configureCellGloom {
    LoginCellViewController *left = self.currentCellIndex > 0 ? [self.cellControllerArray objectAtIndex:self.currentCellIndex - 1] : nil;
    LoginCellViewController *middle = [self.cellControllerArray objectAtIndex:self.currentCellIndex];
    LoginCellViewController *right = self.currentCellIndex < [self numberOfCellsInScrollView] - 1 ? [self.cellControllerArray objectAtIndex:self.currentCellIndex + 1] : nil;
    CGFloat halfScreenWidth = [UIApplication screenWidth] / 2;
    CGFloat scrollViewWidth = self.scrollView.frame.size.width;
    CGFloat relativeOffsetX = self.scrollView.contentOffset.x - self.currentCellIndex * scrollViewWidth;
    
    left.gloomImageView.alpha = fabs(middle.view.center.x - left.view.center.x + relativeOffsetX) / halfScreenWidth;
    middle.gloomImageView.alpha = fabs(relativeOffsetX) / halfScreenWidth;
    right.gloomImageView.alpha = fabs(right.view.center.x - middle.view.center.x - relativeOffsetX) / halfScreenWidth;
}

#pragma mark - Logic methods

- (void)postDeleteCurrentUserNotification {
    [NSNotificationCenter postCoreChangeCurrentUserNotificationWithUserID:nil];
}

- (LoginInputCellViewController *)loginInputCellViewController {
    return [self.cellControllerArray lastObject];
}

- (NSUInteger)numberOfCellsInScrollView {
    return self.loginUserInfoArray.count + 1;
}

- (UIViewController *)cellControllerAtIndex:(NSUInteger)index {
    if(index >= self.cellControllerArray.count) {
        UIViewController *vc = nil;
        if(self.loginUserInfoArray.count <= index) {
            vc = [[LoginInputCellViewController alloc] init];
            ((LoginInputCellViewController *)vc).delegate = self;
        } else {
            User *user = [self.loginUserInfoArray objectAtIndex:index];
            vc = [[LoginUserCellViewController alloc] initWithUser:user];
            ((LoginUserCellViewController *)vc).delegate = self;
        }
        [self.cellControllerArray addObject:vc];
        return vc;
    } else {
        return [self.cellControllerArray objectAtIndex:index];
    }
}

// return -1 if user not exist, else return the index of the user in self.loginUserInfoArray
- (NSUInteger)deleteUser:(User *)oldUser {
    NSMutableArray *userIDArray = [NSMutableArray array];
    __block NSUInteger index = NSUIntegerMax;
    [self.loginUserInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        User *user = obj;
        if([user.userID isEqualToString:oldUser.userID])
            index = idx;
        else
            [userIDArray addObject:user.userID];
    }];
    
    NSString *userID = oldUser.userID;
    
    [User deleteAllObjectsOfUser:userID InManagedObjectContext:self.managedObjectContext];
    [Status deleteAllObjectsFetchedByUser:userID InManagedObjectContext:self.managedObjectContext];
    [Comment deleteAllCommentsFetchedByCurrentUser:userID inManagedObjectContext:self.managedObjectContext];
    [Conversation deleteAllConversationsOfUser:userID managedObjectContext:self.managedObjectContext];
    [Group deleteAllGroupsOfUser:userID inManagedObjectContext:self.managedObjectContext];
    
    if(index != NSUIntegerMax) {
        [self.loginUserInfoArray removeObjectAtIndex:index];
        userIDArray = userIDArray.count > 0 ? userIDArray : nil;
        [NSUserDefaults setLoginUserArray:userIDArray];
        NSLog(@"LoginViewController : remove user at index %d, loginUserInfoArray count %d", index, self.loginUserInfoArray.count);
    }
    return index;
}

- (void)insertNewUser:(User *)newUser {
    NSMutableArray *userIDArray = [NSMutableArray array];
    __block BOOL userAlreadyLogin = NO;
    [self.loginUserInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        User *user = obj;
        if([user.userID isEqualToString:newUser.userID])
            userAlreadyLogin = YES;
        [userIDArray addObject:user.userID];
    }];
    
    if(!userAlreadyLogin) {
        [self.loginUserInfoArray addObject:newUser];
        [userIDArray addObject:newUser.userID];
        [NSUserDefaults setLoginUserArray:userIDArray];
    }
}

#pragma mark - Animations

- (void)viewAppearAnimation {
    __block CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, -frame.size.height);
    self.view.frame = frame;
    [UIView animateWithDuration:LOGIN_VIEW_APPEAR_ANIMATION_DURATION animations:^{
        frame.origin = CGPointMake(0, 0);
        self.view.frame = frame;
    }];
}

- (void)viewDisappearAnimation {
    __block CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, 0);
    self.view.frame = frame;
    [UIView animateWithDuration:LOGIN_VIEW_APPEAR_ANIMATION_DURATION animations:^{
        frame.origin = CGPointMake(0, -frame.size.height);
        self.view.frame = frame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - IBActions 

- (IBAction)didClickRegisterButton:(UIButton *)sender {
    [InnerBrowserViewController loadLinkWithURL:[NSURL URLWithString:kSinaWeiboRegisterURL]];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSUInteger index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.currentCellIndex = index;
    
    if(!decelerate) {
        if(self.currentCellIndex != self.cellControllerArray.count - 1) {
            [self.view endEditing:YES];
        }
    }
    
    _shouldRecordDeceleratingFirst = decelerate;
    if (decelerate) {
        _previousOffset = scrollView.contentOffset.x;
        _bounceBack = scrollView.contentOffset.x > scrollView.contentSize.width;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.currentCellIndex = index;
    
    if(self.currentCellIndex != self.cellControllerArray.count - 1) {
        [self.view endEditing:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self configureCellGloom];
    [self recordScrollViewSpeed];
}

- (void)recordScrollViewSpeed
{
    if (_shouldRecordDeceleratingFirst) {
        _previousOffset = self.scrollView.contentOffset.x;
        _shouldRecordDeceleratingFirst = NO;
        _shouldRecordDeceleratingSecond = YES;
    } else if (_shouldRecordDeceleratingSecond){
        CGFloat offset = self.scrollView.contentOffset.x - _previousOffset;
        if (_bounceBack) {
            offset = -(abs(offset));
        }
        [self swingToAngle:offset];
        _shouldRecordDeceleratingSecond = NO;
    }
}

- (void)swingToAngle:(CGFloat)speed
{
    CGFloat angle = -0.04 * speed / 20 * M_PI;
    for (LoginCellViewController *vc in self.cellControllerArray) {
        
        [vc swingOnceThenHaltToAngle:angle];
    }
}

#pragma mark - LoginCellViewController delegate

- (void)loginCellDidLoginUser:(User *)user {
    [self insertNewUser:user];
    [self viewDisappearAnimation];
    
    [UIApplication dismissModalViewControllerAnimated:NO duration:LOGIN_VIEW_APPEAR_ANIMATION_DURATION];
}

- (void)loginCellWillLoginUser {
    for(UIView *view in self.scrollView.subviews) {
        view.userInteractionEnabled = NO;
    }
}

- (void)loginCellDidFailLoginUser {
    for(UIView *view in self.scrollView.subviews) {
        view.userInteractionEnabled = YES;
    }
}

- (void)loginCellDidDeleteUser:(User *)user {
    if([self.currentUser.userID isEqualToString:user.userID]) {
        [NSNotificationCenter postCoreChangeCurrentUserNotificationWithUserID:nil];
    }
    
    NSUInteger index = [self deleteUser:user];
    [self removeCellAtIndex:index];
    
    if([self numberOfCellsInScrollView] <= MAX_USER_COUNT) {
        [self.loginInputCellViewController setTooManyUsers:NO];
    }
}

@end
