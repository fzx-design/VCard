//
//  DMBubbleView.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

#define kMaxBubbleSize          CGSizeMake(256.0, 9999.0)
#define kMaxTextSize            CGSizeMake(250.0, 9999.0)

typedef enum {
    DMBubbleViewTypeReceived,
    DMBubbleViewTypeSent,
} DMBubbleViewType;

@interface DMBubbleView : UIView

@property (nonatomic, strong) UIImageView           *backgroundImageView;
@property (nonatomic, strong) UILabel               *timeStampLabel;
@property (nonatomic, strong) TTTAttributedLabel    *textLabel;
@property (nonatomic, readonly) DMBubbleViewType    type;

+ (CGSize)sizeForText:(NSString *)text;
- (void)resetWithText:(NSString *)text dateString:(NSString *)dateString type:(DMBubbleViewType)type;

@end
