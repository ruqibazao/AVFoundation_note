//
//  NHQualityOfService.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHQualityOfService.h"

@implementation NHQualityOfService

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format frameRateRange:(AVFrameRateRange *)frameRateRange {
    return [[self alloc] initWithFormat:format frameRateRange:frameRateRange];
}
- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format frameRateRange:(AVFrameRateRange *)frameRateRange {
    self = [super init];
    if (self) {
        _format = format;
        _frameRateRange = frameRateRange;
        
    }
    return self;
}

- (BOOL)isHighframeRate {
    return self.frameRateRange.maxFrameRate > 30.f;
    return YES;
}


@end
