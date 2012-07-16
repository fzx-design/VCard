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
#import "UIView+Resize.h"
#import "UIView+Addition.h"

#define kDrawerFrame CGRectMake(-7.0, -12.0, 148.0, 144.0)
#define kEmptyDrawerFrame CGRectMake(-7, 59, 150, 74)
#define kTopicPaperFrame CGRectMake(-12, 25, 160, 104)

#define kTopicLabelFrame CGRectMake(20, 55.0, 95.0, 35.0)
#define kDrawerLabelFrame CGRectMake(20, 76.0, 95.0, 35.0)

#define kHighlishGlowFrame CGRectMake(-27.0, -20.0, 190.0, 130.0)

#define kDeleteDrawerButtonFrame CGRectMake(-25, -25, 80.0, 80.0)
#define kDeleteTopicButtonFrame  CGRectMake(-30, -10, 80.0, 80.0)

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
        _editing = NO;
        
        self.opaque = YES;
        self.enabled = !empty;
        [self setUpDrawerImageViewWithType:type empty:empty];
        [self setTopicLabelWithType:type];
        [self loadImageFromURL:url completion:nil];
        [self addTarget:self action:@selector(showHighlightGlow) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(showHighlightGlow) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchDragExit];
    }
    return self;
}

- (void)setUpDrawerImageViewWithType:(int)type empty:(BOOL)empty
{
    CGRect frame = self.bounds;
    frame.origin.x += 20;
    frame.origin.y += 20;
    frame.size.width -= 10;
    frame.size.height -= 10;
    
    _photoImageView = [[UIImageView alloc] initWithFrame:frame];
    _photoImageView.hidden = empty || type == kGroupTypeTopic;
    
    _backImageView = [[UIImageView alloc] initWithFrame:frame];
    _backImageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
    _backImageView.hidden = _photoImageView.hidden;
    
    _highlightGlowImageView = [[UIImageView alloc] initWithFrame:kHighlishGlowFrame];
    _highlightGlowImageView.image = [UIImage imageNamed:@"shelf_cell_glow"];
    _highlightGlowImageView.alpha = 0.0;
    
    NSString *imageName = @"shelf_drawer.png";

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
    
    frame = type == kGroupTypeTopic ? kDeleteTopicButtonFrame : kDeleteDrawerButtonFrame;
    
    _deleteButton = [[UIButton alloc] initWithFrame:frame];
    [_deleteButton setImage:[UIImage imageNamed:@"button_delete_black.png"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(didClickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.hidden = YES;
    
    [self addSubview:_backImageView];
    [self addSubview:_photoImageView];
    [self addSubview:_photoFrameImageView];
    [self addSubview:_highlightGlowImageView];
    [self addSubview:_deleteButton];
}

- (void)setTopicLabelWithType:(int)type
{
    CGFloat textColorFactor = type == 2 ? 88.0 / 255.0 : 0.0;
    CGFloat textShadowAlphaFactor = type == 2 ? 0.6 : 1.0;
    
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
    _topicLabel.minimumFontSize = 12.0
    ;
    _topicLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _topicLabel.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:textShadowAlphaFactor];
    _topicLabel.textColor = [UIColor colorWithRed:textColorFactor green:textColorFactor blue:textColorFactor alpha:1.0];
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

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        [self showHighlightGlow];
    } else {
        [self hideHighlightGlow];
    }
}

- (void)showHighlightGlow
{
    if (_editing) {
        return;
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        _highlightGlowImageView.alpha = 1.0;
    }];
}

- (void)hideHighlightGlow
{
    if (_editing) {
        return;
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        _highlightGlowImageView.alpha = 0.0;
    }];
}

- (void)didClickDeleteButton
{
    if ([_delegate respondsToSelector:@selector(didClickDeleteButtonAtIndex:)]) {
        [_delegate didClickDeleteButtonAtIndex:_index];
    }
}

- (void)showDeleteButton
{
    _deleteButton.hidden = NO;
    [_deleteButton fadeIn];
}

- (void)hideDeleteButton
{
    [_deleteButton fadeOutWithCompletion:^{
        _deleteButton.hidden = YES;
    }];
}

@end
