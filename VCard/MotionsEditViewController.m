//
//  MotionsEditViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsEditViewController.h"
#import "UIImage+Addition.h"
#import "UIView+Addition.h"
#import "CropImageViewController.h"
#import "UIApplication+Addition.h"

#define CROP_BUTTON_TAG 1001

#define MOTIONS_EDIT_ACTION_SHEET_SHOOT_INDEX    0
#define MOTIONS_EDIT_ACTION_SHEET_ALBUM_INDEX    1

#define FILTER_TABLE_VIEW_CENTER CGPointMake(77, 540)

@interface MotionsEditViewController ()

@property (nonatomic, assign, getter = isDirty) BOOL dirty;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *modifiedImage;
@property (nonatomic, strong) UIImage *filterImage;
@property (nonatomic, readonly) UIImage *filteredImage;
@property (nonatomic, assign) UIInterfaceOrientation currentInterfaceOrientation;
@property (nonatomic, strong) CropImageViewController *cropImageViewController;
@property (nonatomic, readonly, getter = isShadowAmountFilterAdded) BOOL shadowAmountFilterAdded;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) MotionsFilterTableViewController *filterViewController;
@property (nonatomic, strong) MotionsFilterInfo *currentFilterInfo;
@property (nonatomic, strong) UIImage *cacheFilteredImage;

@end

@implementation MotionsEditViewController

@synthesize cropButton = _cropButton;
@synthesize shadowAmountSlider = _shadowAmountSlider;
@synthesize filterImageView = _filterImageView;
@synthesize changePictureButton = _changePictureButton;
@synthesize finishEditButton = _finishEditButton;
@synthesize revertButton = _revertButton;
@synthesize delegate = _delegate;
@synthesize bgView = _bgView;
@synthesize functionView = _functionView;
@synthesize capturedImageView = _capturedImageView;
@synthesize capturedImageEditView = _capturedImageEditView;
@synthesize activityIndicator = _activityIndicator;

@synthesize originalImage = _originalImage;
@synthesize modifiedImage = _modifiedImage;
@synthesize filterImage = _filterImage;
@synthesize currentInterfaceOrientation = _currentInterfaceOrientation;
@synthesize dirty = _dirty;
@synthesize popoverController = _pc;
@synthesize actionSheet = _actionSheet;
@synthesize filterViewController = _filterViewController;
@synthesize currentFilterInfo = _currentFilterInfo;
@synthesize cacheFilteredImage = _currentFilteredImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [self init];
    if(self) {
        self.originalImage = image;
        self.modifiedImage = self.originalImage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self performSelector:@selector(configureFilterImageView) withObject:nil afterDelay:0.3f];
    self.capturedImageView.image = self.modifiedImage;
    [self configureSlider];
    [self configureButtons];
    [self configureFilterTableViewController];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.cropButton = nil;
    self.shadowAmountSlider = nil;
    self.filterImageView = nil;
    self.changePictureButton = nil;
    self.revertButton = nil;
    self.finishEditButton = nil;
    self.bgView = nil;
    self.functionView = nil;
    self.capturedImageView = nil;
    self.capturedImageEditView = nil;
    self.activityIndicator = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self configureFilterImageView:self.modifiedImage];
}

- (void)loadViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    self.currentInterfaceOrientation = interfaceOrientation;
    [self dismissPopover];
    [super loadViewControllerWithInterfaceOrientation:interfaceOrientation];
}

#pragma mark - Logic methods

- (BOOL)isDirty {
    BOOL result = NO;
    if(self.isShadowAmountFilterAdded)
        result = YES;
    else if(self.currentFilterInfo)
        result = YES;
    else if(self.modifiedImage != self.originalImage)
        result = YES;
    return result;
}

- (void)initViewWithImage:(UIImage *)image {
    [self.activityIndicator fadeIn];
    [self.activityIndicator startAnimating];
    self.currentFilterInfo = nil;
    self.cacheFilteredImage = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *filteredImage = self.filteredImage;
        UIImage *targetImage = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetSliders];
            [self currentImage:filteredImage targetImage:targetImage transitionAnimationWithCompletion:^{
                [self configureFilterImageView:self.modifiedImage];
            }];
            
            self.originalImage = image;
            self.modifiedImage = self.originalImage;
            [self configureFilterTableViewController];
            
            [self.activityIndicator fadeOutWithCompletion:^{
                [self.activityIndicator stopAnimating];
            }];
        });
    });
}

- (BOOL)isShadowAmountFilterAdded {
    return self.shadowAmountSlider.value != 0;
}

- (UIImage *)filteredImage {
    UIImage *filteredImage = [self.currentFilterInfo processImage:self.modifiedImage];
    filteredImage = filteredImage ? filteredImage : self.modifiedImage;
    if(self.isShadowAmountFilterAdded) {
        filteredImage = [filteredImage shadowAmount:self.shadowAmountSlider.value];
    }
    return filteredImage;
}

#pragma mark - Animations 

- (void)currentImage:(UIImage *)currentImage targetImage:(UIImage *)targetIamge transitionAnimationWithCompletion:(void (^)(void))completion {
    self.capturedImageView.image = targetIamge;
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:currentImage];
    tempImageView.opaque = NO;
    tempImageView.clearsContextBeforeDrawing = YES;
    tempImageView.frame = self.filterImageView.frame;
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    [tempImageView setNeedsLayout];
    [self.bgView insertSubview:tempImageView belowSubview:self.capturedImageEditView];
    self.filterImageView.hidden = YES;
    self.capturedImageView.hidden = NO;
    [tempImageView fadeOutWithCompletion:^{
        [tempImageView removeFromSuperview];
        self.filterImageView.hidden = NO;
        self.capturedImageView.hidden = YES;
        if(completion)
            completion();
    }];
}

- (void)semiTransparentEditViewForCropAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        for(UIView *subview in self.functionView.subviews) {
            if(subview.tag != CROP_BUTTON_TAG) {
                subview.alpha = 0.2f;
                subview.userInteractionEnabled = NO;
            }
        }
    }];
}

- (void)opaqueEditViewAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        for(UIView *subview in self.functionView.subviews) {
            subview.alpha = 1;
        }
    } completion:^(BOOL finished) {
        for(UIView *subview in self.functionView.subviews) {
            if([subview isMemberOfClass:[UIView class]])
                subview.userInteractionEnabled = YES;
        }
    }];
}

- (void)hideCropImageViewControllerAnimation {
    [self opaqueEditViewAnimation];
    self.cropButton.userInteractionEnabled = NO;
        
    [self.cropImageViewController.editBarView fadeOut];
    [self.capturedImageEditView fadeIn];
    
    self.cropButton.selected = NO;
    [self.cropImageViewController zoomOutToCenter:self.filterImageView.center withScaleFactor:self.capturedImageView.contentScaleFactor completion:^{
        [self.cropImageViewController.view removeFromSuperview];
        self.cropImageViewController = nil;
        self.cropButton.userInteractionEnabled = YES;
    }];
}

#pragma mark - UI methods

- (void)configureFilterTableViewController {
    MotionsFilterTableViewController *vc = self.filterViewController;
    self.filterViewController = [[MotionsFilterTableViewController alloc] initWithImage:self.modifiedImage];
    self.filterViewController.delegate = self;
    self.filterViewController.view.center = CGPointMake(77, 540);
    [self.functionView addSubview:self.filterViewController.view];
    if(vc) {
        [UIView animateWithDuration:0.3f animations:^{
            [vc.view fadeOut];
            [self.filterViewController.view fadeIn];
        } completion:^(BOOL finished) {
            [vc.view removeFromSuperview];
        }];
    }
}

- (void)dismissPopover {
    if(self.actionSheet) {
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    }
    if(self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
}

- (void)showAlbumImagePicker {
    UIPopoverController *pc =  [UIApplication showAlbumImagePickerFromButton:self.changePictureButton delegate:self];
    self.popoverController = pc;
}

- (void)configureFilterImageView:(UIImage *)image {
    UIImage *filterImage = [image imageCroppedToFitSize:self.filterImageView.frame.size];
    BOOL filterImageViewEmpty = !self.filterImageView.processImage;
    [self.filterImageView setImage:filterImage];
    [self.filterImageView setNeedsDisplay];
    if(filterImageViewEmpty)
        [self.filterImageView fadeIn];
    self.filterImage = filterImage;
    [(NSObject *)self.delegate performSelector:@selector(editViewControllerDidBecomeActiveWithCompletion:) withObject:nil afterDelay:0.3f];
}

- (void)configureSlider {
    [self.shadowAmountSlider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[self.shadowAmountSlider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    if(UIInterfaceOrientationIsLandscape(self.currentInterfaceOrientation)) {
        [self.shadowAmountSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb_horizon.png"] forState:UIControlStateNormal];
        self.shadowAmountSlider.transform = CGAffineTransformMakeRotation(M_PI / 2);
        CGRect frame = self.shadowAmountSlider.frame;
        frame.origin.x = (int)(frame.origin.x);
        frame.origin.y = (int)(frame.origin.y);
        self.shadowAmountSlider.frame = frame;
    } else {
        [self.shadowAmountSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb_vertical.png"] forState:UIControlStateNormal];
    }
}

- (void)configureButtons {
    [ThemeResourceProvider configButtonDark:self.changePictureButton];
    [ThemeResourceProvider configButtonDark:self.revertButton];
}

- (void)resetSliders {
    [self.shadowAmountSlider setValue:0 animated:YES];
    [self.filterImageView initializeParameter];
}

#pragma mark - IBActions

- (IBAction)didChangeSlider:(UISlider *)sender {
    float value = sender.value;
    self.filterImageView.shadowAmountValue = value;
    [self.filterImageView setNeedsDisplay];
    self.cacheFilteredImage = nil;
}

- (IBAction)didClickCropButton:(UIButton *)sender {
    BOOL select = !sender.selected;
    sender.selected = select;
    if(select) {
        [self semiTransparentEditViewForCropAnimation];
        
        [self.activityIndicator fadeIn];
        [self.activityIndicator startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.cropImageViewController = [[CropImageViewController alloc] initWithImage:self.modifiedImage filteredImage:self.filteredImage];
            self.cropImageViewController.delegate = self;
            self.cropImageViewController.view.frame = self.filterImageView.frame;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bgView insertSubview:self.cropImageViewController.view aboveSubview:self.filterImageView];
                
                self.cropButton.userInteractionEnabled = NO;
                [self.cropImageViewController zoomInFromCenter:self.filterImageView.center withScaleFactor:self.capturedImageView.contentScaleFactor completion:^{
                    self.cropButton.userInteractionEnabled = YES;
                }];
                
                [self.cropImageViewController.editBarView fadeIn];
                [self.capturedImageEditView fadeOut];
            });
        });        
    } else {
        [self.cropImageViewController didClickFinishCropButton:sender];
    }
}

- (IBAction)didClickChangePictureButton:(UIButton *)sender {
    
    if(![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        
        return;
    }
    UIActionSheet *actionSheet = nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:self 
                                     cancelButtonTitle:nil 
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"拍照", @"选取照片", nil];

    [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
    self.actionSheet = actionSheet;
}

- (IBAction)didClickRevertButton:(UIButton *)sender {
    if(!self.isDirty) 
        return;
    
    [self initViewWithImage:self.originalImage];
}

- (IBAction)didClickFinishEditButton:(UIButton *)sender {
    [self.activityIndicator fadeIn];
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *filteredImage = self.filteredImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate editViewControllerDidFinishEditImage:filteredImage];
        });
    });
}

#pragma mark - CropImageViewController delegate

- (void)cropImageViewControllerDidFinishCrop:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.modifiedImage = image;
        UIImage *filteredImage = self.filteredImage;
        self.capturedImageView.image = filteredImage;
        self.cacheFilteredImage = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureFilterImageView:filteredImage];
            [self hideCropImageViewControllerAnimation];
            
            CGPoint filterTableViewContentOffset = self.filterViewController.tableView.contentOffset;
            [self configureFilterTableViewController];
            self.filterViewController.tableView.contentOffset = filterTableViewContentOffset;
        });
    });
}

- (void)cropImageViewControllerDidCancelCrop {
    [self hideCropImageViewControllerAnimation];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == MOTIONS_EDIT_ACTION_SHEET_ALBUM_INDEX) {
        [self showAlbumImagePicker];
    } else if(buttonIndex == MOTIONS_EDIT_ACTION_SHEET_SHOOT_INDEX) {
        
    }
    self.actionSheet = nil;
}

#pragma mark -
#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.popoverController dismissPopoverAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.popoverController = nil;
    [self performSelector:@selector(initViewWithImage:) withObject:image afterDelay:0.1f];
}

#pragma mark -
#pragma mark UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"dismiss popover");
    self.popoverController = nil;
}

#pragma mark - 
#pragma mark MotionsFilterTableViewController delegate

- (void)filterTableViewController:(MotionsFilterTableViewController *)vc didSelectFilter:(MotionsFilterInfo *)info {
    if([self.currentFilterInfo.filterName isEqualToString:info.filterName])
        return;
    [self.activityIndicator fadeIn];
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *filteredImage = [info processImage:self.modifiedImage];
        UIImage *currentImage = self.cacheFilteredImage ? self.cacheFilteredImage : [self.currentFilterInfo processImage:self.modifiedImage];
        self.cacheFilteredImage = filteredImage;
        currentImage = currentImage ? currentImage : self.modifiedImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetSliders];
            [self currentImage:currentImage targetImage:filteredImage transitionAnimationWithCompletion:^{
                [self configureFilterImageView:filteredImage];
                self.currentFilterInfo = info;
            }];
            
            [self.activityIndicator fadeOutWithCompletion:^{
                [self.activityIndicator stopAnimating];
            }];
        });
    });
}

@end
