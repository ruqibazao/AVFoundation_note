//
//  NHVideoTransition.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/27.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHVideoTransition.h"

@implementation NHVideoTransition

+ (id)videoTransition {
    return [[[self class] alloc] init];
}

+ (id)disolveTransitionWithDuration:(CMTime)duration {
    NHVideoTransition *transition = [self videoTransition];
    transition.type = NHVideoTransitionTypeDissolve;
    transition.duration = duration;
    return transition;
}

+ (id)pushTransitionWithDuration:(CMTime)duration direction:(NHPushTransitionDirection)direction {
    NHVideoTransition *transition = [self videoTransition];
    transition.type = NHVideoTransitionTypePush;
    transition.duration = duration;
    transition.direction = direction;
    return transition;
}


- (id)init {
    self = [super init];
    if (self) {
        _type = NHVideoTransitionTypeDissolve;
        _timeRange = kCMTimeRangeInvalid;
    }
    return self;
}

- (void)setDirection:(NHPushTransitionDirection)direction {
    if (self.type == NHVideoTransitionTypePush) {
        _direction = direction;
    } else {
        _direction = NHPushTransitionDirectionInvalid;
        NSAssert(NO, @"Direction can only be specified for a type == THVideoTransitionTypePush.");
    }
}


@end
