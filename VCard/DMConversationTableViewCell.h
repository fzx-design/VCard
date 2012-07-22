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

@interface DMConversationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet DMBubbleView           *bubbleView;
@property (nonatomic, weak) IBOutlet UserAvatarImageView    *userAvatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView            *userAvatarCoverImageView;

- (void)resetWithText:(NSString *)text dateString:(NSString *)dateString type:(DMBubbleViewType)type imageURL:(NSString *)imageURL;

@end
