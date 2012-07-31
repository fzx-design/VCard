//
//  TTTAttributedLabelConfiguer.h
//  VCard
//
//  Created by 海山 叶 on 12-7-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CardViewController;
@class TTTAttributedLabel;

@interface TTTAttributedLabelConfiguer : NSObject

+ (void)setCardViewController:(CardViewController *)vc StatusTextLabel:(TTTAttributedLabel*)label withText:(NSString*)string;
+ (void)setMessageTextLabel:(TTTAttributedLabel *)label withText:(NSString *)string leading:(CGFloat)leading fontSize:(CGFloat)fontSize isReceived:(BOOL)isReceived;
+ (NSString *)replaceEmotionStrings:(NSString *)text;
+ (CGFloat)heightForCellWithText:(NSString *)text;

@end
