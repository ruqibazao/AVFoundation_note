//
//  CameraController.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/7.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "CameraController.h"


@interface CameraController ()<AVCaptureFileOutputRecordingDelegate,AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
@property (strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@end

@implementation CameraController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initCaptureSession];
    }
    return self;
}

- (void)initCaptureSession {
    _outputFileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"movie.mov"]];

    // 以下代码必须在真机上运行。不支持模拟器
#if !TARGET_OS_SIMULATOR
    // 请求一个默认的视频设备
    AVCaptureDevice *captureDeveice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    
    // ios 7开始有部份地区有法律规定时，访问用户相机麦克风需要请求权限，ios 8开始所有地区都必须请求
    // 如果用户拒绝了权限，videoInput 会创建失败返回nil，并在error中返回
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDeveice error:&error];
    _videoInput = videoInput;
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    _session = session;
    //    AVCaptureSessionPresetHigh 是默认选择的值，并且满足Kamera的需求
    session.sessionPreset = AVCaptureSessionPresetHigh;
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    
    // 音频设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    // ios 7开始有部份地区有法律规定时，访问用户相机麦克风需要请求权限，ios 8开始所有地区都必须请求
    // 如果用户拒绝了权限，audioInput 会创建失败返回nil，并在error中返回
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    _audioInput = audioInput;
    if ([session canAddInput:audioInput]) {
        [session addInput:audioInput];
    }
    
    if (error) {
        NSLog(@"capture session error:%@",error.localizedDescription);
        if (error.code == AVErrorApplicationIsNotAuthorizedToUseDevice) {
            // `AVErrorApplicationIsNotAuthorizedToUseDevice`(Code=-11852) 没有权限，更多内容可以在 AVError.h 文件中查看
            //  do sth ing ...
        }
        return;
    }
    
    _videoQueue = dispatch_queue_create("com.nenhall.videoQueue", NULL);
    
    [self addStillImageOutput];
    [self addMovieFileOutput];
#endif
}

- (void)addVideoOutput {
    [self removeMovieOutput];
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 初始化格式为双平面420v ，这个格式分为亮度和色度，并且在垂直和水平方向对颜色进行子抽样
    // 虽然直接用这个原始格式肯定可以，不过在使用OpenGL ES时经常会选用BGRA，要注意这一格式的转换会稍微牺牲一点性能
    NSDictionary *setting = @{ (id)kCVPixelBufferPixelFormatTypeKey : @( kCVPixelFormatType_32BGRA) };
    _videoOutput.videoSettings = setting;
    // 设置代理及在指定的队列上进行调度，调度队列必须是一个`序列队列`
    // 为提升性能，videoOutput / audioOutput 实际中我们可以使用两个队列，但代码方面需要改动，此Demo中没有使用两个队列
    // 具体使用两队列的方法，可以参考苹果官方示例程序：RosyWriter(在 ADC 上可用)，用的就是这种方法，它还给出了一些有效处理CMSample-Buffers的更高级性能选项
    [_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
    if ([_session canAddOutput:_videoOutput]) {
        [_session addOutput:_videoOutput];
    }
}

- (void)removeVideoOutput {
    [self.session removeOutput:_videoOutput];
}

- (void)addAudioOutput {
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [_audioOutput setSampleBufferDelegate:self queue:_videoQueue];
    if ([_session canAddOutput:_audioOutput]) {
        [_session addOutput:_audioOutput];
    }
}

- (void)removeAudioOutput {
    [self.session removeOutput:_audioOutput];
}

- (void)addMovieFileOutput {
    [self removeVideoOutput];
    [self removeAudioOutput];

    // 文件输出：用于将quickTime电影录制到文件系统
    AVCaptureMovieFileOutput *movieOutput = AVCaptureMovieFileOutput.alloc.init;
    _movieOutput = movieOutput;
    if ([_session canAddOutput:movieOutput]) {
        [_session addOutput:movieOutput];
    }
}

- (void)removeMovieOutput {
    [self.session removeOutput:_movieOutput];
}

- (void)addStillImageOutput {
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = AVCaptureStillImageOutput.alloc.init;
    _imageOutput = imageOutput;
    //    AVVideoCodecJPEG 捕捉格式
    imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    if (@available(iOS 10, *)) {
        AVCapturePhotoOutput *photoOutput = AVCapturePhotoOutput.alloc.init;
        AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:imageOutput.outputSettings];
        [photoOutput setPhotoSettingsForSceneMonitoring:settings];
    }
    
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
    }
}

- (void)removeStillImageOutput {
    [_session removeOutput:_imageOutput];
}

- (void)startRunning {
    // stopRunning是同频调用的方法，需要一定的时候，所以这里需要异步调用，防止阻碍主线程
    dispatch_async(self.videoQueue, ^{
        [self.session startRunning];
    });
}

- (void)stopRunning {
    dispatch_async(self.videoQueue, ^{
        [self.session stopRunning];
    });
}

// 是否支持缩放
- (BOOL)cameraSupportZoom {
    // 如果 videoMaxZoomFactor > 1.0 则捕捉设备支持缩放功能
    return [self activeCamera].activeFormat.videoMaxZoomFactor > 1.0f;
}

// 最大缩放值
- (CGFloat)maxZoomFactor {
    // 固定一个最大的缩放值，如果设备支持大于4.0，也不要设得太大，没有其它原因，太大也不实用
    // 如果设置的值超出设备的最大值，就会出现异常
    return MIN([self activeCamera].activeFormat.videoMaxZoomFactor, 4.0);
}

// 设置缩放值
- (void)setZoomValue:(CGFloat)zoomValue {
    if (![self activeCamera].isRampingVideoZoom) {
        NSError *error;
        if ([[self activeCamera] lockForConfiguration:&error]) {
            // 应用程序提供是1x-4x，这增长是指数形式，所以要提供范围线性增长的感觉，
            // 需要通过计算最大的缩放因子zoomValue次幂(0到1)来计算`videoZoomFactor`
            CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
            [self activeCamera].videoZoomFactor = zoomFactor;
            [[self activeCamera] unlockForConfiguration];
        }
        
    } else {
        
    }
}
// 持续缩放到指定值，带动画的效果
- (void)rampZoomToValue:(CGFloat)zoomValue {
    CGFloat roomFactor = pow([self maxZoomFactor], zoomValue);
    NSError *error;
    if ([[self activeCamera] lockForConfiguration:&error]) {
        // 每0.2秒增缩放因子一倍
        [[self activeCamera] rampToVideoZoomFactor:roomFactor withRate:0.2];
        [[self activeCamera] unlockForConfiguration];
    } else {
        
    }
}

#pragma mark 人脸检测
- (BOOL)setupSessionOutputs:(NSError *)error {
    self.metadataOutput = AVCaptureMetadataOutput.alloc.init;
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
        
        NSArray *metadataObjectTypes = @[ AVMetadataObjectTypeFace ];
        // 指定元数据输出的数据类型，但现在我只对人脸数据感兴趣
        [self.metadataOutput setMetadataObjectTypes:metadataObjectTypes];
        // 当有新的元数据被检测到时，会调用这代理方法
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        return YES;
    }
    return NO;
}

#pragma mark 条形码读取
// 支持的条形码：UPC-E 、EAN-8、EAN-13、Code39、Code93、Code128、交错式2 of 5码、ITF、QR、Aztec、PDF-417、Data Matrix
- (NSString *)seeionPreset {
    return AVCaptureSessionPreset640x480;
}
- (BOOL)setupsessionInputs:(NSError *)error {
    BOOL success = NO;
    // 检测是否支持约束范围进行扫描
    if ([self activeCamera].autoFocusRangeRestrictionSupported) {
        if ([[self activeCamera] lockForConfiguration:nil]) {
            [self activeCamera].autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
            [[self activeCamera] unlockForConfiguration];
            success = YES;
        }
    }
    
    return success;
}
// 扫码
- (BOOL)setupSessionOutputs2:(NSError *)error {
    [self switchCameras];
    AVCaptureMetadataOutput *metadataOutput = AVCaptureMetadataOutput.alloc.init;
    self.metadataOutput = metadataOutput;
    if ([self.session canAddOutput:metadataOutput]) {
        [self.session addOutput:metadataOutput];
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        [metadataOutput setMetadataObjectsDelegate:self queue:mainQueue];
        // 指定元数据输出的数据类型，但现在我只对条形码感兴趣
        NSArray *types = @[ AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode ];
        metadataOutput.metadataObjectTypes = types;
    }else {
        return NO;
    }
    return YES;
}


#pragma mark 切换摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {
    return self.videoInput.device;
}

// 当前未激活的摄像头
- (AVCaptureDevice *)incativeCamera {
    AVCaptureDevice *device = nil;
    if ([self cameraCount] > 1) {
        if ([self activeCamera].position ==AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

//能否切换摄像头
- (BOOL)canSwitchCameras {
    return [self cameraCount] > 1;
}

- (BOOL)switchCameras {
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError *error;
    AVCaptureDevice *vidieoDevice = [self incativeCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:vidieoDevice error:&error];
    if (videoInput) {
        // 标注原子变化的开始
        [self.session beginConfiguration];
        [self.session removeInput:self.videoInput];
        if ([self.session canAddInput:videoInput]) {
            [self.session addInput:videoInput];
            self.videoInput = videoInput;
        } else {
            [self.session addInput:self.videoInput];
        }
        // 提交原子变化
        [self.session commitConfiguration];
        
    } else {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

#pragma mark 配置摄像头
- (BOOL)cameraSupertsTapToFocus {
    // 是否支持对焦
    return [[self activeCamera] isFocusPointOfInterestSupported];
}
// 对焦
- (IBAction)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    // 确认是否支持对焦 及是否支持自动对焦
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        // 将设备设置为 AVCaptureFocusModeLocked 模式，如果获得了锁，进行配置，直到 unlockForConfiguration 释放该锁定
        if ([device lockForConfiguration:&error]) {
            // 对焦点
            device.focusPointOfInterest = point;
            // AVCaptureFocusModeAutoFocus 会使用单独扫描的自动对焦
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
    } else {
        // ...
    }
}

// 曝光
// 是否支持曝光模式
- (BOOL)cameraSupertsTapExpose {
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static NSString *NHCameraAdjustingExposureContext;
- (IBAction)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureModel = AVCaptureExposureModeContinuousAutoExposure;
    NSError *error;
    // 确定配置是否被支持
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureModel]) {
        [device lockForConfiguration:&error];
        device.exposurePointOfInterest = point;
        device.exposureMode = exposureModel;
        // 锁定支持曝光模式，如果支持，使用kvo来确定设置 adjustingExposure 属性状态，观察该属性可以知道曝光调整何时完成，让我们有机会在该点上锁定曝光
        if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&NHCameraAdjustingExposureContext];
        }
        
        [device unlockForConfiguration];
    } else {
        
    }
}

//重新设置对焦和曝光
- (void)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    // 先确认对焦兴趣点和连续自动对焦是否被支持
    AVCaptureFocusMode focusModel = AVCaptureFocusModeAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusModel];
    // 确认曝光度是否可以相关的功能测试被重设
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    // 合建一个默认的对焦、曝光点
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    
    // 锁定设置准备配置，如果可以进行重设就进行修改
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusModel;
            device.focusPointOfInterest = centerPoint;
        }
        
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        [device unlockForConfiguration];
    }
}

#pragma mark 调整闪光灯
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)falshMode {
    return [[self activeCamera] flashMode];
}

- (void)setFlashModel:(AVCaptureFlashMode) flashMode {
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
    } else {
        
    }
}

- (BOOL)supportsHighFrameRateCapture {
    return [[self activeCamera] supportsHighFrameRateCapture];
}

- (void)startRecordingToOutputFileURL:(NSURL *)outputFileURL {
    _outputFileURL = outputFileURL;
    BOOL active = NO, enabled = NO;
    
    for (AVCaptureConnection *connection in self.movieOutput.connections) {
        active = connection.active;
        enabled = connection.enabled;
    }
    
    if (active && enabled) {
        [self.movieOutput startRecordingToOutputFileURL:_outputFileURL recordingDelegate:self];
    }
}

- (void)stopRecording {
    [self.movieOutput stopRecording];
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
#pragma mark AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_delegate && [_delegate respondsToSelector:@selector(didOutputSampleBuffer:)]) {
        [_delegate didOutputSampleBuffer:sampleBuffer];
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_delegate && [_delegate respondsToSelector:@selector(didDropSampleBuffer:)]) {
        [_delegate didDropSampleBuffer:sampleBuffer];
    }
}


#pragma mark AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(didFinishRecordingToOutputFileAtURL:error:)]) {
        [_delegate didFinishRecordingToOutputFileAtURL:outputFileURL error:error];
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (_delegate && [_delegate respondsToSelector:@selector(didOutputMetadataObjects:)]) {
        [_delegate didOutputMetadataObjects:metadataObjects];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == &NHCameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        // 判定设备是否再调整曝光等级，确认模式是否为 AVCaptureExposureModeLocked，如何可以再继续下去
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            //            移除属性监听器，这样就会得到后续变化的通知了
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&NHCameraAdjustingExposureContext];
            // 最后导眯主队列，来设置模式，将 exposureMode 更改转移到下一个事件循环非常重要，这样上一步中的removeobserver调用才有机会完成
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    
                }
            });
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
//    [ [self activeCamera] removeObserver:self forKeyPath:@"adjustingExposure" context:&NHCameraAdjustingExposureContext];
}

@end
