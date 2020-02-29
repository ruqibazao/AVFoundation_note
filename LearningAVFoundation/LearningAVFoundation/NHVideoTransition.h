//
//  NHVideoTransition.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/27.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    NHVideoTransitionTypeNone,
    NHVideoTransitionTypeDissolve,
    NHVideoTransitionTypePush,
    NHVideoTransitionTypeWipe
} NHVideoTransitionType;

typedef enum {
    NHPushTransitionDirectionLeftToRight = 0,
    NHPushTransitionDirectionRightToLeft,
    NHPushTransitionDirectionTopToButton,
    NHPushTransitionDirectionBottomToTop,
    NHPushTransitionDirectionInvalid = INT_MAX
} NHPushTransitionDirection;


@interface NHVideoTransition : NSObject

+ (id)videoTransition;

@property (nonatomic) NHVideoTransitionType type;
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CMTime duration;
@property (nonatomic) NHPushTransitionDirection direction;

+ (id)disolveTransitionWithDuration:(CMTime)duration;

+ (id)pushTransitionWithDuration:(CMTime)duration direction:(NHPushTransitionDirection)direction;
@end

NS_ASSUME_NONNULL_END
