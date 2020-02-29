//
//  UIImage+Additions.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "UIImage+Additions.h"


#if TARGET_OS_MACCATALYST
#import <AppKit/AppKit.h>
#endif


@implementation UIImage (Additions)

- (CVPixelBufferRef)grayPixleBuffer:(CVPixelBufferRef)pixelBuffer {
    const int BYTES_PER_PIXEL = 4;
    // 从 sampleBuffer 中获取 pixelBuffer
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 在与 CVPixelBufferRef 数据交互前，必须调用，来获取一个相应的内存块的锁
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    size_t bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    // 获得buffer的基址指针，才能霆索引并迭代其数据
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    unsigned char grayPixle;
    for (int row = 0; row < bufferHeight; row++) {
        for (int column = 0; column < bufferWidth; column++) {
            // 迭代buffer 中的像素的行和列，执行简单的RGB像素灰度平均
            grayPixle = ( pixel[1] + pixel[2]) / 3;
            pixel[0] = pixel[1] = pixel[2] = grayPixle;
            pixel += BYTES_PER_PIXEL;
        }
    }
    // 释放上面的加锁操作
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    CVImageBufferRef imageBuffer =  pixelBufferRef;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}

@end
