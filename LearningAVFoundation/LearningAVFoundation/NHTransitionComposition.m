//
//  NHTransitionComposition.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/24.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHTransitionComposition.h"

@interface NHTransitionComposition ()
@property (nonatomic, strong) AVComposition *composition;
@property (nonatomic, strong) AVVideoComposition *videoComposition;
@property (nonatomic, strong) AVAudioMix *audioMix;
@end

@implementation NHTransitionComposition

- (instancetype)initWithComposition:(AVComposition *)composition videoComposition:(AVVideoComposition *)videoComposition audioMix:(AVAudioMix *)audioMix {
    self = [super init];
    if (self) {
        _composition = composition;
        _videoComposition = videoComposition;
        _audioMix = audioMix;
        
    }
    return self;
}

- (AVPlayerItem *)makePlayable {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.composition copy]];
    playerItem.audioMix = self.audioMix;
    playerItem.videoComposition = self.videoComposition;
    
    return playerItem;
}


- (AVAssetExportSession *)makeExportable {
    NSString *preset = AVAssetExportPresetHighestQuality;
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:[self.composition copy] presetName:preset];
    session.audioMix = self.audioMix;
    session.videoComposition = self.videoComposition;
    
    return session;
}



@end
