//
//  ViewController.m
//  AVFoundation_note
//
//  Created by nenhall on 2019/1/16.
//  Copyright © 2019 nenhall. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()<AVCaptureFileOutputRecordingDelegate>
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (weak, nonatomic) IBOutlet UIView *playerLayer;
@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (strong, nonatomic) AVPlayer *player;
@property (weak, nonatomic) IBOutlet AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) NSURL *outputFileURL;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCameraAuthorization];
    [self createPlayer];

}

- (void)getCameraAuthorization {
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            NSLog(@"相机权限：未设置过权限");
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        NSLog(@"请求授权成功");
                        dispatch_async(dispatch_get_main_queue(), ^{
                        [self createAV];
                        });
                    } else {
                        NSLog(@"请求授权失败");
                    }
                    
                }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        {
            NSLog(@"相机权限：无权访问这项权限");
            
        }
            break;
        case AVAuthorizationStatusDenied:
        {
            NSLog(@"相机权限：拒绝");

        }
            break;
        case AVAuthorizationStatusAuthorized:
        {
            [self createAV];
            NSLog(@"相机权限：已授权");

        }
            break;
     
        default:
            break;
    }
}

- (void)createAV {
    //捕获会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //设置清晰度
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    } else {
        self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    //等价上面的方式创建
//    AVCaptureDevice *device2 = [self deviceWithMediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];

    NSError *getDeviceInputErr;
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&getDeviceInputErr];
    
    if (getDeviceInputErr) {
        NSLog(@"获取输入设备失败");
        return;
    }
    
    
    NSError *getaudioInputErr;
    AVCaptureDevice *audio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audio error:&getaudioInputErr];
    if (getaudioInputErr) {
        NSLog(@"获取音频输入设备失败");
        return;
    }
    
    
    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    _movieFileOutput = movieFileOutput;
    //设置链接管理对象
   AVCaptureConnection *captureConnection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    //设置连接管理对象
    //视频稳定设置
    if ([captureConnection isVideoStabilizationSupported]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    //视频旋转方向的设置
    captureConnection.videoScaleAndCropFactor = captureConnection.videoMaxScaleAndCropFactor;
    

    
    //将创建的所有输入、输出源添加到视频捕捉会话对象
    [_captureSession beginConfiguration];
    
    if ([_captureSession canAddInput:deviceInput]) {
        [_captureSession addInput:deviceInput];
    }
    
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
    }
    
    if ([_captureSession canAddOutput:movieFileOutput]) {
        [_captureSession addOutput:movieFileOutput];
    }

    [_captureSession commitConfiguration];
    
    //创建预览层
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    previewLayer.frame = CGRectMake(0, 0, self.recordView.bounds.size.width, self.recordView.bounds.size.height);
    previewLayer.connection.videoOrientation = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation;
    [self.recordView.layer addSublayer:previewLayer];
    [self.playerLayer setHidden:YES];

    [_captureSession startRunning];

}


- (AVCaptureDevice *)deviceWithMediaType:(AVMediaType)mediaType position:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;

    for (AVCaptureDevice *dinput in devices) {
        if (dinput.position == position) {
            captureDevice = dinput;
        }
    }
    
    return captureDevice;
}

- (IBAction)startREC:(UIButton *)sender {
    [self.playerLayer setHidden:YES];
    [self.recordView setHidden:NO];

    if (sender.selected) {
        [_movieFileOutput stopRecording];
    } else {
        //设置视频存放路径
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@move.mov",NSTemporaryDirectory()]];
        [_movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    }
    sender.selected = !sender.selected;
    
}



- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    
    if (outputFileURL) {
        _outputFileURL = outputFileURL;
        [self createPlayer];
    }
    
    NSLog(@"%s>>>%@",__func__,outputFileURL.absoluteString);
}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    
    NSLog(@"%s",__func__);

}

- (IBAction)play:(UIButton *)sender {
    [self.recordView setHidden:YES];
    [self.playerLayer setHidden:NO];
    
    if (!_outputFileURL) {
        NSLog(@"无效的播放地址");
        return;
    }
    
    NSDictionary *options = @{
                              AVURLAssetPreferPreciseDurationAndTimingKey : [NSNumber numberWithBool:YES]
                              };
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:_outputFileURL options:options];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset automaticallyLoadedAssetKeys:assetKeys];
    [_player replaceCurrentItemWithPlayerItem:playerItem];
    [_player play];
}

- (void)createPlayer {
    NSDictionary *options = @{
                              AVURLAssetPreferPreciseDurationAndTimingKey : [NSNumber numberWithBool:YES]
                              };
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:_outputFileURL options:options];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset automaticallyLoadedAssetKeys:assetKeys];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    _player = player;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.playerLayer.bounds;
    playerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//视频填充模式
    [self.playerLayer.layer addSublayer:playerLayer];
    [player play];

}


//保存视频到相册
- (IBAction)saveVideoToPhoto:(UIButton *)sender {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //方法一
//        [self exportVidelWithUrl:_outputFileURL];
        
        //方法二
        UISaveVideoAtPathToSavedPhotosAlbum(self.outputFileURL.absoluteString, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    });

}

// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    NSLog(@"%@",videoPath);
    NSLog(@"%@",error);
}

//导出视频
- (void)exportVidelWithUrl:(NSURL *)url {
    NSLog(@"压缩前文件大小：%f",[self fileSize:url]);
    
    AVURLAsset *avasset = [[AVURLAsset alloc] initWithURL:url options:nil];
    
    NSArray *exportSessions = [AVAssetExportSession exportPresetsCompatibleWithAsset:avasset];
    
    BOOL containsObj = [exportSessions containsObject:AVAssetExportPresetLowQuality];
    
    if (containsObj) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avasset presetName:AVAssetExportPreset1280x720];
        exportSession.outputURL = [self exportURL];
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"压缩完毕，文件大小：%f",[self fileSize:[self exportURL]]);
                [self saveVidelToPhoto:[self exportURL]];
            } else {
                NSLog(@"压缩进度：%f",exportSession.progress);
                
            }
        }];
        
    }
}

//保存到相册
- (void)saveVidelToPhoto:(NSURL *)outputFileURL {
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存到相册出错");
        } else {
            NSLog(@"保存到相册成功");
        }
    }];
}

- (NSURL *)exportURL {
    return [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"export.mp4"]]];
}


- (CGFloat)fileSize:(NSURL *)path {
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}

@end
