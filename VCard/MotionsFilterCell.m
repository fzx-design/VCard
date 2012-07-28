//
//  MotionsFilterCell.m
//  WeTongji
//
//  Created by 紫川 王 on 12-5-10.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "MotionsFilterCell.h"
#import "UIView+Addition.h"

@implementation MotionsFilterCell

@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize activityIndicator = _activityIndicator;
@synthesize iapIndicator = _iapIndicator;
@synthesize filterNameLabel = _filterNameLabel;

- (void)awakeFromNib {
    [self.activityIndicator startAnimating];
    self.filterNameLabel.shadowOffset = CGSizeMake(0, 1);
    self.filterNameLabel.shadowBlur = 3.0f;
    self.filterNameLabel.shadowColor = [UIColor blackColor];
}

- (void)setThumbnailImage:(UIImage *)image {
    if(image) {
        self.thumbnailImageView.image = image;
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
    }
}

- (void)loadThumbnailImage:(UIImage *)image
            withFilterInfo:(MotionsFilterInfo *)info
                completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *filteredImage = [info processUIImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setThumbnailImage:filteredImage];
            [self.thumbnailImageView fadeIn];
            if(completion)
                completion();
        });  
    });
}

@end
