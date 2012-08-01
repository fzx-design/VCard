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
#import "UIImage+Addition.h"

#define CROP_BUTTON_TAG 1001

#define MOTIONS_EDIT_ACTION_SHEET_SHOOT_INDEX    0
#define MOTIONS_EDIT_ACTION_SHEET_ALBUM_INDEX    1

#define FILTER_TABLE_VIEW_CENTER CGPointMake(77, 540)

@interface MotionsEditViewController () {
    BOOL _shouldShowCropView;
    NSUInteger _currentFilterImageViewIndex;
}

@property (nonatomic, assign) BOOL useForAvatar;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *croppedImage;

@property (nonatomic, strong) CropImageViewController *cropImageViewController;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) MotionsFilterTableViewController *filterViewController;
@property (nonatomic, strong) MotionsFilterInfo *currentFilterInfo;
@property (nonatomic, assign) CGFloat currentShadowAmountValue;

@property (readonly, getter = isDirty) BOOL dirty;
@property (readonly, getter = isShadowAmountFilterAdded) BOOL shadowAmountFilterAdded;
@property (readonly) FilterImageView *currentFilterImageView;
@property (readonly) FilterImageView *backupFilterImageView;
@property (readonly) UIImage *filteredImage;
@property (readonly) CGFloat filterImageViewContentScaleFactor;

@end

@implementation MotionsEditViewController

@synthesize popoverController = _pc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImage:(UIImage *)image useForAvatar:(BOOL)useForAvatar {
    self = [self init];
    if(self) {
        self.originalImage = image;
        
        _useForAvatar = useForAvatar;
        _shouldShowCropView = useForAvatar;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self performSelector:@selector(configureFilterImageView) withObject:nil afterDelay:0.3f];
    
    self.croppedImage = self.originalImage;
    
    [self configureSlider];
    [self configureButtons];
    [self configureFilterTableViewController];
    
    self.currentFilterImageView.hidden = NO;
    self.backupFilterImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self configureFilterImageView:self.croppedImage];
}

- (void)loadViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self dismissPopover];
    [super loadViewControllerWithInterfaceOrientation:interfaceOrientation];
}

#pragma mark - Logic methods

- (void)refreshViewWithImage:(UIImage *)image {    
    self.currentFilterInfo = nil;
    
    [self changeCurrentFilterImageView];
    [self resetSliders];
    [self configureFilterImageView:image];
    
    BlockARCWeakSelf weakSelf = self;
    [self.currentFilterImageView fadeInWithCompletion:^{
        BOOL reloadFilterTableView = (weakSelf.originalImage != image || weakSelf.originalImage != weakSelf.croppedImage);
        
        self.originalImage = image;
        self.croppedImage = self.originalImage;
        
        if(weakSelf.useForAvatar)
            [weakSelf didClickCropButton:weakSelf.cropButton];
        
        if(reloadFilterTableView)
            [weakSelf.filterViewController refreshWithImage:self.croppedImage];
        else
            [weakSelf.filterViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
    }];
}

- (void)changeCurrentFilterImageView {
    _currentFilterImageViewIndex = (_currentFilterImageViewIndex + 1) % 2;
    
    self.backupFilterImageView.alpha = 1;
    self.currentFilterImageView.alpha = 1;
    
    self.currentFilterImageView.hidden = NO;
    [self.currentFilterImageView initializeParameter];
    [self.currentFilterImageView setNeedsDisplay];
    
    [self.currentFilterImageView removeFromSuperview];
    [self.bgView insertSubview:self.currentFilterImageView aboveSubview:self.backupFilterImageView];
}

#pragma mark - Properties

- (CGFloat)filterImageViewContentScaleFactor {
    CGFloat widthScale = self.currentFilterImageView.bounds.size.width / self.croppedImage.size.width;
    CGFloat heightScale = self.currentFilterImageView.bounds.size.height / self.croppedImage.size.height;
    return MAX(widthScale, heightScale);
}

- (BOOL)isDirty {
    BOOL result = NO;
    if(self.isShadowAmountFilterAdded)
        result = YES;
    else if(self.currentFilterInfo)
        result = YES;
    else if(self.croppedImage != self.originalImage)
        result = YES;
    return result;
}

- (BOOL)isShadowAmountFilterAdded {
    return self.currentShadowAmountValue != 0;
}

- (FilterImageView *)currentFilterImageView {
    if(_currentFilterImageViewIndex == 0) {
        return self.filterImageViewA;
    } else {
        return self.filterImageViewB;
    }
}

- (FilterImageView *)backupFilterImageView {
    if(_currentFilterImageViewIndex == 1) {
        return self.filterImageViewA;
    } else {
        return self.filterImageViewB;
    }
}

- (MotionsFilterTableViewController *)filterViewController {
    if(!_filterViewController) {
        _filterViewController = [[MotionsFilterTableViewController alloc] initWithImage:self.originalImage];
        _filterViewController.delegate = self;
        [self.subViewControllers addObject:_filterViewController];
    }
    return _filterViewController;
}

- (UIImage *)filteredImage {
    UIImage *result = nil;
    
    if(self.isShadowAmountFilterAdded && self.currentFilterInfo) {
        CIImage *source = [CIImage imageWithCGImage:self.croppedImage.CGImage];
        CIImage *filteredImage = [self.currentFilterInfo processCIImage:source];
        result = [UIImage shadowAmount:self.currentShadowAmountValue withCIImage:filteredImage];
    } else if(self.currentFilterInfo) {
        result = [self.currentFilterInfo processUIImage:self.croppedImage];
    } else if(self.shadowAmountFilterAdded) {
        result = [self.croppedImage shadowAmount:self.currentShadowAmountValue];
    } else {
        result = self.croppedImage;
    }
    
    return result;
}

#pragma mark - Animations

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
    
    BlockARCWeakSelf weakSelf = self;
    [self.cropImageViewController zoomOutToCenter:self.currentFilterImageView.center withScaleFactor:self.filterImageViewContentScaleFactor completion:^{
        [weakSelf.cropImageViewController.view removeFromSuperview];
        weakSelf.cropImageViewController = nil;
        weakSelf.cropButton.userInteractionEnabled = YES;
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
    BOOL filterImageViewEmpty = !self.currentFilterImageView.processImage;
    
    UIImage *filterImage = [image imageCroppedToFitSize:self.currentFilterImageView.frame.size];
    
    [self.currentFilterImageView setImage:filterImage];
    self.currentFilterImageView.shadowAmountValue = self.currentShadowAmountValue;
    self.currentFilterImageView.filterInfo = self.currentFilterInfo;
    
    [self.currentFilterImageView setNeedsDisplay];
    
    if(filterImageViewEmpty)
        [self.currentFilterImageView fadeIn];
    
    [self.delegate performSelector:@selector(editViewControllerDidBecomeActiveWithCompletion:) withObject:nil afterDelay:0.3f];
    
    if(_shouldShowCropView) {
        [self performSelector:@selector(didClickCropButton:) withObject:self.cropButton afterDelay:0.3f];
    }
    _shouldShowCropView = NO;
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
}

#pragma mark - IBActions

- (IBAction)didChangeSlider:(UISlider *)sender {
    self.currentShadowAmountValue = -1 * sender.value;
    self.currentFilterImageView.shadowAmountValue = self.currentShadowAmountValue;
    [self.currentFilterImageView setNeedsDisplay];
}

- (IBAction)didClickCropButton:(UIButton *)sender {
    BOOL select = !sender.selected;
    sender.selected = select;
    if(select) {
        [self semiTransparentEditViewForCropAnimation];
        [self.activityIndicator fadeIn];
        [self.activityIndicator startAnimating];
        
        BlockARCWeakSelf weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *filteredImage = self.filteredImage;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.cropImageViewController = [[CropImageViewController alloc] initWithImage:weakSelf.croppedImage filteredImage:filteredImage useForAvatar:_useForAvatar];
                weakSelf.cropImageViewController.delegate = weakSelf;
                weakSelf.cropImageViewController.view.frame = weakSelf.currentFilterImageView.frame;
                
                [weakSelf.bgView insertSubview:weakSelf.cropImageViewController.view aboveSubview:weakSelf.capturedImageEditBar];
                
                weakSelf.cropButton.userInteractionEnabled = NO;
                [weakSelf.cropImageViewController zoomInFromCenter:weakSelf.currentFilterImageView.center withScaleFactor:weakSelf.filterImageViewContentScaleFactor completion:^{
                    weakSelf.cropButton.userInteractionEnabled = YES;
                    
                    [weakSelf.activityIndicator fadeOutWithCompletion:^{
                        [weakSelf.activityIndicator stopAnimating];
                    }];
                }];
                
                [weakSelf.cropImageViewController.editBarView fadeIn];
                [weakSelf.capturedImageEditBar fadeOut];
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
    
    [self refreshViewWithImage:self.originalImage];
}

- (IBAction)didClickFinishEditButton:(UIButton *)sender {
    [self.activityIndicator fadeIn];
    [self.activityIndicator startAnimating];
    
    BlockARCWeakSelf weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *filteredImage = weakSelf.filteredImage;
        if(weakSelf.useForAvatar)
            filteredImage = [filteredImage compressImageToSize:CGSizeMake(180, 180)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate editViewControllerDidFinishEditImage:filteredImage];
        });
    });
}

#pragma mark - CropImageViewController delegate

- (void)cropImageViewControllerDidFinishCrop:(UIImage *)image {
    self.croppedImage = image;
    [self configureFilterImageView:image];
    [self hideCropImageViewControllerAnimation];
    
    CGPoint filterTableViewContentOffset = self.filterViewController.tableView.contentOffset;
    [self.filterViewController refreshWithImage:self.croppedImage];
    self.filterViewController.tableView.contentOffset = filterTableViewContentOffset;
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
    
    BlockARCWeakSelf weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *rotatedImage = [image motionsAdjustImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf refreshViewWithImage:rotatedImage];
        });
    });
}

#pragma mark - UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popoverController = nil;
}

#pragma mark - MotionsFilterTableViewController delegate

- (void)filterTableViewController:(MotionsFilterTableViewController *)vc didSelectFilter:(MotionsFilterInfo *)info {
    if([self.currentFilterInfo.filterName isEqualToString:info.filterName])
        return;
    
    self.currentFilterInfo = info;
    
    self.backupFilterImageView.processImage = self.currentFilterImageView.processImage;
    self.backupFilterImageView.filterInfo = info;
    
    [self changeCurrentFilterImageView];
    
    BlockARCWeakSelf weakSelf = self;
    [self.currentFilterImageView fadeInWithCompletion:^{
        self.backupFilterImageView.hidden = YES;
        [weakSelf resetSliders];
    }];
}

@end
