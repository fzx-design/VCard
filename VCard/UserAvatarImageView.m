//
//  UserAvatarImageView.m
//  VCard
//
//  Created by 海山 叶 on 12-5-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserAvatarImageView.h"

#define IconBigFrame CGRectMake(100.0, 100.0, 27.0, 27.0)
#define IconSmallFrame CGRectMake(17.0, 17.0, 13.0, 14.0)

@implementation UserAvatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpVIPImageView];
    }
    return self;
}

- (void)setUpVIPImageView
{
    if ([self isBigAvatar]) {
        _vipImageView = [[UIImageView alloc] initWithFrame:IconBigFrame];
        
    } else {
        _vipImageView = [[UIImageView alloc] initWithFrame:IconSmallFrame];
    }
    
    [self addSubview:_vipImageView];
}

- (BOOL)isBigAvatar
{
    return self.frame.size.width > 50.0;
}

- (void)setVerifiedType:(VerifiedType)type
{
    switch (type) {
        case VerifiedTypeNone:
            _vipImageView.hidden = YES;
            break;
        case VerifiedTypePerson:
            _vipImageView.hidden = NO;
            _vipImageView.image = [self isBigAvatar] ? [UIImage imageNamed:kRLIconVerifiedPersionBig] : [UIImage imageNamed:kRLIconVerifiedPersonSmall];
            break;
        case VerifiedTypeAssociation:
            _vipImageView.hidden = NO;
            _vipImageView.image = [self isBigAvatar] ? [UIImage imageNamed:kRLIconVerifiedAssociationBig] : [UIImage imageNamed:kRLIconVerifiedAssociationSmall];
            break;
        case VerifiedTypeTalent:
            _vipImageView.hidden = NO;
            _vipImageView.image = [self isBigAvatar] ? [UIImage imageNamed:kRLIconVerifiedTalentBig] : [UIImage imageNamed:kRLIconVerifiedTalentSmall];
            
        default:
            break;
    }
}

@end
