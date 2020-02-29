//
//  UIImage+Additions.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/6.
//  Copyright © 2020 nenhall. All rights reserved.
//


#if TARGET_OS_MACCATALYST
#import <AppKit/AppKit.h>
#endif


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Additions)


+ (CVPixelBufferRef)grayPixleBuffer:(CVPixelBufferRef)pixelBuffer;

+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef;



@end

NS_ASSUME_NONNULL_END
