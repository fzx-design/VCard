//
//  ShelfDrawerView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ShelfDrawerView.h"
#import "Group.h"
#import "UIView+Resize.h"
#import "UIView+Addition.h"
#import "UIImageView+Addition.h"

#define kDrawerFrame CGRectMake(-7.0, -12.0, 148.0, 144.0)
#define kEmptyDrawerFrame CGRectMake(-7, 59, 150, 74)
#define kTopicPaperFrame CGRectMake(-12, 25, 160, 104)

#define kTopicLabelFrame CGRectMake(20, 55.0, 95.0, 35.0)
#define kDrawerLabelFrame CGRectMake(20, 76.0, 95.0, 35.0)

#define kHighlishGlowFrame CGRectMake(-27.0, -20.0, 190.0, 130.0)

#define kDeleteDrawerButtonFrame CGRectMake(-5, -5, 44.0, 44.0)
#define kDeleteTopicButtonFrame  CGRectMake(-10, 10, 44.0, 44.0)

@interface ShelfDrawerView ()

@property (nonatomic, strong) UIImageView   *photoFrameImageView;
@property (nonatomic, strong) UIImageView   *photoImageView;
@property (nonatomic, strong) UIImageView   *backImageView;
@property (nonatomic, strong) UIImageView   *highlightGlowImageView;
@property (nonatomic, strong) UILabel       *topicLabel;
@property (nonatomic, strong) UIButton      *deleteButton;

@end

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
        _empty = empty;
        
        self.opaque = YES;
        self.enabled = !empty;
        [self setUpDrawerImageViewWithType:type empty:empty];
        [self setTopicLabelWithType:type];
        [self loadImageFromURL:url completion:nil];
        
        [self addTarget:self action:@selector(showHighlightGlow) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(showHighlightGlow) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(hideHighlightGlow) forControlEvents:UIControlEventTouchUpOutside];
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
    _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _backImageView = [[UIImageView alloc] initWithFrame:frame];
    _backImageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
    _backImageView.hidden = _photoImageView.hidden;
    
    _highlightGlowImageView = [[UIImageView alloc] initWithFrame:kHighlishGlowFrame];
    _highlightGlowImageView.image = [UIImage imageNamed:@"shelf_cell_glow"];
    _highlightGlowImageView.alpha = 0.0;
    
    NSString *imageName = @"shelf_drawer.png";

    if (_type == kGroupTypeFavourite) {
        imageName = @"shelf_drawer_favorites.png";
        frame = kDrawerFrame;
    } else if (_type == kGroupTypeDefault || _type == kGroupTypeGroup) {
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
    
    [self addSubview:_backImageView];
    [self addSubview:_photoImageView];
    [self addSubview:_photoFrameImageView];
    [self addSubview:_highlightGlowImageView];
    
    if (type != kGroupTypeFavourite && _index != 0) {
        _deleteButton = [[UIButton alloc] initWithFrame:frame];
        [_deleteButton setImage:[UIImage imageNamed:@"button_delete_black.png"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(didClickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hidden = YES;
        [self addSubview:_deleteButton];
    }
}

- (void)setTopicLabelWithType:(int)type
{
    CGFloat textColorFactor = type == kGroupTypeTopic ? 88.0 / 255.0 : 0.0;
    CGFloat textShadowAlphaFactor = type == kGroupTypeTopic ? 0.6 : 1.0;
    
    CGRect frame;
    if (_type == kGroupTypeTopic) {
        frame = kTopicLabelFrame;
    } else {
        frame = kDrawerLabelFrame;
    }
    _topicLabel = [[UILabel alloc] initWithFrame:frame];
    _topicLabel.text = _topicName;
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
	
    [_photoImageView loadImageFromURL:urlString completion:completion];
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
    if (self.editing) {
        return;
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        self.highlightGlowImageView.alpha = 1.0;
    }];
}

- (void)hideHighlightGlow
{
    if (self.editing) {
        return;
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        self.highlightGlowImageView.alpha = 0.0;
    }];
}

- (void)didClickDeleteButton
{
    NSString *deleteTitle = _type == kGroupTypeTopic ? @"取消关注" : @"删除";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self 
                                                    cancelButtonTitle:nil 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:deleteTitle, nil];
    actionSheet.destructiveButtonIndex = 0;
    actionSheet.delegate = self;
    CGRect frame = _deleteButton.frame;
    
    if (_type == kGroupTypeTopic) {
        frame.origin.y -= 15;
        frame.origin.x += 10;
    } else {
        frame.origin.x += 5;
    }
    [actionSheet showFromRect:frame inView:_deleteButton animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self didConfirmDelete];
    }
}

- (void)didConfirmDelete
{
    if ([self.delegate respondsToSelector:@selector(didClickDeleteButtonAtIndex:)]) {
        [self.delegate didClickDeleteButtonAtIndex:self.index];
    }
}

- (void)showDeleteButton
{
    self.deleteButton.hidden = NO;
    [self.deleteButton fadeIn];
    if (self.empty) {
        self.enabled = YES;
    }
}

- (void)hideDeleteButton
{
    BlockARCWeakSelf weakSelf = self;
    [self.deleteButton fadeOutWithCompletion:^{
        weakSelf.deleteButton.hidden = YES;
        if (weakSelf.empty) {
            weakSelf.enabled = NO;
        }
    }];
}

@end
