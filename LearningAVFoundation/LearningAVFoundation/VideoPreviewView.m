//
//  VideoPreviewView.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/29.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "VideoPreviewView.h"

@interface VideoPreviewView ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *flastlight;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;
@property (strong, nonatomic) NSMutableDictionary *faceLayers;
@property (strong, nonatomic) CALayer *overlayLayer;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) NSMutableDictionary *codeLayers;

@end

@implementation VideoPreviewView

static CATransform3D CATransform3DMakePerspective(CGFloat eyePosition) {    // 3
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}

static CGFloat NHDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

+ (instancetype)loadVideoPreview {
    NSString *nibName = NSStringFromClass(VideoPreviewView.class);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];

    return nibs.firstObject;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}


+ (Class)layerClass {
    return AVCaptureVideoPreviewLayer.class;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)setupView {
    self.faceLayers = NSMutableDictionary.dictionary;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.codeLayers = NSMutableDictionary.alloc.init;
    self.overlayLayer = [CALayer layer];
    self.overlayLayer.frame = self.bounds;
    self.overlayLayer.sublayerTransform = CATransform3DMakePerspective(1000);
    [self.previewLayer addSublayer:self.overlayLayer];
    
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    [self.previewLayer setVideoGravity:videoGravity];
}

- (void)setSession:(AVCaptureSession *)session {
    [self.previewLayer setSession:session];
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)setMaxZoomValue:(NSInteger)value {
    _zoomSlider.maximumValue = value;
}

// 获取屏幕的坐标系转换得的设置坐标系
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = self.previewLayer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

// 获取摄像头的坐标秕转换成屏幕的坐标系
- (CGPoint)pointForCaptureDevicePointOfInterest:(CGPoint)captureDevicePointOfInterest {
    return [self.previewLayer pointForCaptureDevicePointOfInterest:captureDevicePointOfInterest];
}


- (IBAction)startOrstop:(UIButton *)sender {
    
    if (_segmentedControl.selectedSegmentIndex == 1) {
        if (_captureImage) {
            _captureImage();
        }
    } else {
        sender.selected = !sender.selected;
        if (_recordSartOrStop) {
            _recordSartOrStop(sender.selected);
        }
    }
    
}

- (IBAction)switchCamera:(UIButton *)sender {
    sender.selected = !sender.selected;

    if (_switchCamera) {
        _switchCamera(sender.selected);
    }
}

- (void)didDetectCodes:(NSArray *)codes {
    NSArray *transformedCodes = [self transformedCodesFromCodes:codes];
    NSMutableArray *lostCodes = [self.codeLayers.allKeys mutableCopy];
    // 按最新位置添加新的layer层
    for (AVMetadataMachineReadableCodeObject *code in transformedCodes) {
        NSString *stringValue = code.stringValue;
        // 如果 stringValue为 nil，说明没有识别到任何内容，则跳过
        if (stringValue) {
            [lostCodes removeObject:stringValue];
        } else {
            continue;
        }
        
        NSArray *layers = self.codeLayers[stringValue];
        if (!layers) {
            layers = @[[self makeBoundsLayer], [self makeCornersLayer]];
            [self.previewLayer addSublayer:layers.firstObject];
            [self.previewLayer addSublayer:layers.lastObject];
            self.codeLayers[stringValue] = layers;
        }
        // 边界图层
        CAShapeLayer *boundsLayer = layers.firstObject;
        boundsLayer.path = [self bezierPathForBounds:code.bounds].CGPath;
        boundsLayer.hidden = NO;
         // 内部图层
        CAShapeLayer *cornersLayer = layers.lastObject;
        cornersLayer.path = [self bezierPathForCorners:code.corners].CGPath;
        cornersLayer.hidden = NO;
        NSLog(@"条形码内容：%@",stringValue);
    }
    // 删除历史layer
    for (NSString *stringValue in lostCodes) {
        for (CALayer *layer in self.codeLayers[stringValue]) {
            [layer removeFromSuperlayer];
        }
        [self.codeLayers removeObjectForKey:stringValue];
    }
}

-(UIBezierPath *)bezierPathForBounds:(CGRect)bounds {
    return [UIBezierPath bezierPathWithRect:bounds];
}
-(UIBezierPath *)bezierPathForCorners:(NSArray *)corners {
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < corners.count; i++) {
        CGPoint point = [self pointForCorner:corners[i]];
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    return path;
}
-(CGPoint)pointForCorner:(NSDictionary *)corner {
    CGPoint point;
    //corner 包含角点对象的字典具有x值的条目和y值的条目
    CGPointMakeWithDictionaryRepresentation((CGPDFDictionaryRef)corner, &point);
    return point;
}

-(CAShapeLayer *)makeBoundsLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor colorWithRed:0.95 green:0.75 blue:0.06 alpha:1.0].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 4.0;
    return shapeLayer;
    
}
-(CAShapeLayer *)makeCornersLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor colorWithRed:0.172 green:0.671 blue:0.428 alpha:1.0].CGColor;
    shapeLayer.fillColor = [UIColor colorWithRed:0.19 green:0.753 blue:0.489 alpha:0.5].CGColor;;
    shapeLayer.lineWidth = 2.0;
    return shapeLayer;

}

- (NSArray *)transformedCodesFromCodes:(NSArray *)codes {
    NSMutableArray *transformedCodes = [NSMutableArray array];
    for (AVMetadataObject *code in codes) {
        AVMetadataObject *transformedCode = [self.previewLayer transformedMetadataObjectForMetadataObject:code];
        [transformedCodes addObject:transformedCode];
    }
    return transformedCodes;
}


- (IBAction)recode:(UISegmentedControl *)sender {
    
    if (_switchRecordMode) {
        _switchRecordMode(sender.selectedSegmentIndex);
    }
    
}

- (IBAction)switchFlastlightMode:(UISegmentedControl *)sender {
    
    if (_switchFlastlight) {
        _switchFlastlight(sender.selectedSegmentIndex);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_setTouchPoint) {
        _setTouchPoint([[touches allObjects].firstObject locationInView:self]);
    }
}

- (IBAction)subtract:(UIButton *)sender {
    CGFloat value = _zoomSlider.value - 0.5;
    if (_didClickChangeZoomValue) {
        if (value < 0) {
             value = 0;
         }
        _didClickChangeZoomValue(value);
        _zoomSlider.value = value;
    }
}

- (IBAction)add:(UIButton *)sender {
    CGFloat value = _zoomSlider.value + 0.5;
    if (_didClickChangeZoomValue) {
        if (value > _zoomSlider.maximumValue) {
            value = _zoomSlider.maximumValue;
        }
        _didClickChangeZoomValue(value);
        _zoomSlider.value = value;
    }
}

- (IBAction)didChangeSlider:(UISlider *)sender {
    if (_didSliderChangeZoomValue) {
        _didSliderChangeZoomValue(sender.value);
    }
}

- (void)setFaces:(NSArray <AVMetadataFaceObject *>*)faces {
    NSArray *transformedFaces = [self transformedFacesFormFaces:faces];
    NSMutableArray *lostFaces = [self.faceLayers.allKeys mutableCopy];
    // 新的人脸数据
    for (AVMetadataFaceObject *face in transformedFaces) {
        NSNumber *faceID = @(face.faceID);
        [lostFaces removeObject:faceID];
        
        CALayer *layer = self.faceLayers[faceID];
        if (!layer) {
            layer = [CALayer layer];
            layer.borderWidth = 5.0f;
            layer.borderColor = [UIColor colorWithRed:0.188 green:0.517 blue:0.877 alpha:1.0].CGColor;
            [self.overlayLayer addSublayer:layer];
            self.faceLayers[faceID] = layer;
        }
        layer.transform = CATransform3DIdentity;
        layer.frame = face.bounds;
        
        // 斜倾角:
        // 判定人脸是否有倾斜角，如果返回NO，在获取face.rollAngle属性时会报异常
        // face.rollAngle的单位是度，所以进行转换，x y z 分别是 0 0 1，这样会得到一个绕Z轴的斜倾角旋转转换
        if (face.hasRollAngle) {
            // rotate around Z-axis
            CATransform3D t = [self transformForRollAngle:face.rollAngle];
            layer.transform = t;
        }
        // 偏转角
        // face.hasRollAngle
        if (face.hasYawAngle) {
            // rotate around Y-axis
            CATransform3D t = [self transformForYawAngle:face.hasYawAngle];
            layer.transform = t;
        }
    }
    

    
    // 删除历史人脸数据
    for (NSNumber *faceID in lostFaces) {
        CALayer *layer = self.faceLayers[faceID];
        [layer removeFromSuperlayer];
        [self.faceLayers removeObjectForKey:faceID];
    }
}


/// 转换空间
/// @param faces 因元数据位于设备空间，要e使用这一元数据，首先需要将该数据转换到视图坐村系空间
- (NSArray *)transformedFacesFormFaces:(NSArray <AVMetadataFaceObject*>*)faces {
    NSMutableArray *transformedFaces = [NSMutableArray array];
    for (AVMetadataFaceObject *face in faces) {
//        NSLog(@"Face detected with ID：%ld",face.faceID);
//        NSLog(@"Face bounds %@", NSStringFromCGRect(face.bounds));
        
        AVMetadataObject *transformedFace = [self.previewLayer transformedMetadataObjectForMetadataObject:face];
        [transformedFaces addObject:transformedFace];
    }
    
    return transformedFaces;
}

/// rotate around Z-axis
- (CATransform3D)transformForRollAngle:(CGFloat)angle {
    // 首先将角度转在弧度
    CGFloat yawAngleInRadians = NHDegreesToRadians(angle);
    CATransform3D yawTransform = CATransform3DMakeRotation(yawAngleInRadians, 0.0, 0.0, 1.0);
    return CATransform3DConcat(yawTransform, [self orientationTransform]);
}

/// rotate around Y-axis
- (CATransform3D)transformForYawAngle:(CGFloat)angle {
    CGFloat yawAngleInRadians = NHDegreesToRadians(angle);
    CATransform3D yawTransform = CATransform3DMakeRotation(yawAngleInRadians, 0.0, -1.0, 0.0);
    return CATransform3DConcat(yawTransform, [self orientationTransform]);
}

- (CATransform3D)orientationTransform {
    CGFloat angle = 0.0;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI / 2.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI / 2.0f;
            break;
        default:
            angle = 0.0;
            break;
    }
    return CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
}


@end
