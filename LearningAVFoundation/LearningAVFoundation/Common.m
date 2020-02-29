//
//  Common.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "Common.h"


CGAffineTransform NHTransformForDeviceOrientation(UIDeviceOrientation orientation) {
    CGAffineTransform result;

    switch (orientation) {

        case UIDeviceOrientationLandscapeRight:
            result = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            result = CGAffineTransformMakeRotation((M_PI_2 * 3));
            break;

        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = CGAffineTransformMakeRotation(M_PI_2);
            break;

        default: // Default orientation of landscape left
            result = CGAffineTransformIdentity;
            break;
    }

    return result;
}

