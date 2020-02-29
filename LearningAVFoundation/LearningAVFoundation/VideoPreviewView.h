//
//  VideoPreviewView.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/29.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPreviewView : UIView

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;
@property (copy) void (^switchFlastlight)(NSUInteger type);
@property (copy) void (^switchRecordMode)(NSUInteger type);
@property (copy) void (^switchCamera)(NSUInteger type);
@property (copy) void (^recordSartOrStop)(NSUInteger type);
@property (copy) void (^setTouchPoint)(CGPoint point);
@property (copy) void (^captureImage)(void);
@property (copy) void (^didClickChangeZoomValue)(CGFloat value);
@property (copy) void (^didSliderChangeZoomValue)(CGFloat value);


+ (instancetype)loadVideoPreview;

// 获取屏幕的坐标系转换得的设置坐标系
- (CGPoint)captureDevicePointForPoint:(CGPoint)point;

- (void)setMaxZoomValue:(NSInteger)value;
- (void)setFaces:(NSArray *)faces;
- (void)didDetectCodes:(NSArray *)codes;


@end

NS_ASSUME_NONNULL_END
