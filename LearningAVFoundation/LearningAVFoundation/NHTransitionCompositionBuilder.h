//
//  NHTransitionCompositionBuilder.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/24.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

@class NHTimeline;

@interface NHTransitionCompositionBuilder : NSObject
@property (nonatomic, strong, readonly) NHTimeline *timeline;
@property (nonatomic, strong, readonly) AVMutableComposition *composition;
@property (nonatomic, strong, readonly) AVMutableCompositionTrack *musicTrack;
@end

NS_ASSUME_NONNULL_END
