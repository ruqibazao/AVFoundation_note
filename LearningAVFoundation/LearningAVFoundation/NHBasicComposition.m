//
//  NHBasicComposition.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHBasicComposition.h"

@interface NHBasicComposition ()
@property (nonatomic, strong) AVComposition *composition;

@end

@implementation NHBasicComposition

+ (instancetype)compositionWithComposition:(AVComposition *)composition {
    return [[self alloc] initWithComposition:composition];
}

- (instancetype)initWithComposition:(AVComposition *)composition {
    self = [super init];
    if (self) {
        _composition = composition;
    }
    return self;
}

- (AVPlayerItem *)makePlayable {
    return [AVPlayerItem playerItemWithAsset:self.composition.copy];
}

- (AVAssetExportSession *)makeExportable {
    NSString *preset = AVAssetExportPresetHighestQuality;
    return [AVAssetExportSession exportSessionWithAsset:self.composition.copy presetName:preset];
}


@end
