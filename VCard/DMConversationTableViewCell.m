//
//  DMConversationTableViewCell.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DMConversationTableViewCell.h"
#import "UIView+Resize.h"

#define kReceivedOriginX    40.0
#define kSentOriginX        90.0

@implementation DMConversationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)resetWithText:(NSString *)text dateString:(NSString *)dateString type:(DMBubbleViewType)type imageURL:(NSString *)imageURL
{
    CGFloat originX = 0.0;
    if (type == DMBubbleViewTypeSent) {
        _userAvatarImageView.hidden = YES;
        _userAvatarCoverImageView.hidden = YES;
        originX = kSentOriginX;
    } else {
        _userAvatarImageView.hidden = NO;
        _userAvatarCoverImageView.hidden = NO;
        [_userAvatarImageView loadImageFromURL:imageURL completion:nil];
        originX = kReceivedOriginX;
    }
    [_bubbleView resetWithText:text dateString:dateString type:type];
    [_bubbleView resetOriginX:originX];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        [_bubbleView showHighlight];
    } else {
        [_bubbleView hideHighlight];
    }
}

- (void)setUp
{
    _bubbleView.pageIndex = self.pageIndex;
    _bubbleView.delegate = self;
}

- (void)shouldDeleteBubble
{
    if ([self.delegate respondsToSelector:@selector(shouldDeleteMessageAtIndex:)]) {
        [self.delegate shouldDeleteMessageAtIndex:self.index];
    }
}

@end
