//
//  SampleDataProvider.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/9.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "SampleDataProvider.h"
#import <AVFoundation/AVFoundation.h>

@implementation SampleDataProvider

+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset completionBlock:(void(^)(NSData *))completion {
    NSString *tracks = @"tracks";
    // 异步读取资源所需的键执行标准
    [asset loadValuesAsynchronouslyForKeys:@[ tracks ] completionHandler:^{
        AVKeyValueStatus status = [asset statusOfValueForKey:tracks error:nil];
        NSData *sampleData = nil;
        if (status  == AVKeyValueStatusLoaded) {
            sampleData = [self readAudioSamplesFromAsset:asset];
        }
        // 由于载入操作可能发生在任意队列，所以需要回到主队列回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(sampleData);
            }
        });
    }];
}

+ (NSData *)readAudioSamplesFromAsset:(AVAsset *)asset {
    NSError *error;
    // 创建 AVAssetReader 实例，并赋值一个资源来读取
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (!assetReader) {
        NSLog(@"Error creating aseet reader: %@",error.localizedDescription);
        return nil;
    }
    // 这里有可能会出现数组越界，实现开发中请进行判定
    // 获取对应的轨道
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    // 从资源v轨道读取音频样本时使用的解压设置
    NSDictionary *outputSetting = @{
        AVFormatIDKey : @(kAudioFormatLinearPCM),
        AVLinearPCMIsBigEndianKey : @NO,
        AVLinearPCMIsFloatKey : @NO,
        AVLinearPCMBitDepthKey: @(16)
    };
    //
    AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track
                                                                             outputSettings:outputSetting];
    if ([assetReader canAddOutput:trackOutput]) {
        [assetReader addOutput:trackOutput];
        // 允许资源器开始取样
        [assetReader startReading];
    }
    
    NSMutableData *sampleData = NSMutableData.data;
    
    while (assetReader.status == AVAssetReaderStatusReading) {
        // 调用跟踪输出的 `copyNextSampleBuffer` 方法开始每一个迭代，每次都会返回一个包含ujfhi样本的下一个可用样本buffer
        CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];

        if (sampleBuffer) {
            // CMSampleBufferRef中的音频样本包含在一个 CMBlockBufferRef 类型中
            // 使用 CMSampleBufferGetDataBuffer 函数访问这个block buffer
            // 使用 CMBlockBufferGetDataLength 函数确定其长度并创建一个16位的带符号整型r数组来保存这些音频样本
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            SInt16 sampleBytes[length];
            // CMBlockBufferCopyDataBytes 生成一个数组，数组听元素为CMBlock-buffer所包含的数据
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, sampleBytes);
            [sampleData appendBytes:sampleBytes length:length];
            // 指定样本buffer 已经处理和不可再继续使用，因此还要释放其内存
            CMSampleBufferInvalidate(sampleBuffer);
            CFRelease(sampleBuffer);
        }
    }
    // 如果读取完成，则返回
    if (assetReader.status == AVAssetReaderStatusCompleted) {
        return sampleData;
    } else {
        NSLog(@"读取音频样本失败");
    }
    
    return nil;
}

@end
