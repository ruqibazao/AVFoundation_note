//
//  NHQualityOfService.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHQualityOfService : NSObject
@property (nonatomic, strong, readonly) AVCaptureDeviceFormat *format;
@property (nonatomic, strong, readonly) AVFrameRateRange *frameRateRange;
@property (nonatomic, assign) BOOL isHighframeRate;

+(instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
              frameRateRange:(AVFrameRateRange *)frameRateRange;

-(BOOL)isHighframeRate;


@end

NS_ASSUME_NONNULL_END
