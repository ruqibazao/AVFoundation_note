//
//  Common.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

static const CGFloat NHTimelineSeconds = 15.0f;
static const CGFloat NHTimelineWidth = 1014.0f;

static const CMTime NHDefaultFadeInOutTime = {3, 2, 1, 0}; // 1.5 seconds
static const CMTime NHDefaultDuckingFadeInOutTime = {1, 2, 1, 0}; // .5 seconds
static const CMTime NHDefaultTransitionDuration = {1, 1, 1, 0}; // 1 second

CG_EXTERN CGAffineTransform NHTransformForDeviceOrientation(UIDeviceOrientation orientation);


static inline BOOL NHIsEmpty(id value) {
    return value == nil ||
    value == [NSNull null] ||
    ([value isKindOfClass:[NSString class]] && [value length] == 0) ||
    ([value respondsToSelector:@selector(count)] && [value count] == 0);
}


NS_ASSUME_NONNULL_END
