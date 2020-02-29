//
//  MovieWriter.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "MovieWriter.h"
#import <UIKit/UIKit.h>
#import "Common.h"
#import "NHContextManager.h"
#import "NHPhotoFilters.h"

@interface MovieWriter ()
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *inputPixelBufferAdaptor;

@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) dispatch_queue_t audioQueue;

@property (strong, nonatomic) CIFilter *activeFilter;
@property (weak, nonatomic) CIContext *ciContext;
@property (nonatomic) CGColorSpaceRef colorSpace;

@property (nonatomic, copy) NSDictionary *videoSetting;
@property (nonatomic, copy) NSDictionary *audioSetting;
@property (nonatomic, assign) BOOL firstSample;
@property (nonatomic, assign) BOOL isWriting;

@end

@implementation MovieWriter

- (instancetype)initWithVideoSetting:(NSDictionary *)videoSetting audioSetting:(NSDictionary *)audioSetting dispatchQueue:(dispatch_queue_t)dispatchQueue {
    self = [super init];
    if (self) {
        _videoSetting = videoSetting;
        _audioSetting = audioSetting;
        // 为提升性能，实际中我们可以使用两个队列，但代码方面需要改动，此Demo中没有使用两个队列
        _videoQueue = dispatchQueue;
        _audioQueue = dispatchQueue;
        
        _ciContext = [NHContextManager sharedInstance].ciContext;           // 3
        _colorSpace = CGColorSpaceCreateDeviceRGB();

        _activeFilter = [NHPhotoFilters defaultFilter];
        _firstSample = YES;
        
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];    // 4
//        [nc addObserver:self
//               selector:@selector(filterChanged:)
//                   name:NHFilterSelectionChangedNotification
//                 object:nil];
        
    }
    return self;
}

- (void)filterChanged:(NSNotification *)notification {
    self.activeFilter = [notification.object copy];
}


- (void)startWriting {
    // 避免用户交互层卡顿，所以以异步方式调度到 _videoQueue 队列
    dispatch_async(_videoQueue, ^{
        NSError *error = nil;
        NSString *fileType = AVFileTypeQuickTimeMovie;
        // 创建 AVAssetWriter 实例
        self.assetWriter = [AVAssetWriter assetWriterWithURL:[self outputURL] fileType:fileType error:&error];
        if (!self.assetWriter || error) {
            NSString *formatString = @"Could not create AVAssetWriter";
            NSLog(@"%@, error:%@",formatString, error.localizedDescription);
            return ;
        }
        // 创建 AVAssetWriterInput 以附加从 AVCaptureVieoDataOutput 中得到的样本
        self.videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:self.videoSetting];
        // 指明 expectsMediaDataInRealTime 为yes，是针对实时性进行优化
        self.videoInput.expectsMediaDataInRealTime = YES;
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        // 应用程序的用户界面锁定为垂直方向，不过我们需要捕捉应该可以支持任何文向，所以需要合适的转换，在写入会话期间，方向会按照这一设定保持不变
        self.videoInput.transform = NHTransformForDeviceOrientation(orientation);
        // 要保证最大效率，字典中的值应该对应于在配置 AVCaptureVideoData-Output时所用的原像素格式
        NSDictionary *attributes = @{
            (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
            (id)kCVPixelBufferWidthKey : self.videoSetting[AVVideoWidthKey],
            (id)kCVPixelBufferHeightKey: self.videoSetting[AVVideoHeightKey],
            (id)kCVPixelFormatOpenGLESCompatibility : (id)kCFBooleanTrue
        };
        
        // 使用 AVAssetWriterInputPixelBufferAdaptor 可以创建CVPixelBuffer 对象来渲染筛选视频帧
        self.inputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.videoInput sourcePixelBufferAttributes:attributes];
        if ([self.assetWriter canAddInput:self.videoInput]) {
            [self.assetWriter addInput:self.videoInput];
        } else {
            NSLog(@"Unable to add video input.");
        }
        // 同 videoInput，只不过这个是音频数据
        self.audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:self.audioSetting];
        self.audioInput.expectsMediaDataInRealTime = YES;
        
        if ([self.assetWriter canAddInput:self.audioInput]) {
            [self.assetWriter addInput:self.audioInput];
        } else {
            NSLog(@"Unable to add audio input.");
        }
        
        self.isWriting = YES;
        self.firstSample = YES;

    });
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!self.isWriting) {
        return;
    }
    
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
    // 确定媒体样本类型
    if (mediaType == kCMMediaType_Video) {
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if (self.firstSample) {
            if ([self.assetWriter startWriting]) {
                [self.assetWriter startSessionAtSourceTime:timestamp];
            } else {
                NSLog(@"Failed to start writing.");
            }
            self.firstSample = NO;
        }
        
        CVPixelBufferRef outputRenderBuffer = NULL;
        CVPixelBufferPoolRef pixelBufferPool = self.inputPixelBufferAdaptor.pixelBufferPool;
        
        OSStatus err = CVPixelBufferPoolCreatePixelBuffer(NULL, pixelBufferPool, &outputRenderBuffer);
        if (err) {
            NSLog(@"Unable to obtain a pixel buffer from the pool.");
            return;
        }
        // 获取当前视频样本的 CVPixelBufferRef
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        // 根据像素buffer创建一个新的CIImage ，并将它设置为活动筛选器的 kCIInputImageKey 值，
        // 通过筛选器得到输出图片，会返回一个封装了CIFilter 操作的CIImage 对象
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:nil];
        [self.activeFilter setValue:sourceImage forKey:kCIInputImageKey];
        
        // 如果因为某种原因FilteredImage为nil，则设置CIImage的引用为原始的soruceImage
        CIImage *filteredImage = [self activeFilter].outputImage;
        if (!filteredImage) {
            filteredImage = sourceImage;
        }
        // 将筛选好的CIImage的输出渲染到第三步创建的CVPixelBuffer 中
        [self.ciContext render:filteredImage toCVPixelBuffer:outputRenderBuffer bounds:filteredImage.extent colorSpace:self.colorSpace];
        // 如果 readyForMoreMediaData 为 yes ，则将像素buffer连同当前样本的呈现时间都附加到 AVAssetWriterPixelBufferAdaptor。
        if (self.videoInput.readyForMoreMediaData) {
            BOOL isAppend = [self.inputPixelBufferAdaptor appendPixelBuffer:outputRenderBuffer
                                                       withPresentationTime:timestamp];
            if (!isAppend) {
                NSLog(@"Error appending pixel buffer");
            }
        }
        // 现在就完成了对当前视频样本的处理，所以此时应释放 buffer
        CVPixelBufferRelease(outputRenderBuffer);
        
    } else if (!self.firstSample && (mediaType == kCMMediaType_Audio)) {
        // 如果第一个样本处理完成并且当前的CMSampleBuffer 是一个音频样本，则询问音频写入是否准备接受更多数据，如何可以，则将它添加到输入
        if (self.audioInput.isReadyForMoreMediaData) {
            BOOL isAppend = [self.audioInput appendSampleBuffer:sampleBuffer];
            if (!isAppend) {
                NSLog(@"Error appending audio sample buffer");
            }
        }
    }
}

- (void)stopWriting {
    // 设置标志为NO，这样`processSampleBuffer:medidType`方法就不会再处理更多的样本
    self.isWriting = NO;
    dispatch_async(_videoQueue, ^{
        [self.assetWriter finishWritingWithCompletionHandler:^{
            // 判定状态确定是否完成写入
            if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
                // 回到主线程调度
                dispatch_async(dispatch_get_main_queue(), ^{
                       NSURL *fileURL = [self.assetWriter outputURL];
                       if (self.delegate && [self.delegate respondsToSelector:@selector(didWriterMovieAtURL:)]) {
                           [self.delegate didWriterMovieAtURL:fileURL];
                       }
                   });
            } else {
                NSLog(@"Failed to write movie: %@",self.assetWriter.error);
            }
        }];
    });
}


- (NSURL *)outputURL {
    if (_outputURL) {
        return _outputURL;
    }
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"freeWriter.mov"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

@end
