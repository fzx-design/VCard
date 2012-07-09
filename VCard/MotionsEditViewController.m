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
@property (nonatomic, strong) CropImageViewController *cropImageViewController;
@property (nonatomic, readonly, getter = isShadowAmountFilterAdded) BOOL shadowAmountFilterAdded;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) MotionsFilterTableViewController *filterViewController;
@property (nonatomic, strong) MotionsFilterInfo *currentFilterInfo;
@property (nonatomic, strong) UIImage *cacheFilteredImage;
@property (nonatomic, assign) CGFloat currentShadowAmountValue;

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
@synthesize capturedImageEditBar = _capturedImageEditView;
@synthesize activityIndicator = _activityIndicator;
@synthesize editAccessoryView = _editAccessoryView;

@synthesize originalImage = _originalImage;
@synthesize modifiedImage = _modifiedImage;
@synthesize filterImage = _filterImage;
@synthesize dirty = _dirty;
@synthesize popoverController = _pc;
@synthesize actionSheet = _actionSheet;
@synthesize filterViewController = _filterViewController;
@synthesize currentFilterInfo = _currentFilterInfo;
@synthesize cacheFilteredImage = _cacheFilteredImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.changePictureButton = nil;
    self.revertButton = nil;
    self.finishEditButton = nil;
    self.bgView = nil;
    self.functionView = nil;
    self.capturedImageView = nil;
    self.capturedImageEditBar = nil;
    self.activityIndicator = nil;
    self.editAccessoryView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    UIImage *currentImage = self.cacheFilteredImage;
    currentImage = currentImage ? currentImage : self.modifiedImage;
    [self configureFilterImageView:currentImage];
}

- (void)loadViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *filteredImage = self.filteredImage;
        UIImage *targetImage = image;
        self.currentFilterInfo = nil;
        self.cacheFilteredImage = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetSliders];
            [self currentImage:filteredImage targetImage:targetImage transitionAnimationWithCompletion:^{
                [self configureFilterImageView:self.modifiedImage];
            }];
            
            BOOL reloadFilterTableView = (self.originalImage != image || self.originalImage != self.modifiedImage);
            
            self.originalImage = image;
            self.modifiedImage = self.originalImage;
            
            if(reloadFilterTableView)
                [self.filterViewController refreshWithImage:self.modifiedImage];
            else
                [self.filterViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
            
            [self.activityIndicator fadeOutWithCompletion:^{
                [self.activityIndicator stopAnimating];
            }];
        });
    });
}

- (BOOL)isShadowAmountFilterAdded {
    return self.currentShadowAmountValue != 0;
}

- (UIImage *)filteredImage {
    UIImage *filteredImage = [self.currentFilterInfo processImage:self.modifiedImage];
    filteredImage = filteredImage ? filteredImage : self.modifiedImage;
    if(self.isShadowAmountFilterAdded) {
        filteredImage = [filteredImage shadowAmount:self.currentShadowAmountValue];
    }
    return filteredImage;
}

- (UIImage *)cacheFilteredImage {
    if(!_cacheFilteredImage) {
        //NSLog(@"make cache filter image using %@", self.currentFilterInfo.filterName);
        _cacheFilteredImage = [self.currentFilterInfo processImage:self.modifiedImage];
    }
    return _cacheFilteredImage;
}

- (MotionsFilterTableViewController *)filterViewController {
    if(!_filterViewController) {
        _filterViewController = [[MotionsFilterTableViewController alloc] initWithImage:self.originalImage];
        _filterViewController.delegate = self;
        [self.subViewControllers addObject:_filterViewController];
    }
    return _filterViewController;
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
    [self.bgView insertSubview:tempImageView belowSubview:self.capturedImageEditBar];
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
        for(UIView *subview in self.editAccessoryView.subviews) {
            if(subview.tag != CROP_BUTTON_TAG) {
                subview.alpha = 0.2f;
                subview.userInteractionEnabled = NO;
            }
        }
        self.filterViewController.view.alpha = 0.2f;
        self.filterViewController.view.userInteractionEnabled = NO;
    }];
}

- (void)opaqueEditViewAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        for(UIView *subview in self.editAccessoryView.subviews) {
            subview.alpha = 1;
        }
        self.filterViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        for(UIView *subview in self.editAccessoryView.subviews) {
            if([subview isMemberOfClass:[UIView class]])
                subview.userInteractionEnabled = YES;
        }
        self.filterViewController.view.userInteractionEnabled = YES;
    }];
}

- (void)hideCropImageViewControllerAnimation {
    [self opaqueEditViewAnimation];
    self.cropButton.userInteractionEnabled = NO;
        
    [self.cropImageViewController.editBarView fadeOut];
    [self.capturedImageEditBar fadeIn];
    
    self.cropButton.selected = NO;
    [self.cropImageViewController zoomOutToCenter:self.filterImageView.center withScaleFactor:self.capturedImageView.contentScaleFactor completion:^{
        [self.cropImageViewController.view removeFromSuperview];
        self.cropImageViewController = nil;
        self.cropButton.userInteractionEnabled = YES;
    }];
}

- (void)setShowEditAccessoriesFrame {
    CGRect editAccessoryFrame = self.editAccessoryView.frame;
    CGRect filterFrame = self.filterViewController.view.frame;
    if(self.isCurrentOrientationLandscape) {
        editAccessoryFrame.origin.x = 1024 - editAccessoryFrame.size.width;
        editAccessoryFrame.origin.y = 0;
        
        filterFrame.origin.x = 0;
        filterFrame.origin.y = 0;
    } else {
        editAccessoryFrame.origin.x = 0;
        editAccessoryFrame.origin.y = 0;
        
        filterFrame.origin.x = 0;
        filterFrame.origin.y = 0;
    }
    self.editAccessoryView.frame = editAccessoryFrame;
    self.filterViewController.view.frame = filterFrame;
}

- (void)setHideEditAccessoriesFrame {
    CGRect editAccessoryFrame = self.editAccessoryView.frame;
    CGRect filterFrame = self.filterViewController.view.frame;
    if(self.isCurrentOrientationLandscape) {
        editAccessoryFrame.origin.x = 1024;
        editAccessoryFrame.origin.y = 0;
        
        filterFrame.origin.x = editAccessoryFrame.size.width;
        filterFrame.origin.y = 0;
    } else {
        editAccessoryFrame.origin.x = 0 - editAccessoryFrame.size.width;
        editAccessoryFrame.origin.y = 0;
        
        filterFrame.origin.x = 0;
        filterFrame.origin.y = self.filterViewController.bgView.frame.size.height;
    }
    self.editAccessoryView.frame = editAccessoryFrame;
    self.filterViewController.view.frame = filterFrame;
}

- (void)hideEditAccessoriesAnimationWithCompletion:(void (^)(void))completion {
    [self setShowEditAccessoriesFrame];
    [UIView animateWithDuration:0.3f animations:^{
        [self setHideEditAccessoriesFrame];
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

- (void)showEditAccessoriesAnimationWithCompletion:(void (^)(void))completion {
    [self setHideEditAccessoriesFrame];
    [UIView animateWithDuration:0.3f animations:^{
        [self setShowEditAccessoriesFrame];
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

#pragma mark - UI methods

- (void)configureFilterTableViewController {
    [self.functionView insertSubview:self.filterViewController.view atIndex:0];
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
    self.filterImageView.shadowAmountValue = self.currentShadowAmountValue;
    [self.filterImageView setNeedsDisplay];
    if(filterImageViewEmpty)
        [self.filterImageView fadeIn];
    self.filterImage = filterImage;
    [(NSObject *)self.delegate performSelector:@selector(editViewControllerDidBecomeActiveWithCompletion:) withObject:nil afterDelay:0.3f];
}

- (void)configureSlider {
    [self.shadowAmountSlider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[self.shadowAmountSlider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    
    [self.shadowAmountSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb.png"] forState:UIControlStateNormal];
    self.shadowAmountSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    CGRect frame = self.shadowAmountSlider.frame;
    frame.origin.x = (int)(frame.origin.x);
    frame.origin.y = (int)(frame.origin.y);
    self.shadowAmountSlider.frame = frame;
    
    [self.shadowAmountSlider setValue:self.currentShadowAmountValue * -1 animated:NO];
}

- (void)configureButtons {
    [ThemeResourceProvider configButtonDark:self.changePictureButton];
    [ThemeResourceProvider configButtonDark:self.revertButton];
}

- (void)resetSliders {
    self.currentShadowAmountValue = 0;
    [self.shadowAmountSlider setValue:self.currentShadowAmountValue animated:YES];
    [self.filterImageView initializeParameter];
}

#pragma mark - IBActions

- (IBAction)didChangeSlider:(UISlider *)sender {
    self.currentShadowAmountValue = -1 * sender.value;
    self.filterImageView.shadowAmountValue = self.currentShadowAmountValue;
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
            UIImage *filteredImage = self.filteredImage;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cropImageViewController = [[CropImageViewController alloc] initWithImage:self.modifiedImage filteredImage:filteredImage];
                self.cropImageViewController.delegate = self;
                self.cropImageViewController.view.frame = self.filterImageView.frame;
                
                [self.bgView insertSubview:self.cropImageViewController.view aboveSubview:self.capturedImageEditBar];
                
                self.cropButton.userInteractionEnabled = NO;
                [self.cropImageViewController zoomInFromCenter:self.filterImageView.center withScaleFactor:self.capturedImageView.contentScaleFactor completion:^{
                    self.cropButton.userInteractionEnabled = YES;
                    
                    [self.activityIndicator fadeOutWithCompletion:^{
                        [self.activityIndicator stopAnimating];
                    }];
                }];
                
                [self.cropImageViewController.editBarView fadeIn];
                [self.capturedImageEditBar fadeOut];
            });
        });
    } else {
        [self.cropImageViewController didClickFinishCropButton:sender];
    }
}

- (IBAction)didClickChangePictureButton:(UIButton *)sender {
    
    if(![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        [self showAlbumImagePicker];
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
        UIImage *filteredImage = [self.currentFilterInfo processImage:self.modifiedImage];
        filteredImage = filteredImage ? filteredImage : self.modifiedImage;
        self.capturedImageView.image = filteredImage;
        self.cacheFilteredImage = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureFilterImageView:filteredImage];
            [self hideCropImageViewControllerAnimation];
            
            CGPoint filterTableViewContentOffset = self.filterViewController.tableView.contentOffset;
            [self.filterViewController refreshWithImage:self.modifiedImage];
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
        [self.delegate editViewControllerDidChooseToShoot];
    }
    self.actionSheet = nil;
}

#pragma mark -
#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.popoverController dismissPopoverAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.popoverController = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *rotatedImage = [image motionsAdjustImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initViewWithImage:rotatedImage];
        });
    });
}

#pragma mark -
#pragma mark UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
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
        UIImage *currentImage = self.cacheFilteredImage;
        currentImage = currentImage ? currentImage : self.modifiedImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetSliders];
            [self currentImage:currentImage targetImage:filteredImage transitionAnimationWithCompletion:^{
                [self configureFilterImageView:filteredImage];
                self.currentFilterInfo = info;
                self.cacheFilteredImage = filteredImage;
            }];
            
            [self.activityIndicator fadeOutWithCompletion:^{
                [self.activityIndicator stopAnimating];
            }];
        });
    });
}

@end
