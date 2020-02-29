//
//  NHTransitionComposition.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/24.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NHComposition.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHTransitionComposition : NSObject <NHComposition>

@property (nonatomic, strong, readonly) AVComposition *composition;
@property (nonatomic, strong, readonly) AVVideoComposition *videoComposition;
@property (nonatomic, strong, readonly) AVAudioMix *audioMix;

- (instancetype)initWithComposition:(AVComposition *)composition
                   videoComposition:(AVVideoComposition *)videoComposition
                           audioMix:(AVAudioMix *)audioMix;


@end

NS_ASSUME_NONNULL_END
