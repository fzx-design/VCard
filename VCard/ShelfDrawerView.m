//
//  ShelfDrawerView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ShelfDrawerView.h"
#import "UIImageView+URL.h"
#import "Group.h"

#define kDrawerFrame CGRectMake(-27.0, -32.0, 148.0, 144.0)
#define kEmptyDrawerFrame CGRectMake(-27, 39, 150, 74)
#define kTopicPaperFrame CGRectMake(-32, 5, 160, 104)

#define kTopicLabelFrame CGRectMake(0, 35.0, 95.0, 35.0)
#define kDrawerLabelFrame CGRectMake(0, 56.0, 95.0, 35.0)

#define kHighlishGlowFrame CGRectMake(-47.0, -40.0, 190.0, 130.0)

@implementation ShelfDrawerView

- (id)initWithFrame:(CGRect)frame
          topicName:(NSString *)name
             picURL:(NSString *)url
              index:(NSInteger)index
               type:(int)type
              empty:(BOOL)empty

{
    self = [super initWithFrame:frame];
    if (self) {
        _topicName = name;
        _index = index;
        _picURL = url;
        _type = type;
        _imageLoaded = url && ![url isEqualToString:@""];
        
        self.opaque = YES;
        [self setUpDrawerImageViewWithType:type empty:empty];
        [self setTopicLabel];
        [self loadImageFromURL:url completion:nil];
        [self addTarget:self action:@selector(showHighlightGlow) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(showHighlightGlow) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setUpDrawerImageViewWithType:(int)type empty:(BOOL)empty
{
    _photoImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _photoImageView.hidden = empty || type == kGroupTypeTopic;
    
    _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backImageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
    _backImageView.hidden = _photoImageView.hidden;
    
    _highlightGlowImageView = [[UIImageView alloc] initWithFrame:kHighlishGlowFrame];
    _highlightGlowImageView.image = [UIImage imageNamed:@"shelf_cell_glow"];
    _highlightGlowImageView.alpha = 0.0;
    
    
    NSString *imageName = @"shelf_drawer.png";
    CGRect frame;
    if (_type == 0) {
        imageName = @"shelf_drawer_favorites.png";
        frame = kDrawerFrame;
    } else if (_type == 1) {
        imageName = empty ? @"shelf_drawer_empty.png" : @"shelf_drawer.png";
        frame = empty ? kEmptyDrawerFrame : kDrawerFrame;
    } else {
        imageName = @"topic_paper.png";
        frame = kTopicPaperFrame;
    }
    _photoFrameImageView = [[UIImageView alloc] initWithFrame:frame];
    _photoFrameImageView.image = [UIImage imageNamed:imageName];
    _photoFrameImageView.opaque = YES;
    
    [self addSubview:_backImageView];
    [self addSubview:_photoImageView];
    [self addSubview:_photoFrameImageView];
    [self addSubview:_highlightGlowImageView];
}

- (void)setTopicLabel
{
    CGRect frame;
    NSString *title;
    if (_type == kGroupTypeTopic) {
        frame = kTopicLabelFrame;
        title = [NSString stringWithFormat:@"#%@#", _topicName];
    } else {
        frame = kDrawerLabelFrame;
        title = [NSString stringWithFormat:@"%@", _topicName];
    }
    _topicLabel = [[UILabel alloc] initWithFrame:frame];
    _topicLabel.text = title;
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
    if (_photoImageView.hidden) {
        return;
    }
	
    [_photoImageView kv_cancelImageDownload];
    NSURL *anImageURL = [NSURL URLWithString:urlString];
    [_photoImageView kv_setImageAtURLWithoutCropping:anImageURL completion:completion];
}

- (void)showHighlightGlow
{
    [UIView animateWithDuration:0.15 animations:^{
        _highlightGlowImageView.alpha = 1.0;
    }];
}

- (void)hideHighlightGlow
{
    [UIView animateWithDuration:0.15 animations:^{
        _highlightGlowImageView.alpha = 0.0;
    }];
}

@end
