//
//  ShelfDrawerView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ShelfDrawerView.h"
#import "UIImageView+URL.h"

#define kPhotoFrameFrame CGRectMake(-27.0, -32.0, 148.0, 144.0)
#define kTopicLabelFrame CGRectMake(0, 55.0, 95.0, 35.0)

@implementation ShelfDrawerView

- (id)initWithFrame:(CGRect)frame
          topicName:(NSString *)name
             picURL:(NSString *)url
              index:(NSInteger)index
               type:(int)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _topicName = name;
        _index = index;
        _picURL = url;
        _type = type;
        _imageLoaded = url && ![url isEqualToString:@""];
        
        self.opaque = YES;
        [self setUpDrawerImageView];
        [self setTopicLabel];
        [self loadImageFromURL:url completion:nil];
    }
    return self;
}

- (void)setUpDrawerImageView
{
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    
    _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backImageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
    
    _photoFrameImageView = [[UIImageView alloc] initWithFrame:kPhotoFrameFrame];
    NSString *imageName = @"shelf_drawer.png";
    if (_type == 0) {
        imageName = @"shelf_drawer_favorites.png";
    }
    _photoFrameImageView.image = [UIImage imageNamed:imageName];
    _photoFrameImageView.opaque = YES;
    
    [self addSubview:_backImageView];
    [self addSubview:_imageView];
    [self addSubview:_photoFrameImageView];
}

- (void)setTopicLabel
{
    _topicLabel = [[UILabel alloc] initWithFrame:kTopicLabelFrame];
    if (_type == 2) {
        _topicLabel.text = [NSString stringWithFormat:@"#%@#", _topicName];
    } else {
        _topicLabel.text = [NSString stringWithFormat:@"%@", _topicName];
    }
    _topicLabel.textAlignment = UITextAlignmentCenter;
    _topicLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _topicLabel.shadowColor = [UIColor whiteColor];
    _topicLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    _topicLabel.backgroundColor = [UIColor clearColor];
    _topicLabel.minimumFontSize = 12.0;
    _topicLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_topicLabel];
}

- (void)loadImageFromURL:(NSString *)urlString
              completion:(void (^)(BOOL succeeded))completion
{
    _imageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
	
    [_imageView kv_cancelImageDownload];
    NSURL *anImageURL = [NSURL URLWithString:urlString];
    [_imageView kv_setImageAtURLWithoutCropping:anImageURL completion:completion];
}

@end
