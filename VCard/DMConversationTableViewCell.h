//
//  DMConversationTableViewCell.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMBubbleView.h"
#import "UserAvatarImageView.h"

@protocol DMConversationTableViewCellDelegate <NSObject>
@required
- (void)shouldDeleteMessageAtIndex:(int)index;

@end

@interface DMConversationTableViewCell : UITableViewCell <DMBubbleViewDelegate>

@property (nonatomic, weak) IBOutlet DMBubbleView           *bubbleView;
@property (nonatomic, weak) IBOutlet UserAvatarImageView    *userAvatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView            *userAvatarCoverImageView;
@property (nonatomic, unsafe_unretained) NSInteger          index;
@property (nonatomic, unsafe_unretained) NSInteger          pageIndex;
@property (nonatomic, weak) id<DMConversationTableViewCellDelegate> delegate;

- (void)resetWithText:(NSString *)text dateString:(NSString *)dateString type:(DMBubbleViewType)type imageURL:(NSString *)imageURL;
- (void)setUp;

@end
