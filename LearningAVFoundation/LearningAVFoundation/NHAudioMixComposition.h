//
//  NHAudioMixComposition.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/18.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NHComposition.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHAudioMixComposition : NSObject<NHComposition>
@property (nonatomic, strong, readonly) AVAudioMix *audioMix;
@property (nonatomic, strong, readonly) AVComposition *composition;

+(instancetype)compositionWithComposition:(AVComposition *)composition
                                 audioMix:(AVAudioMix *)audioMix;
-(instancetype)initWithComposition:(AVComposition *)composition
                          audioMix:(AVAudioMix *)audioMix;

@end

NS_ASSUME_NONNULL_END
