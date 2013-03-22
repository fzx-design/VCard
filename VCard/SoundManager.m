//
//  SoundManager.m
//  VCard
//
//  Created by 王 紫川 on 12-7-23.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SoundManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NSUserDefaults+Addition.h"

static SoundManager *soundManagerInstance;

@interface SoundManager() {
    SystemSoundID _newMessageSoundID;
    SystemSoundID _reloadSoundID;
}

@end

@implementation SoundManager

+ (id)sharedManager {
    if (!soundManagerInstance) {
        soundManagerInstance = [[SoundManager alloc] init];
    }
    if ([NSUserDefaults isSoundEffectEnabled])
        return soundManagerInstance;
    else
        return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self loadSoundResource];
    }
    return self;
}

- (void)loadSoundResource {
    NSString* newMessageSoundPath = [[NSBundle mainBundle] pathForResource:@"sound_new_message" ofType:@"wav"];
    if (newMessageSoundPath) {
        NSURL* newMessageSoundUrl = [NSURL fileURLWithPath:newMessageSoundPath];
        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)newMessageSoundUrl, &_newMessageSoundID);
        if (err != kAudioServicesNoError) {
            NSLog(@"SoundManager : Could not load %@, error code %d", newMessageSoundUrl ,(int)err);
        }
    }
    
    NSString* reloadSoundIDPath = [[NSBundle mainBundle] pathForResource:@"sound_reload" ofType:@"wav"];
    if (reloadSoundIDPath) {
        NSURL* reloadSoundIDUrl = [NSURL fileURLWithPath:reloadSoundIDPath];
        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)reloadSoundIDUrl, &_reloadSoundID);
        if (err != kAudioServicesNoError) {
            NSLog(@"SoundManager : Could not load %@, error code %d", reloadSoundIDUrl ,(int)err);
        }
    }

}

- (void)playNewMessageSound {
    AudioServicesPlaySystemSound(_newMessageSoundID);
}

- (void)playReloadSound {
    AudioServicesPlaySystemSound(_reloadSoundID);
}

- (void)playNewMessageSoundAfterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(playNewMessageSound) withObject:nil afterDelay:delay];
}

- (void)playReloadSoundAfterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(playReloadSound) withObject:nil afterDelay:delay];
}

@end
