//
//  TTTAttributedLabelConfiguer.m
//  VCard
//
//  Created by 海山 叶 on 12-7-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "TTTAttributedLabelConfiguer.h"
#import "CardViewController.h"
#import "NSUserDefaults+Addition.h"
#import "EmoticonsInfoReader.h"
#import "TTTAttributedLabel.h"

#define kReceivedBubbleTextColor    [UIColor colorWithRed:42.0/255 green:42.0/255 blue:42.0/255 alpha:1.0]
#define kSentBubbleTextColor        [UIColor colorWithRed:0.0/255 green:76.0/255 blue:96.0/255 alpha:1.0]
#define RegexColor [[UIColor colorWithRed:161.0/255 green:161.0/255 blue:161.0/255 alpha:1.0] CGColor]

static NSRegularExpression *__nameRegularExpression;
static inline NSRegularExpression * NameRegularExpression() {
    if (!__nameRegularExpression) {
        __nameRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"@[[a-z][A-Z][0-9][\\u4E00-\\u9FA5]-_]*" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return __nameRegularExpression;
}

static NSRegularExpression *__tagRegularExpression;
static inline NSRegularExpression * TagRegularExpression() {
    if (!__tagRegularExpression) {
        __tagRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"#.+?\\[{0}?#" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return __tagRegularExpression;
}

static NSRegularExpression *__urlRegularExpression;
static inline NSRegularExpression * UrlRegularExpression() {
    if (!__urlRegularExpression) {
        __urlRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"https?://[[a-z][A-Z][0-9]\?/%&=.]+" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return __urlRegularExpression;
}

static NSRegularExpression *__emotionRegularExpression;
static inline NSRegularExpression * EmotionRegularExpression() {
    if (!__emotionRegularExpression) {
        __emotionRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\[[[\\u4E00-\\u9FA5][a-z]]*\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return __emotionRegularExpression;
}

static NSRegularExpression *__emotionIDRegularExpression;
static inline NSRegularExpression * EmotionIDRegularExpression() {
    if (!__emotionIDRegularExpression) {
        __emotionIDRegularExpression = [[NSRegularExpression alloc] initWithPattern:@" \\[[[a-f][0-9] ]*\\] " options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return __emotionIDRegularExpression;
}

@implementation TTTAttributedLabelConfiguer

+ (CGFloat)heightForCellWithText:(NSString *)text {
    CGFloat height = 10.0f;
    CGFloat fontSize = [NSUserDefaults currentFontSize];
    height += ceilf([text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:MaxCardSize lineBreakMode:UILineBreakModeWordWrap].height);
    CGFloat singleLineHeight = ceilf([@"测试单行高度" sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:MaxCardSize lineBreakMode:UILineBreakModeWordWrap].height);
    
    height += ceilf(height / singleLineHeight * [NSUserDefaults currentLeading]);
    
    return height;
}

+ (void)setCardViewController:(CardViewController *)vc StatusTextLabel:(TTTAttributedLabel*)label withText:(NSString*)string
{
    CGRect frame = label.frame;
    frame.size.height = [TTTAttributedLabelConfiguer heightForCellWithText:string];
    label.frame = frame;
    
    label.font = [UIFont systemFontOfSize:[NSUserDefaults currentFontSize]];
    label.textColor = [UIColor colorWithRed:49.0/255 green:42.0/255 blue:37.0/255 alpha:1.0];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.leading = [NSUserDefaults currentLeading];
    
    label.highlightedTextColor = [UIColor whiteColor];
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    [self setCardViewController:vc SummaryText:string toLabel:label fontSize:[NSUserDefaults currentFontSize]];
}

+ (void)setMessageTextLabel:(TTTAttributedLabel *)label
                   withText:(NSString *)string
                    leading:(CGFloat)leading
                   fontSize:(CGFloat)fontSize
                 isReceived:(BOOL)isReceived
{
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = isReceived ? kReceivedBubbleTextColor : kSentBubbleTextColor;
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.leading = leading;
    label.highlightedTextColor = [UIColor whiteColor];
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    [self setCardViewController:nil SummaryText:string toLabel:label fontSize:fontSize];
}

+ (NSString *)replaceEmotionStrings:(NSString *)text
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSRange stringRange = NSMakeRange(0, [text length]);
    NSRegularExpression *regexp = EmotionRegularExpression();
    [regexp enumerateMatchesInString:text options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = result.range;
        if (range.length != 1) {
            NSString *string = [text substringWithRange:range];
            [array addObject:string];
        }
    }];
    
    for (NSString *ketString in array) {
        NSString *key = [ketString substringWithRange:NSMakeRange(1, ketString.length - 2)];
        EmoticonsInfo *info = [[EmoticonsInfoReader sharedReader] emoticonsInfoForKey:key];
        if (info) {
            NSString *string = [NSString stringWithFormat:@" %@ ", info.emoticonIdentifier];
            text = [text stringByReplacingOccurrencesOfString:ketString withString:string];
        }
    }
    
    return text;
}

+ (void)setCardViewController:(CardViewController *)vc SummaryText:(NSString *)text toLabel:(TTTAttributedLabel*)label fontSize:(CGFloat)fontSize
{
    NSRange stringRange = NSMakeRange(0, [text length]);
    
    [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
        
        NSRegularExpression *regexp = NameRegularExpression();
        
        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [TTTAttributedLabelConfiguer configureFontForAttributedString:mutableAttributedString withRange:result.range fontSize:fontSize];
        }];
        
        regexp = TagRegularExpression();
        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [TTTAttributedLabelConfiguer configureFontForAttributedString:mutableAttributedString withRange:result.range fontSize:fontSize];
        }];
        
        regexp = UrlRegularExpression();
        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [TTTAttributedLabelConfiguer configureFontForAttributedString:mutableAttributedString withRange:result.range fontSize:fontSize];
        }];
        
        regexp = EmotionIDRegularExpression();
        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [TTTAttributedLabelConfiguer configureEmotionsForAttributedString:mutableAttributedString withRange:result.range];
        }];
        
        return mutableAttributedString;
    }];

    NSRegularExpression * regexp = NameRegularExpression();
    [regexp enumerateMatchesInString:text options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = result.range;
        if (range.length != 1) {
            range.location++;
            range.length--;
            NSString *string = [text substringWithRange:range];
            [label addLinkToPhoneNumber:string withRange:result.range];
        }
    }];
    
    regexp = TagRegularExpression();
    [regexp enumerateMatchesInString:text options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = result.range;
        if (range.length != 1) {
            range.location++;
            range.length -= 2;
            NSString *string = [text substringWithRange:range];
            [label addQuoteToString:string withRange:result.range];
        }
    }];
    
    regexp = UrlRegularExpression();
    [regexp enumerateMatchesInString:text options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = result.range;
        if (range.length != 1) {
            NSString *string = [text substringWithRange:range];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", string]];
            [label addLinkToURL:url withRange:result.range];
            
            if (vc) {
                [vc recognizerLinkType:string];
            }
        }
    }];
    
    regexp = EmotionIDRegularExpression();
    [regexp enumerateMatchesInString:text options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = result.range;
        if (range.length != 1) {
            NSString *string = [text substringWithRange:range];
            EmoticonsInfo *info = [[EmoticonsInfoReader sharedReader] emoticonsInfoForIdentifier:string];
            if (info) {
                [label addEmotionToString:info.imageFileName withRange:range];
            }
        }
    }];
    
}

+ (void)configureFontForAttributedString:(NSMutableAttributedString *)mutableAttributedString withRange:(NSRange)stringRange fontSize:(CGFloat)fontSize
{
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    CTFontRef systemFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    if (systemFont) {
        [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:stringRange];
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)systemFont range:stringRange];
        
        [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:stringRange];
        [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)RegexColor range:stringRange];
        CFRelease(systemFont);
    }
}

+ (void)configureEmotionsForAttributedString:(NSMutableAttributedString *)mutableAttributedString withRange:(NSRange)stringRange
{
    UIFont *font = [UIFont boldSystemFontOfSize:8.0f];
    CTFontRef systemFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:stringRange];
    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)systemFont range:stringRange];
    CFRelease(systemFont);
}


@end
