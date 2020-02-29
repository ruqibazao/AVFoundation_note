//
//  AVCaptureDevice+Additions.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#if TARGET_OS_MACCATALYST
#import <AppKit/AppKit.h>
#endif

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCaptureDevice (Additions)

- (BOOL)supportsHighFrameRateCapture;
- (BOOL)enableHighFrameRateCapture:(NSError **)error;


@end

NS_ASSUME_NONNULL_END
