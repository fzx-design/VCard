//
//  PostNewStatusViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-6-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostNewStatusViewController.h"
#import "WBClient.h"
#import "ErrorIndicatorViewController.h"
#import "NSUserDefaults+Addition.h"
#import "ErrorIndicatorViewController.h"

@interface PostNewStatusViewController ()

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, assign) CGRect navLabelInitFrame;

@end

@implementation PostNewStatusViewController
@synthesize locationManager = locationManager;
@synthesize navLabelInitFrame = _navLabelInitFrame;

- (id)initWithContent:(NSString *)content {
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"PostViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.functionLeftCheckmarkView.hidden = YES;
    self.functionLeftNavView.hidden = NO;
    if (self.content)
        self.textView.text = self.content;
    else
        self.textView.text = @"";
    self.navLabelInitFrame = self.navLabel.frame;
    
    self.textView.selectedRange = NSMakeRange(self.textView.text.length, 0);

    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - UI methods

- (void)unfoldAnimationDidFinish {
    if ([NSUserDefaults isAutoLocateEnabled])
        [self didClickNavButton:self.navButton];
}

- (void)showNavLocationLabel:(NSString *)place {
    self.navLabel.text = place;
    CGFloat y = self.navLabel.frame.origin.y;
    [self.navLabel sizeToFit];
    __block CGRect frame = self.navLabel.frame;
    frame.origin.y = y;
    frame.origin.x = self.navLabelInitFrame.origin.x;
    self.navLabel.frame = frame;
    
    CGFloat originX = frame.origin.x;
    frame.origin.x = originX - frame.size.width;
    self.navLabel.frame = frame;
    self.navLabel.alpha = 0;
    self.navButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        frame.origin.x = originX;
        self.navLabel.frame = frame;
        self.navLabel.alpha = 1;
        
        CGRect rightFuncViewFrame = self.functionRightView.frame;
        rightFuncViewFrame.origin.x = _functionRightViewInitFrame.origin.x + frame.size.width;
        self.functionRightView.frame = rightFuncViewFrame;
    } completion:^(BOOL finished) {
        self.navButton.userInteractionEnabled = YES;
    }];
}

- (void)hideNavLocationLabel {
    if (self.navLabel.text.length == 0)
        return;
    __block CGRect frame = self.navLabel.frame;
    self.navLabel.alpha = 1;
    self.navButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        frame.origin.x -= frame.size.width;
        self.navLabel.frame = frame;
        self.navLabel.alpha = 0;
        
        CGRect rightFuncViewFrame = self.functionRightView.frame;
        rightFuncViewFrame.origin.x = _functionRightViewInitFrame.origin.x;
        self.functionRightView.frame = rightFuncViewFrame;
    } completion:^(BOOL finished) {
        self.navLabel.text = @"";
        self.navButton.userInteractionEnabled = YES;
    }];
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    self.navButton.hidden = NO;
    self.navActivityIndicator.hidden = YES;
    [self.navActivityIndicator stopAnimating];
    self.navButton.selected = NO;
    [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureFailure contentText:@"定位失败"];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    self.locationManager = nil;
    _location2D = newLocation.coordinate; 
    
    if (_located)
        return;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSString *locationString;
            NSArray* array = (NSArray*)client.responseJSONObject;
            if (array.count > 0) {
                NSDictionary *dict = [array objectAtIndex:0];
                NSString *city = [dict objectForKey:@"city_name"];
                NSString *district = [dict objectForKey:@"district_name"];
                NSString *name = [dict objectForKey:@"name"];
                
                locationString = [NSString stringWithFormat:@"%@%@%@", city ? city : @"", district ? district : @"", name ? name : @""];
            }
            [self showNavLocationLabel:locationString];
        } else {
            self.navButton.selected = NO;
        }
        
        [self.navActivityIndicator stopAnimating];
        self.navButton.hidden = NO;
        self.navActivityIndicator.hidden = YES;
    }];
    
    float lat = _location2D.latitude;
    float lon = _location2D.longitude;
    [client getAddressFromGeoWithCoordinate:[[NSString alloc] initWithFormat:@"%f,%f", lon, lat]];
    
    _located = YES;
}

#pragma mark - IBActions 

- (IBAction)didClickNavButton:(UIButton *)sender {
    BOOL select = !sender.isSelected;
    if (select) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager startUpdatingLocation];
        
        self.navButton.hidden = YES;
        self.navActivityIndicator.hidden = NO;
        [self.navActivityIndicator startAnimating];
    } else {
        _located = NO;
        [self hideNavLocationLabel];
    }
    sender.selected = select;
}

- (IBAction)didClickPostButton:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [self.delegate postViewController:self didPostMessage:self.textView.text];
            [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeProcedureSuccess contentText:@"发表成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldHidePostIndicator object:nil];
        } else {
            [self.delegate postViewController:self didFailPostMessage:self.textView.text];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldHidePostIndicator object:nil];
        }
    }];
        
    if (!_located)
        [client sendWeiBoWithText:self.textView.text image:self.motionsOriginalImage];
    else {
        NSString *lat = [NSString stringWithFormat:@"%f", _location2D.latitude];
        NSString *lon = [NSString stringWithFormat:@"%f", _location2D.longitude];
        [client sendWeiBoWithText:self.textView.text image:self.motionsOriginalImage longtitude:lon latitude:lat];
    }
    [self.delegate postViewController:self willPostMessage:self.textView.text];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowPostIndicator object:nil];
}

@end
