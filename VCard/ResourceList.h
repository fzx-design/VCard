//
//  ResourceList.h
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#ifndef VCard_ResourceList_h
#define VCard_ResourceList_h

#define kRLTopBarBG @"main_bar_bg.png"
#define kRLTopBarShadow @"main_bar_shadow.png"
#define kRLCastViewBGUnit @"castview_bg_unit.png"
#define kRLStackViewBGUnit @"side_bg.png"
#define kRLStackViewSideShadow @"stackview_pre_shadow_cover.png"

#define kRLAvatarPlaceHolderBG @"imageview_placeholder.png"
#define kRLAvatarPlaceHolder @"avatar_placeholder.png"
#define kRLProfileAvatarFrame @"profile_avatar_frame.png"

#define kRLCardBGUnit @"card_bg_body.png"
#define kRLCardTop @"card_bg_top.png"
#define kRLCardBottom @"card_bg_bottom.png"

#define kRLCardImageShadowTop @"image_shadow_top.png"
#define kRLCardImageShadowCenter @"image_shadow_body.png"
#define kRLCardImageShadowBottom @"image_shadow_btm.png"

#define kRLRefreshButtonCircle @"menu_reload_indicator.png"
#define kRLRefreshButtonHole @"menu_reload_bg.png"
#define kRLStackTableViewShadow  @"stack_tableview_shadow.png"

#define kRLIconVerifiedAssociationSmall @"verified_association_small.png"
#define kRLIconVerifiedAssociationBig @"verified_association_large.png"
#define kRLIconVerifiedPersonSmall @"verified_person_small.png"
#define kRLIconVerifiedPersionBig @"verified_person_large.png"
#define kRLIconVerifiedTalentSmall @"verified_talent_small.png"
#define kRLIconVerifiedTalentBig @"verified_talent_large.png"

#define kRLIconMale @"icon_male.png"
#define kRLIconFemale @"icon_female.png"

#define kRLIconGif @"icon_gif.png"

#define kNotificationNameOrientationWillChange @"kNotificationNameOrientationWillChange"
#define kNotificationNameOrientationChanged @"kNotificationNameOrientationChanged"
#define kNotificationNameShouldDisableWaterflowScroll @"kNotificationNameShouldDisableWaterflowScroll"
#define kNotificationNameShouldEnableWaterflowScroll @"kNotificationNameShouldEnableWaterflowScroll"
#define kNotificationNameAddNewStackPage @"kNotificationNameAddNewStackPage"
#define kNotificationNameUserNameClicked @"kNotificationNameUserNameClicked"
#define kNotificationNameUserCellClicked @"kNotificationNameUserCellClicked"
#define kNotificationNameShouldSaveContext @"kNotificationNameShouldSaveContext"

#define kNotificationCommentButtonClicked @"kNotificationCommentButtonClicked"

#define kNotificationNameStackViewCoveredWholeScreen @"kNotificationNameStackViewCoveredWholeScreen"
#define kNotificationNameStackViewDoNotCoverWholeScreen @"kNotificationNameStackViewDoNotCoverWholeScreen"

#define kNotificationObjectKeyUser @"kNotificationObjectKeyUser"
#define kNotificationObjectKeyIndex @"kNotificationObjectKeyIndex"
#define kNotificationObjectKeyUserName @"kNotificationObjectKeyUserName"
#define kNotificationObjectKeyStatus @"kNotificationObjectKeyStatus"

#define kOrientationPortrait @"kOrientationPortrait"
#define kOrientationLandscape @"kOrientationLandscape"

typedef enum {
    VerifiedTypeNone,
    VerifiedTypePerson,
    VerifiedTypeAssociation,
    VerifiedTypeTalent,
} VerifiedType;

#endif
