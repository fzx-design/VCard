//
//  MotionsFilterCell.h
//  WeTongji
//
//  Created by 紫川 王 on 12-5-10.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionsFilterReader.h"

@interface MotionsFilterCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)loadThumbnailImage:(UIImage *)image
            withFilterInfo:(MotionsFilterInfo *)info
                completion:(void (^)(void))completion;

- (void)setThumbnailImage:(UIImage *)image;

@end
 