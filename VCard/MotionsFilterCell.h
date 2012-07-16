//
//  MotionsFilterCell.h
//  WeTongji
//
//  Created by 紫川 王 on 12-5-10.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionsFilterReader.h"
#import "FXLabel.h"

@interface MotionsFilterCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *iapIndicator;
@property (nonatomic, weak) IBOutlet FXLabel *filterNameLabel;

- (void)loadThumbnailImage:(UIImage *)image
            withFilterInfo:(MotionsFilterInfo *)info
                completion:(void (^)(void))completion;

- (void)setThumbnailImage:(UIImage *)image;

@end
 