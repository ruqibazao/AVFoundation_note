//
//  NHAudioMixComposition.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/18.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHAudioMixComposition.h"

@interface NHAudioMixComposition ()
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, strong) AVComposition *composition;
@end

@implementation NHAudioMixComposition

+ (instancetype)compositionWithComposition:(AVComposition *)composition
                                  audioMix:(AVAudioMix *)audioMix {
    return [[self alloc] initWithComposition:composition audioMix:audioMix];
}

- (instancetype)initWithComposition:(AVComposition *)composition
                           audioMix:(AVAudioMix *)audioMix {
    self = [super init];
    if (self) {
        _composition = composition;
        _audioMix = audioMix;
    }
    return self;
}

// 利用此方法进行播放预览
- (AVPlayerItem *)makePlayable {
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:[self.composition copy]];
    playItem.audioMix = self.audioMix;
    return playItem;
}

// 进行导出
- (AVAssetExportSession *)makeExportable {
    NSString *preset = AVAssetExportPresetHighestQuality;
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:[self.composition copy] presetName:preset];
    session.audioMix = self.audioMix;
    return session;
}

@end
