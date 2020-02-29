//
//  AVCaptureDevice+Additions.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "AVCaptureDevice+Additions.h"
#import "NHQualityOfService.h"

#if TARGET_OS_MACCATALYST
#import <AppKit/AppKit.h>
#endif

@implementation AVCaptureDevice (Additions)

- (BOOL)supportsHighFrameRateCapture {
    // 先判定媒体类型
    if (![self hasMediaType:AVMediaTypeVideo]) {
        return NO;
    }
    // 判定是否支持高帧率
    return [self findHighestQuqlityOfService].isHighframeRate;
}

- (BOOL)enableHighFrameRateCapture:(NSError *__autoreleasing  _Nullable *)error {
    
    NHQualityOfService *qos = [self findHighestQuqlityOfService];
    if (!qos.isHighframeRate) {// 首先判定设备是否支持最向质量服务，如果不支持生成一个错误
        if (error) {
            NSString *message = @"Device does not support high FPS capture";
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
            NSUInteger code = 10010;
            *error = [NSError errorWithDomain:@"com.nenhall.CameraErrorDomain" code:code userInfo:userInfo];
        }
        return NO;
    }
    // 修改配置前，需要为配置操作锁住
    if ([self lockForConfiguration:error]) {
        CMTime minFameDuration = qos.frameRateRange.minFrameDuration;
        // 将设备的activeFormat 设置为检索到 AVCaptureDeviceFormat
        self.activeFormat = qos.format;
        // 将最小帧星期和最大帧时长调协为 AVFramtRateRange 定义的值
        // MinFrameDuration值为MaxFrameDuration的倒数值，比如帧率为60fps，则duration 为1/60秒
        self.activeVideoMinFrameDuration = minFameDuration;
        self.activeVideoMaxFrameDuration = minFameDuration;
        
        [self unlockForConfiguration];
        return YES;
    }
    
    return NO;
}

- (NHQualityOfService *)findHighestQuqlityOfService {
    AVCaptureDeviceFormat *maxFormat = nil;
    AVFrameRateRange *maxFrameRateRange = nil;
    for (AVCaptureDeviceFormat *format in self.formats) {
        // 遍历所有捕捉设备的支持formats ，并对每一个元素从 formatDescription 获得codecType
        // CMFormatDescriptionRef 是一个coreMedia 的隐含类型，提供了格式对象的许多想着信息
        // 这里只需要 codeType 值等于420YpCbCr8BiPlanarVideoRange的格式，筛选出视频格式
        
        FourCharCode codecType = CMVideoFormatDescriptionGetCodecType(format.formatDescription);
        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
            NSArray *frameRateRanges = format.videoSupportedFrameRateRanges;
            for (AVFrameRateRange *range in frameRateRanges) {
                if (range.maxFrameRate > maxFrameRateRange.maxFrameRate) {
                    maxFormat = format;
                    maxFrameRateRange = range;
                }
            }
        }
    }
    
    return [NHQualityOfService qosWithFormat:maxFormat frameRateRange:maxFrameRateRange];
}

@end
