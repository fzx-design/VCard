//
//  PostHintTextView.m
//  VCard
//
//  Created by 王 紫川 on 12-8-2.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostHintTextView.h"
#import "PostAtHintView.h"
#import "PostTopicHintView.h"

static NSString *weiboAtRegEx = @"[[a-z][A-Z][0-9][\\u4E00-\\u9FA5]-_\\s]*";
static NSString *weiboTopicRegEx = @"[[a-z][A-Z][0-9][\\u4E00-\\u9FA5]-_]*";

@interface PostHintTextView()

@end

@implementation PostHintTextView

#pragma mark - Properties

- (NSString *)currentHintString {
    return [self.text substringWithRange:self.currentHintStringRange];
}

- (BOOL)isAtHintStringValid {
    NSRange range = [self.currentHintString rangeOfString:weiboAtRegEx options:NSRegularExpressionSearch];
    return range.length == self.currentHintString.length;
}

- (BOOL)isTopicHintStringValid {
    return YES; // no limit
    NSRange range = [self.currentHintString rangeOfString:weiboTopicRegEx options:NSRegularExpressionSearch];
    return range.length == self.currentHintString.length;
}

#pragma mark - Logic methods

- (void)callDismissHintView {
    [self.hintDelegate postHintTextViewCallDismissHintView];
}

- (void)replaceHintWithResult:(NSString *)text fromHintView:(id)hintView {
    int location = self.currentHintStringRange.location;
    NSString *replaceText = text;
    if([hintView isMemberOfClass:[PostAtHintView class]]) {
        replaceText = [NSString stringWithFormat:@"%@ ", replaceText];
    } else if([hintView isMemberOfClass:[PostTopicHintView class]] && self.needFillPoundSign) {
        replaceText = [NSString stringWithFormat:@"%@#", replaceText];
    }
    
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:beginning offset:self.currentHintStringRange.location];
    UITextPosition *end = [self positionFromPosition:start offset:self.currentHintStringRange.length];
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    [self replaceRange:textRange withText:replaceText];
    
    NSRange range = NSMakeRange(location + replaceText.length, 0);
    if([hintView isMemberOfClass:[PostTopicHintView class]])
        range.location += 1;
    self.selectedRange = range;
    self.currentHintStringRange = range;
    if([hintView isKindOfClass:[PostHintView class]]) {
        [self callDismissHintView];
    }
    
    [self.delegate textViewDidChange:self];
}

- (void)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text currentHintView:(id)hintView {
    if(hintView) {
        if([hintView isMemberOfClass:[PostAtHintView class]] && [text isEqualToString:@" "]) {
            [self.hintDelegate postHintTextViewCallDismissHintView];
        }
    } else if([text isEqualToString:@"@"]) {
        self.currentHintStringRange = NSMakeRange(range.location + text.length - range.length, 0);
    } else if([text isEqualToString:@"#"]) {
        self.currentHintStringRange = NSMakeRange(range.location + text.length - range.length, 0);
        self.needFillPoundSign = YES;
    }
}

- (void)textViewDidChangeWithCurrentHintView:(id)hintView {
    if([hintView isKindOfClass:[PostHintView class]]) {
        NSInteger length = self.selectedRange.location - self.currentHintStringRange.location;
        if(length < 0)
            [self callDismissHintView];
        else {
            self.currentHintStringRange = NSMakeRange(self.currentHintStringRange.location, length);
        }
    } else if(hintView) {
        self.currentHintStringRange = NSMakeRange(self.selectedRange.location, 0);
    }
}

- (void)textViewDidChangeSelectionWithCurrentHintView:(id)hintView {
    if([hintView isKindOfClass:[PostHintView class]]) {
        if(self.selectedRange.location < self.currentHintStringRange.location
           || self.selectedRange.location > self.currentHintStringRange.location + self.currentHintStringRange.length) {
            [self callDismissHintView];
        }
    }
}

- (void)initAtHintView:(BOOL)present {
    if(present) {
        [self insertText:@"@"];
        NSInteger location = self.selectedRange.location;
        NSRange range = NSMakeRange(location, 0);
        self.currentHintStringRange = range;
    }
}

- (void)initTopicHintView:(BOOL)present {
    if(present) {
        [self insertText:@"##"];
        NSInteger location = self.selectedRange.location;
        NSRange range = NSMakeRange(location - 1, 0);
        self.currentHintStringRange = range;
        self.selectedRange = range;
    } else {
        if(!self.needFillPoundSign)
            self.selectedRange = NSMakeRange(self.selectedRange.location + 1, 0);
    }
}

#pragma mark - PostHintView delegate

- (void)postHintView:(PostHintView *)hintView didSelectHintString:(NSString *)text {
    [self replaceHintWithResult:text fromHintView:hintView];
}

#pragma mark - EmoticonsViewController delegate

- (void)didClickEmoticonsButtonWithInfoKey:(NSString *)key {
    [self replaceHintWithResult:key fromHintView:nil];
}

@end
