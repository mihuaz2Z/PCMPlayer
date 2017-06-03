//
//  PCMPlayer.h
//  PCMPlayer
//
//  Created by Ruiwen Feng on 2017/5/31.
//  Copyright © 2017年 Ruiwen Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioBufferQueue.h"


@protocol PcmRecordProtocol <NSObject>

- (void)pcmDataCallback:(AudioBuffer)buffer;

@end

@interface PCMPlayer : NSObject
@property (strong,nonatomic) AudioBufferQueue *audioBufferQueue;
@property (assign,nonatomic) AudioComponentInstance audioUnit;

@property (weak,nonatomic)   id<PcmRecordProtocol>  delegate;


/* 8000 hz,16 bit,1 channel */
+ (void)defaultAudioFormat:(AudioStreamBasicDescription*)format;

- (void)createUnit:(AudioStreamBasicDescription)audioFormat;

- (void)startPlay;
- (void)stopPlay ;

- (void)inserAudioBuffer:(AudioBuffer*)buffer;

@end
