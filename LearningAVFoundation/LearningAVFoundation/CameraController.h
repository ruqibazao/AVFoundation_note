//
//  CameraController.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/7.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVCaptureDevice+Additions.h"
#import "AVMetadataItem+Additions.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CameraControllerDelegate <NSObject>

- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects;
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error;

@end

@interface CameraController : NSObject
@property (copy)   NSURL *outputFileURL;

@property (nonatomic, weak) id<CameraControllerDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureSession *session;
@property (nonatomic, strong, readonly) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong, readonly) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong, readonly) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic, strong, readonly) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong, readonly) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong, readonly) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong, readonly) AVCaptureAudioDataOutput *audioOutput;


- (void)startRunning;
- (void)stopRunning;

// 设置缩放值
- (void)setZoomValue:(CGFloat)zoomValue;

// 持续缩放到指定值，带动画的效果
- (void)rampZoomToValue:(CGFloat)zoomValue;

// 人脸检测
- (BOOL)setupSessionOutputs:(NSError *)error;

// 扫码
- (BOOL)setupSessionOutputs2:(NSError *)error;
- (BOOL)supportsHighFrameRateCapture;


//切换摄像头
- (BOOL)switchCameras;
// 对焦
- (IBAction)focusAtPoint:(CGPoint)point;
- (IBAction)exposeAtPoint:(CGPoint)point;
- (void)setFlashModel:(AVCaptureFlashMode) flashMode;
- (void)resetFocusAndExposureModes;

- (void)addVideoOutput;
- (void)removeVideoOutput;
- (void)addAudioOutput;
- (void)removeAudioOutput;
- (void)addMovieFileOutput;
- (void)removeMovieOutput;
- (void)addStillImageOutput;
- (void)removeStillImageOutput;

- (void)startRecordingToOutputFileURL:(NSURL *)outputFileURL;
- (void)stopRecording;

@end

NS_ASSUME_NONNULL_END
