//
//  PostNewStatusViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-6-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostNewStatusViewController.h"
#import "WBClient.h"

@interface PostNewStatusViewController ()

@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation PostNewStatusViewController
@synthesize locationManager = locationManager;

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
    self.textView.text = @"";
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - UI methods

- (void)showNavLocationLabel:(NSString *)place {
    self.navLabel.text = place;
    CGFloat y = self.navLabel.frame.origin.y;
    [self.navLabel sizeToFit];
    __block CGRect frame = self.navLabel.frame;
    frame.origin.y = y;
    self.navLabel.frame = frame;
    
    CGFloat width = frame.size.width;
    frame.size.width = 0;
    self.navLabel.frame = frame;
    self.navButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        frame.size.width = width;
        self.navLabel.frame = frame;
        
        CGRect rightFuncViewFrame = self.functionRightView.frame;
        rightFuncViewFrame.origin.x = _functionRightViewInitFrame.origin.x + width;
        self.functionRightView.frame = rightFuncViewFrame;
    } completion:^(BOOL finished) {
        self.navButton.userInteractionEnabled = YES;
    }];
}

- (void)hideNavLocationLabel {
    if(self.navLabel.text.length == 0)
        return;
    __block CGRect frame = self.navLabel.frame;
    self.navLabel.frame = frame;
    self.navButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        frame.size.width = 0;
        self.navLabel.frame = frame;
        
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
    self.navActivityView.hidden = YES;
    [self.navActivityView stopAnimating];
    self.navButton.selected = NO;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    self.locationManager = nil;
    _location2D = newLocation.coordinate; 
    
    if(_located)
        return;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if(!client.hasError) {
            NSString *locationString;
            NSArray* array = (NSArray*)client.responseJSONObject;
            if (array.count > 0) {
                NSDictionary *dict = [array objectAtIndex:0];
                NSLog(@"location dict:%@", dict);
                locationString = [NSString stringWithFormat:@"%@%@%@", [dict objectForKey:@"city_name"], [dict objectForKey:@"district_name"], [dict objectForKey:@"name"]];
            }
            [self showNavLocationLabel:locationString];
        } else {
            self.navButton.selected = NO;
        }
        
        [self.navActivityView stopAnimating];
        self.navButton.hidden = NO;
        self.navActivityView.hidden = YES;
    }];
    
    float lat = _location2D.latitude;
    float lon = _location2D.longitude;
    [client getAddressFromGeoWithCoordinate:[[NSString alloc] initWithFormat:@"%f,%f", lon, lat]];
    
    _located = YES;
}

#pragma mark - IBActions 

- (IBAction)didClickNavButton:(UIButton *)sender {
    BOOL select = !sender.isSelected;
    if(select) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager startUpdatingLocation];
        
        self.navButton.hidden = YES;
        self.navActivityView.hidden = NO;
        [self.navActivityView startAnimating];
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
        NSLog(@"post finish:%@", client.responseJSONObject);
        if(!client.hasError) {
            NSLog(@"post succeeded");
            [self.delegate postViewController:self didPostMessage:self.textView.text];
        } else {
            NSLog(@"post failed");
            [self.delegate postViewController:self didFailPostMessage:self.textView.text];
        }
    }];
    if(!_located)
        [client sendWeiBoWithText:self.textView.text image:self.motionsOriginalImage];
    else {
        NSString *lat = [NSString stringWithFormat:@"%f", _location2D.latitude];
        NSString *lon = [NSString stringWithFormat:@"%f", _location2D.longitude];
        [client sendWeiBoWithText:self.textView.text image:self.motionsOriginalImage longtitude:lon latitude:lat];
    }
    [self.delegate postViewController:self willPostMessage:self.textView.text];
}

@end
