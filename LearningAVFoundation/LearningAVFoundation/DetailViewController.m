//
//  DetailViewController.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/4.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "DetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "LevelPair.h"
#import "LevelMeterColorThreshold.h"
#import "MeterTable.h"
#import "LevelMeterView.h"

#if !TARGET_OS_MACCATALYST
#import <AssetsLibrary/AssetsLibrary.h>
#endif
#import <MediaPlayer/MediaPlayer.h>
#import "AssetImageCell.h"
#import "AVAsset+Additions.h"
#import "VideoPreviewView.h"
#import "UIImage+Additions.h"
#import "OpenGLView.h"
#import "CameraController.h"
#import "SampleDataProvider.h"
#import "WaceformView.h"
#import "MovieWriter.h"
#import "NHCompositionExporter.h"
#import "NHBasicComposition.h"
#import "NHAudioMixComposition.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface DetailViewController ()<AVAudioRecorderDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CameraControllerDelegate,MovieWriterDelegate>
@property (copy)   NSURL *mp3FileURL;
@property (copy)   NSURL *mp4FileURL;
@property (copy)   NSURL *mp4FileURL2;
@property (copy)   NSURL *outputFileURL;
@property (strong) NSMutableArray *speechs;
@property (strong) AVSpeechSynthesizer *synthesizer;
@property (copy) NSArray *voices;
@property (strong) AVAudioPlayer *audioPlayer;
@property (strong) AVAudioPlayer *audioPlayer1;
@property (strong) AVAudioPlayer *audioPlayer2;
@property (strong) AVAudioPlayer *audioPlayer3;
@property (strong) AVAudioRecorder *recorder;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (strong) NSTimer *timer;
@property (strong) MeterTable *meterTable;
@property (nonatomic, strong) LevelPair *levels;
@property (strong) LevelMeterColorThreshold *cThreshold;
@property (strong) CADisplayLink *displayLink;
@property (strong) LevelMeterView *levelMeterView;
@property (strong) AVPlayer *player;
@property (strong) AVPlayerItem *playItem;
@property (strong) NSMutableArray *assetIamges;
@property (strong) AVAssetImageGenerator *imageGenerator;
@property (strong) VideoPreviewView *videoPreview;
@property (weak, nonatomic) IBOutlet UICollectionView *thumnailImageView;
@property (nonatomic, strong) CameraController *cameraController;
@property (nonatomic, strong) OpenGLView *openGLView;
@property (nonatomic, strong) AVAssetReader *assetReader;
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) WaceformView *waceformView;
@property (nonatomic, strong) MovieWriter *movieWriter;
@property (nonatomic, strong) NHCompositionExporter *exporter;
@property (nonatomic, strong) NHAudioMixComposition *audioMixConposition;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"详情";
    self.navigationController.title = @"详情";
    _mp3FileURL = [[NSBundle mainBundle] URLForResource:@"黑龙-38度6" withExtension:@"mp3"];
    _mp4FileURL = [[NSBundle mainBundle] URLForResource:@"天浊地沌混元功" withExtension:@"mp4"];
    _mp4FileURL2 = [[NSBundle mainBundle] URLForResource:@"hubblecast" withExtension:@"m4v"];
    _outputFileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"movie.mov"]];
    _assetIamges = NSMutableArray.alloc.init;

    [_thumnailImageView registerClass:[AssetImageCell class] forCellWithReuseIdentifier:@"AssetImageCell"];
    
    _player = [AVPlayer playerWithURL:_mp3FileURL];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [self.playerView.layer addSublayer:layer];
    layer.frame = _playerView.bounds;
    
    switch (_type) {
        case DetailType1:
            [self buildSpeechString];
            [self speechSynthesizer];
            [self beginConversation];
            break;
        case DetailType2:
            [self buildAudioPlayer];
            [self buildAudioRecorder];
            break;
        case DetailType3:
            [self buildAVAsset];
            break;
        case DetailType4:
            [self buildAVPlay];
            break;
        case DetailType5:
            [self buildAVkit];
            break;
        case DetailType6:
            [self buildCaptureDeveice];
            break;
        case DetailType7:
            [self buildCaptureDeveice];
            [self captureVideoPro];
            break;
        case DetailType8:
            [self AVAssetReader];
            break;
        case DetailType9:
            [self editorMedia];
            break;
        case DetailType10:
            [self editorMedia];
            break;
        case DetailType11:
            [self buildVideoInstruction];
            break;
        case DetailType12:
            [self coreAnimation];
            break;
        default:
            break;
    }
}
#pragma mark - 第一章
- (void)beginConversation {
    for (NSInteger i = 0; i < _speechs.count; i++) {
        //该对象起到队列的作用，提供了接口供控制和监视正在进行的语音播放
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:_speechs[i]];
        utterance.voice = _voices[i % 2];
        utterance.rate = 0.4f; //播放速率
        utterance.pitchMultiplier = 0.8; //声音的音调：一般介于0.5(低音调) - 2.0(高音调)
        utterance.postUtteranceDelay = 0.1; //播放下一语句之前短暂暂停的时间
        [_synthesizer speakUtterance:utterance]; //
    }
}

- (void)speechSynthesizer {
    // 该对象用于执行具体的 文本到语音 会话
    _synthesizer = [[AVSpeechSynthesizer alloc] init];
    // 设置语言
    _voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"],
                [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"]];
}

- (void)buildSpeechString {
    _speechs = [[NSMutableArray alloc] init];
    [_speechs addObject:@"hello world"];
    [_speechs addObject:@"hello jack"];
    [_speechs addObject:@"how are you"];
    [_speechs addObject:@"i'm fine"];
    [_speechs addObject:@"are you ok"];
    [_speechs addObject:@"i'm fine to"];
    [_speechs addObject:@"nice to meet you"];
}


#pragma mark - 第二章
- (void)buildAudioPlayer {
    // iOS2.0 增加了音频播放类
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:_mp3FileURL error:nil];
    if (_audioPlayer) {
        // 调这个方法可以取音频需要的硬件并预加载 Audio queue 的缓冲区，
        // 这个动作是可选的，当调用play方法时会隐性的激活
        // 提前调用可降低play方法和听到声音输出之间的延时
        [_audioPlayer prepareToPlay];
    }
    
//    [_audioPlayer play];
//    [_audioPlayer pause];
    // pause 和 stop 的最主要区别在于底层的处理上，前者只是pause，后者在撤消调用prepareToPlay时所做的设置
//    [_audioPlayer stop];
    
    [self buildAudioPlayer2];
}

- (void)buildAudioPlayer2 {
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"bass" withExtension:@"caf"];
    _audioPlayer1 = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    _audioPlayer1.enableRate = YES;
    _audioPlayer1.rate = 1.0;
    // 让声音极左或者极右 –1.0 is full left, 0.0 is center, and 1.0 is full right.
    _audioPlayer1.pan = -1.0;
    _audioPlayer1.volume = 5.0;
    _audioPlayer1.currentTime = 0.0f;
    // -1无限循环
    _audioPlayer1.numberOfLoops = -1;
    [_audioPlayer1 prepareToPlay];

    fileURL = [[NSBundle mainBundle] URLForResource:@"drums" withExtension:@"caf"];
    _audioPlayer2 = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    _audioPlayer2.pan = 0.0f;
    _audioPlayer2.numberOfLoops = -1;
    [_audioPlayer2 prepareToPlay];

    fileURL = [[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"];
    _audioPlayer3 = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    _audioPlayer3.pan = 1.0;
    _audioPlayer3.numberOfLoops = -1;
    [_audioPlayer3 prepareToPlay];

    
    NSNotificationCenter *nsnc = [NSNotificationCenter defaultCenter];
    [nsnc addObserver:self selector:@selector(handlerInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [nsnc addObserver:self selector:@selector(handlerRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];

}

- (void)handlerRouteChange:(NSNotification *)note {
    NSDictionary *info = note.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    NSLog(@"AVAudioSessionRouteChangeReason:%ld",reason);
    // 上一次的设备不可用时
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        // 描述了不同的 I/O接口属性
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs.firstObject;
        AVAudioSessionPort outputPortType = previousOutput.portType;
        NSLog(@"outputPortType:%@",outputPortType);

        // headphones 头戴耳机：是否为耳机接口
        // BluetoothA2DP 蓝牙 airpod
        if ([outputPortType isEqualToString:AVAudioSessionPortHeadphones] || [outputPortType isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
            [_audioPlayer1 pause];
            [_audioPlayer2 pause];
            [_audioPlayer3 pause];
        } else {

        }
    } else if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        // 描述了不同的 I/O接口属性
        AVAudioSessionPortDescription *previousInput = previousRoute.inputs.firstObject;
        AVAudioSessionPort inputPortType = previousInput.portType;
        
        NSLog(@"inputPortType:%@",inputPortType);
        
        if ([inputPortType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            // AVAudioSessionPortBuiltInMic iPhone 麦克风 / 耳机 接入
            [_audioPlayer1 play];
            [_audioPlayer2 play];
            [_audioPlayer3 play];
        }
    }
}

- (void)handlerInterruption:(NSNotification *)note {
    NSDictionary *info = note.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    // 中断开始
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"AVAudioSessionInterruptionTypeBegan");
        [_audioPlayer1 pause];
        [_audioPlayer2 pause];
        [_audioPlayer3 pause];
    } else {
        NSLog(@"AVAudioSessionInterruptionTypeEnded");
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        // 中断结束，将要恢复
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            [_audioPlayer1 play];
            [_audioPlayer2 play];
            [_audioPlayer3 play];
        }
    }
}

-(void)buildAudioRecorder {
    // 音频写入的地址
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"voice.m4a"];
    NSURL *URL = [NSURL fileURLWithPath:filePath];
    // 可查看 avfoundation/avAudioSettings.h
    NSDictionary *settings = @{
        // 所录制音频格式一定要和URL参数定义的文件类型兼容，如 voice.m4a -> kAudioFormatMPEG4AAC
        AVFormatIDKey : @(kAudioFormatMPEG4AAC),
        //采样率：每秒内的采样数，将影响着音频质量和最终文件大小，具体多少没有明确规定，标准的采样率有：8000 16000 22050 44100
        AVSampleRateKey : @22050.0f,
        //通道数：1意味首使用单声道录制， 2使用立体声录制；除非使用外部硬件录制，否则通常应该为单声道录制
        AVNumberOfChannelsKey : @1,
        AVEncoderBitDepthHintKey : @16, //位深
        AVEncoderAudioQualityKey : @(AVAudioQualityMedium)
        //其它键：在Xcode帮助文档中 AV Foundation Audio Settings Contants 引用中找到完整的列表
    };
    
    NSError *error;
    // iOS3.0 增加了音频录制类
    _recorder = [[AVAudioRecorder alloc] initWithURL:URL settings:settings error:&error];
    _recorder.delegate = self;
    if (_recorder) {
        // 这个方法和 prepareToPlay 类似，为audio queue 初始化的必要过程
        [_recorder prepareToRecord];
    }
    if (error) {
        NSLog(@"创建 avaudio recorder failed:%@",error.localizedDescription);
    }
    _recorder.meteringEnabled = YES;
    _meterTable = [[MeterTable alloc] init];
    _levelMeterView = [[LevelMeterView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_timeLabel.frame) + 60, self.view.bounds.size.width - 40, 20)];
    _levelMeterView.backgroundColor = _timeLabel.backgroundColor;
    [self.view addSubview:_levelMeterView];
}

#pragma mark <AVAudioRecorderDelegate>
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur:%@",error.localizedDescription);
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    _audioPlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    [_audioPlayer play];
}

- (LevelPair *)levels {
    // 每次分贝的值，都需要调用此方法才能获取最新值
    [self.recorder updateMeters];
    // range: -160 - 0,一个平均值
    float avgPower = [self.recorder averagePowerForChannel:0];
    // range: -160 - 0,取一个峰值
    float peakPower = [self.recorder peakPowerForChannel:0];
    float linearLevel = [self.meterTable valueForPower:avgPower];
    float linearPeak = [self.meterTable valueForPower:peakPower];
    return [LevelPair levelsWithLevel:linearLevel peakLevel:linearPeak];
}

- (void)startMeterTimer {
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
    // 时间间隔为刷新率的1/4
    self.displayLink.frameInterval = 5;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stoptMeterTimer {
    [self.displayLink invalidate];
    _displayLink = nil;
    [self.levelMeterView resetLevelMeter];
}

- (void)updateMeter {
    self.levelMeterView.level = self.levels.level;
    self.levelMeterView.peakLevel = self.levels.peakLevel;
    
    [self.levelMeterView setNeedsDisplay];
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTime {
    self.timeLabel.text = [self formattedCurrentTime];
}

- (NSString *)formattedCurrentTime {
    NSUInteger time = (NSUInteger)self.recorder.currentTime;
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;

    NSString *format = @"%02i:%02i:%02i";
    return [NSString stringWithFormat:format, hours, minutes, seconds];
}

#pragma mark - 第三章 资源和元数据
- (void)buildAVAsset {
#if !TARGET_OS_MACCATALYST
    // iOS 4.0 增加的对媒体资源的捕捉、组合、播放和处理
    // NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey: @YES };
    // AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:_mp3FileURL options:options];
    // NSLog(@"%@",urlAsset);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // 读取保存在 `Saved Photos` 组中的视频资源
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // 过滤，提取所有视频
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if (group.numberOfAssets) {
                    [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *stop) {
                        if (alAsset) {
                            ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                            NSURL *url = [representation url];
                            AVAsset *asset = [AVAsset assetWithURL:url];
                            if (asset) {
            //                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            //                    [self.player replaceCurrentItemWithPlayerItem:playerItem];
            //                    [self.player play];
                            }
                            NSLog(@"representation:%@",representation.url);
                        }
                    }];
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
#endif
    
    [self buildAVAssetFromIPod];
}

#pragma mark 获取用户 iPod 音乐库
- (void)buildAVAssetFromIPod {
    // 获取用户 iPod 音乐库 , 需要在plist文件中添加权限字段： NSAppleMusicUsageDescription
    //MPMediaPropertyPredicate：用于构建用户查询具体内容所用的查询语句
    // 下面语句表示：在 Foo Fighters 的 In Your Honor 唱片中查找Best of You 这首歌
//    MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:@"Foo Fighters" forProperty:MPMediaItemPropertyArtist];
//    MPMediaPropertyPredicate *albumPredicate = [MPMediaPropertyPredicate predicateWithValue:@"In Your Honor" forProperty:MPMediaItemPropertyAlbumTitle];
//    MPMediaPropertyPredicate *songPredicate = [MPMediaPropertyPredicate predicateWithValue:@"Best of You" forProperty:MPMediaItemPropertyTitle];
    
    MPMediaPropertyPredicate *songPredicate = [MPMediaPropertyPredicate predicateWithValue:@"烟火里的尘埃-华晨宇" forProperty:MPMediaItemPropertyTitle];
    
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
//    [query addFilterPredicate:artistPredicate];
//    [query addFilterPredicate:albumPredicate];
    [query addFilterPredicate:songPredicate];
    
    // 获取所有歌曲
//    query = [MPMediaQuery songsQuery];
    
    NSArray *results = [query items];
    if (results.count > 0) {
        MPMediaItem *item = results.firstObject;
        NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
        AVAsset *asset = [AVAsset assetWithURL:assetURL];
        if (asset) {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            [_player replaceCurrentItemWithPlayerItem:playerItem];
            [_player play];
        }
        
        NSArray *keys = @[@"availableMetadataFormats"];
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
            NSMutableArray *metadata = [NSMutableArray array];
            for (NSString *format in asset.availableMetadataFormats) {
                if ([format isEqualToString:AVMetadataFormatiTunesMetadata]) {
                    NSArray *iTMetadata = [asset metadataForFormat:AVMetadataFormatiTunesMetadata];
                    for (AVMetadataItem *item in iTMetadata) {
                        NSLog(@"%@: %@: keyString%@:", item.key, item.value, item.keyString);
                    }
                }

                [metadata addObjectsFromArray:[asset metadataForFormat:format]];
            }
            NSLog(@"%@",metadata);
            
            AVMetadataItem *mdataItem = metadata.count > 0 ? metadata.firstObject : nil;
            NSString *keyString = mdataItem.keyString;
//            NSString *keySpace = @"org.id3";
            NSString *keySpace = AVMetadataKeySpaceiTunes;

            NSArray *artistMetadata = [AVMetadataItem metadataItemsFromArray:metadata withKey:AVMetadataiTunesMetadataKeyArtist keySpace:keySpace];
            NSArray *albumMetadata = [AVMetadataItem metadataItemsFromArray:metadata withKey:AVMetadataiTunesMetadataKeyAlbum keySpace:keySpace];
            AVMetadataItem *artistItem, *albumItem;
            if (artistMetadata.count > 0) {
                artistItem = artistMetadata[0];
            }
            
            if (albumMetadata.count > 0) {
                albumItem = albumMetadata[0];
            }
            
            NSLog(@"%@ - %@",artistItem, albumItem);

        }];
        
        NSLog(@"MPMediaQuery.assetURL:%@", assetURL);
    }
    
    [self asyncLoading];
    [self readMetedata];
#if TARGET_OS_OSX
    // 在Mac OS 上，iTunes是用户的中心媒体资源库，要识别这个库中的资源，开发者需要对iTunes音乐目录中的iTunes music library.xml   文件进行解析，但在macOS 10.8和iTunes 11.0开始有了更简单的方法，源自于iTunesLibrary框架
    // 下在这段代码只能在 macOS 下运行
    NSError *error;
    ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.0" error:&error];
    NSArray *items = library.allMediaItems;
    // 查询条件
    NSString *query = @"artist.name == 'Robert Johnson' AND"
    "album.title == 'king of the Delta Blues Singers' AND"
    "title == 'Cross Road Blues'";
    // 构建一个查询类
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    NSArray *songs = [items filteredArrayUsingPredicate:predicate];
    if (songs.count) {
        ITLibMediaItem *item = songs[0];
        AVAsset *asset = [AVAsset assetWithURL:item.location];
        // ...
        NSLog(@"ITLibMediaItem.URL:%@",item.location);
    }
#endif
}

#pragma mark avasset 异步导入
- (void)asyncLoading {
    AVAsset *asset = [AVAsset assetWithURL:_mp3FileURL];
    NSArray *keys = @[@"tracks"];
    // 不管你传多少个keys，回调都只会调用一次
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error;
        // 加载完后，通过 `statusOfValueForKey:error:` 来分别获取对应状态
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        NSLog(@"%ld",status);
        switch (status) {
            case AVKeyValueStatusLoaded:

                break;
            case AVKeyValueStatusFailed:
                
                break;
            case AVKeyValueStatusCancelled:
                
                break;
            default:
                break;
        }
    }];
}

#pragma mark avasset 读取元数据
- (void)readMetedata {
    //  AV Foundation 使用键空间作为将相关键组合在一起的方法，可以实现对AVMetadataItem 实例集合的筛选，每个资源至少包含两个键空间，供从中获取元数据
    
    // 1, 访问元数据
    AVAsset *asset = [AVAsset assetWithURL:_mp3FileURL];
    NSArray *keys = @[@"availableMetadataFormats"];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSMutableArray *metadata = [NSMutableArray array];
        for (NSString *format in asset.availableMetadataFormats) {
            [metadata addObjectsFromArray:[asset metadataForFormat:format]];
        }
//        NSLog(@"%@",metadata);
    }];
    
    //2， 查找元数据
    

}

- (void)metaManager {
    
}

static const NSString *playerItemStatusContext;

#pragma mark - 第四章 视频播放
- (void)buildAVPlay {
    NSArray *keys = @[@"tracks", @"duration",@"commonMetadata"];
    AVAsset *asset = [AVAsset assetWithURL:_mp4FileURL];
    _playItem = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:keys];
    [_playItem addObserver:self forKeyPath:@"status" options:0 context:&playerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:_playItem];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _player.allowsExternalPlayback = YES;
    [self.playerView.layer addSublayer:layer];
    layer.frame = _playerView.bounds;
    [_player play];
    
    // AirPlay功能
    MPVolumeView *volumeView = MPVolumeView.alloc.init;
//    volumeView.frame = CGRectMake(CGRectGetMaxX(_playerView.frame) - 50, CGRectGetMaxY(_playerView.frame) - 50, 0, 0);
    volumeView.showsVolumeSlider = YES;
//    [volumeView sizeToFit];
    [_playerView addSubview:volumeView];
    
}


/// 监听播放结束通知
- (void)addItemEndObserverForPlayerItem {
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    __weak DetailViewController *weakself = self;
    void (^callBlock)(NSNotification *note) = ^(NSNotification *note) {
        [weakself.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            NSLog(@"播放完成");
        }];
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:name object:self.playItem queue:queue usingBlock:callBlock];

}

- (void)getAssetImages {

    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.playItem.asset];
    // 设置图片的尺寸，设置此属性会对图片进行缩放并提高显能
    // 设置width，heigt为0，这样可以确保生成的图片都遵循了一定的y宽度，并且会根据视频的宽度比自动设置高度
    self.imageGenerator.maximumSize = CGSizeMake(200, 0.f);
    CMTime duration = self.playItem.asset.duration;
    
    NSMutableArray *times = NSMutableArray.array;
    // 把视频分成20个时间值
    CMTimeValue increment = duration.value / 20;
    CMTimeValue currentValue = 0;
    while (currentValue <= duration.value) {
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    }
    
    __block NSUInteger imageCount = times.count;
    __block NSMutableArray *images = NSMutableArray.array;
    __weak DetailViewController *weakself = self;
    AVAssetImageGeneratorCompletionHandler handler;
    // requestedTime：请求最初的时间，它对应于生成图片的调用中指定的times数组中的值
    // imageRef：生成的CGImageRef，没有在指定时间没有生成图片则为NULL
    // actualTime: 图片实际r生成的时间，基于实际效率，这个值可能与请求时间不同，
    // 但可以通过rquestedTimeToleranceBefore 与 requestedTimeToleranceAfter值来调整 requestedTime和actualTime的接近程度
    // result：用来表示图片生成成功还是失败
    handler = ^(CMTime requestedTime, CGImageRef imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            [weakself.assetIamges addObject:image];
        } else {
            NSLog(@"failed to creat thumnail image");
        }
        
        if (--imageCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // do sth ing
                [weakself.thumnailImageView reloadData];
            });
        }
    };
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
    
}


#pragma mark - 第五章 AVKit 用法
// AVKit从ios8开始引入到ios平台的，之前是存在于mac平台
-(void)buildAVkit {
    
    AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
    // 播放控件显示隐藏控制
    playerController.showsPlaybackControls = YES;
    playerController.player = [AVPlayer playerWithURL:_mp4FileURL];
    // 视频的填充模式
//    playerController.videoGravity = AVLayerVideoGravityResizeAspect;
    // 通过观察这个布尔值来确实视频内容是否已经准备好
//    playerController.readyForDisplay
    [self.navigationController pushViewController:playerController animated:YES];
    
    
#if !TARGET_OS_IPHONE
    // 下面这段代码需要在macos下才能运行
    /**
        NSURL * _mp4FileURL = [[NSBundle mainBundle] URLForResource:@"天浊地沌混元功" withExtension:@"mp4"];
         _mp4FileURL = [[NSBundle mainBundle] URLForResource:@"hubblecast" withExtension:@"m4v"];
     //    _mp4FileURL = [NSURL URLWithString:@"http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"];
         AVPlayerView *playerView = AVPlayerView.alloc.init;
         playerView.frame = self.view.bounds;
         playerView.controlsStyle = AVPlayerViewControlsStyleFloating;
         playerView.player = [AVPlayer playerWithURL:_mp4FileURL];
         playerView.showsSharingServiceButton = YES;
         playerView.showsFullScreenToggleButton = YES;
     //    playerView.showsTimecodes = YES;
         [self.view addSubview:playerView];
     */
#endif
    // 查找语言章节
    AVAsset *asset = [AVAsset assetWithURL:_mp4FileURL];
    __block NSString *keys = @"availableChapterLocales";
    [asset loadValuesAsynchronouslyForKeys:@[keys] completionHandler:^{
        AVKeyValueStatus status = [asset statusOfValueForKey:keys error:nil];
        if (status == AVKeyValueStatusLoaded) {
            NSArray *langs = [NSLocale preferredLanguages];
            NSArray *chapterMetadata = [asset chapterMetadataGroupsBestMatchingPreferredLanguages:langs];
            NSLog(@"%@",chapterMetadata);
        }
    }];
}


#pragma mark - 第六章 媒体捕捉
- (void)buildCaptureDeveice {
    
    _cameraController = [[CameraController alloc] init];
    _cameraController.delegate = self;
    
    /**
     AVLayerVideoGravityResizeAspect 在承载区域内缩放，保持视频有的是始的宽高比，默认值
     AVLayerVideoGravityResizeAspectFill 按照视频的宽高比将视频拉伸填满
     AVLayerVideoGravityResize 拉伸视频内容，以匹配承载层大小，不保持视频原有的宽高比
     */
    
     // 预览及功能控制层
    self.videoPreview = [VideoPreviewView loadVideoPreview];
    self.videoPreview.session = _cameraController.session;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.videoPreview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }

    [self.view addSubview:self.videoPreview];
    self.videoPreview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoPreview.frame = self.view.bounds;
    __weak DetailViewController *weakself = self;
    // 切换前后摄像头
    [self.videoPreview setSwitchCamera:^(NSUInteger type) {
        [weakself.cameraController switchCameras];
    }];
    // 设置闪光灯模式
    [self.videoPreview setSwitchFlastlight:^(NSUInteger type) {
        /**
         AVCaptureFlashModeOff  = 0, 总是关
         AVCaptureFlashModeOn   = 1, 总是开
         AVCaptureFlashModeAuto = 2, 跟据环境自动
         */
        [weakself.cameraController setFlashModel:type];
    }];
    // 设置录制模式
    [self.videoPreview setSwitchRecordMode:^(NSUInteger type) {
        
    }];
    // 开始或者停止录制
    [self.videoPreview setRecordSartOrStop:^(NSUInteger type) {
        if (weakself.type == DetailType8) {
            if (weakself.movieWriter.isWriting) {
                [weakself.movieWriter stopWriting];
            } else {
                [weakself.movieWriter startWriting];
            }
        } else {
            if (type == 1) {
                [weakself.cameraController stopRecording];
                AVCaptureConnection *connection = [weakself.cameraController.movieOutput connectionWithMediaType:AVMediaTypeVideo];
                //预览图层和视频方向保持一致
                if ([connection isVideoOrientationSupported]) {
                    connection.videoOrientation = [weakself currentVideoOrientation];
                }
                // 视频稳定防抖功能，这个效果无法在视频内看到
                if ([connection isVideoStabilizationSupported]) {
                    connection.enablesVideoStabilizationWhenAvailable = YES;
                    // ios 8.0以后
                    // connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
                }
                [weakself.cameraController startRecordingToOutputFileURL:weakself.outputFileURL];
            } else {
                [weakself.cameraController stopRecording];
            }
        }
    }];
    [self.videoPreview setCaptureImage:^{
        AVCaptureConnection *connection = [weakself.cameraController.imageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (connection.isVideoOrientationSupported) {
//            connection.videoOrientation = [self currentVideoOrientation];
        }
        [weakself.cameraController.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            NSLog(@"拍照完成");
            [weakself writeImageToAssetsLibrary:image];
        }];
    }];
    // 对焦
    [self.videoPreview setSetTouchPoint:^(CGPoint point) {
        [weakself.cameraController focusAtPoint:point];
        [weakself.cameraController exposeAtPoint:point];
    }];
    
    
    [_cameraController.session startRunning];
}

- (void)writeImageToAssetsLibrary:(UIImage *)image {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusDenied) {
        // 拒绝 ...
        
    } else {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(NSInteger)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"图片保存结果：%@ error：%@",assetURL,error);
        }];
    }
}

- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}


#pragma mark - 第七章 高级捕捉功能
- (void)captureVideoPro {
    [self.playerView setHidden:YES];
    [self.thumnailImageView setHidden:YES];
    
    [self.cameraController switchCameras];
    
//    [_videoPreview setMaxZoomValue:[self activeCamera].activeFormat.videoMaxZoomFactor];
    __weak DetailViewController *weakself = self;
    [_videoPreview setDidClickChangeZoomValue:^(CGFloat value) {
        [weakself.cameraController setZoomValue:value];
    }];
    [_videoPreview setDidSliderChangeZoomValue:^(CGFloat value) {
        [weakself.cameraController rampZoomToValue:value];
    }];
    
    // 添加监听缩放状态监听
//    [[self activeCamera] addObserver:self forKeyPath:@"videoZoomFator" options:0 context:nil];
    // 人脸识别
    if (0) {
        [self.cameraController setupSessionOutputs:nil];
    } else {
        // 条形码识别
        [self.cameraController setupSessionOutputs2:nil];
    }
    
    // 支持高帧率捕捉";
    [self highFrameRateCapture];
    
    // 操作 sampleBuffer
//    [self sampleBuffer];
}



#pragma mark 高帧率捕捉
// ios7.0开始支持，iphone 5s可以支持120fps，如可以用来做慢动作
// 框架支持60fps帧率捕捉 720p视频，或在iphone 5s中将帧率提高到120fps，并带有视频稳定技术，此外还可以支持启用droppable P-frames的 h.264 特性，保证高帧率内容可以在旧设备上流畅播放
- (void)highFrameRateCapture {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    label.center = self.view.center;
    [self.view addSubview:label];
    if ([self.cameraController supportsHighFrameRateCapture]) {
        // 打开下面这个if将会同时开启高帧率捕捉
        //        if ([[self activeCamera] enableHighFrameRateCapture:nil]) {
        label.text = @"支持高帧率捕捉";
        //        } else {
        //            label.text = @"不支持高帧率捕捉";
        //        }
    } else {
        label.text = @"不支持高帧率捕捉";
        
    }
}

#pragma mark CMSampleBuffer
- (void)sampleBuffer {
    [self.cameraController removeMovieOutput];
    [self.cameraController addVideoOutput];
    
//    [self.videoPreview setSession:nil];
//    [self.videoPreview removeFromSuperview];
//    self.videoPreview = nil;
    
    
    _openGLView = OpenGLView.alloc.init;
    [self.view addSubview:_openGLView.view];
    _openGLView.view.frame = self.view.bounds;

}

#pragma mark - 第八章 读取和写入媒体
- (void)AVAssetReader {
    // 读取媒体
//    [self readerAsset];
 
    // 读取音频样本
//    [self readerAudioSample];
    
    // 媒体捕捉、写入
    [self captureAndWrite];
}

#pragma mark readerAsset
- (void)readerAsset {
       NSError *error;
        AVAsset *asset = [AVAsset assetWithURL:_mp4FileURL2];
        AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        
        NSDictionary *readerOutputSetting = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
        
        // 从资源的轨道读取样本，将视频帧解压缩为BGRA格式
        AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc
                                                  ]initWithTrack:track outputSettings:readerOutputSetting];
        [assetReader addOutput:trackOutput];
        [assetReader startReading];
        _assetReader = assetReader;
        
        // 创建一个写入对象，并设置写入路径，及文件类型
        // 与AVAssetExportSession相比，AVAssetWriter的明显优势就是它对输出进行编码时能够进行更加细致的置控制
        NSString *oldPath = [NSString stringWithFormat:@"%@movie.mov",NSTemporaryDirectory()];
        if ([[NSFileManager defaultManager] fileExistsAtPath:oldPath]) {
            BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
            if (removed) {
                NSLog(@"历史文件删除结果：%d",removed);
            }
        }

        _assetWriter = [[AVAssetWriter alloc] initWithURL:_outputFileURL fileType:AVFileTypeQuickTimeMovie error:&error];
        // 相应的媒体输出设置
        NSDictionary *writeOutputSetting = @{ AVVideoCodecKey:AVVideoCodecH264,
                                              AVVideoWidthKey:@1280,
                                              AVVideoHeightKey:@720,
                                              AVVideoCompressionPropertiesKey: @{
                                                      AVVideoMaxKeyFrameIntervalKey:@1,
                                                      AVVideoAverageBitRateKey: @10500000,
                                                      AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31
                                              }
        };
        
        AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:writeOutputSetting];
        [self.assetWriter addInput:writerInput];
        CGFloat offset = self.view.bounds.size.height * 0.5 - 40;
        UILabel *load = [[UILabel alloc] initWithFrame:CGRectMake(50, offset, 200, 30)];
        load.backgroundColor = [UIColor blackColor];
        load.textColor = UIColor.whiteColor;
        load.text = @"正在写入数据...";
        [self.view addSubview:load];
        
        [self.assetWriter startWriting];
        // 写入的开始时间
        [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    //    self.assetWriter endSessionAtSourceTime:<#(CMTime)#>
        dispatch_queue_t writerQueue = dispatch_queue_create("com.nenhall.writerQueue", NULL);
        // 去资源中请求数据
        [writerInput requestMediaDataWhenReadyOnQueue:writerQueue usingBlock:^{
            BOOL complete = NO;
            while ([writerInput isReadyForMoreMediaData] && !complete) {
                CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
                
                if (sampleBuffer) {
                    BOOL result = [writerInput appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                    complete = !result;
                } else {
                    [writerInput markAsFinished];
                    complete = YES;
                }
            }
            
            if (complete) {
                // 请求完成，关闭会话，并确认成功与失败
                [self.assetWriter finishWritingWithCompletionHandler:^{
                    AVAssetWriterStatus status = self.assetWriter.status;
                    if (status == AVAssetWriterStatusCompleted) {
                        NSLog(@"完成写入");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            load.text = @"数据写入完成";
                        });
                    } else {
                        NSLog(@"写入失败:%@",self.assetWriter.error.localizedDescription);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            load.text = [NSString stringWithFormat:@"数据写入失败：%@",self.assetWriter.error.localizedDescription];
                        });
                    }
                }];
            }
        }];
}

#pragma mark 读取音频样本
- (void)readerAudioSample {
    CGFloat offset = self.view.bounds.size.height * 0.5;
    _waceformView = [[WaceformView alloc] initWithFrame:CGRectMake(0, offset, self.view.bounds.size.width, 89)];
    _waceformView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _waceformView.waveColor = [UIColor colorWithRed:0.749 green:0.861 blue:0.994 alpha:1.000];
    _waceformView.backgroundColor = [UIColor colorWithRed:0.142 green:0.270 blue:0.438 alpha:1.000];
    [self.view addSubview:_waceformView];

    NSURL *keys = [[NSBundle mainBundle] URLForResource:@"keys" withExtension:@"mp3"];
    AVAsset *asset = [AVAsset assetWithURL:keys];
    [_waceformView setAsset:asset];
}

#pragma mark 媒体捕捉、写入
- (void)captureAndWrite {

    [self buildCaptureDeveice];
    [self.cameraController addVideoOutput];
    [self.cameraController addAudioOutput];
    
    NSString *fileType = AVFileTypeQuickTimeMovie;
    NSDictionary *videoSetting = [self.cameraController.videoOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:fileType];
    NSDictionary *audioSetting = [self.cameraController.audioOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:fileType];
    dispatch_queue_t queue = dispatch_queue_create("com.nenhall.video.queue", 0);

    _movieWriter = [[MovieWriter alloc] initWithVideoSetting:videoSetting audioSetting:audioSetting  dispatchQueue:queue];
    _movieWriter.delegate = self;
    
}

#pragma mark - 第九章 媒体的组合和编辑
#pragma mark - 第十章 混合音频
- (void)editorMedia {
    /**
     CMTime:
        * CMTimeValue    value
        * CMTimeScale    timescale
        * CMTimeFlags    flags
        * CMTimeEpoch    epoch
     CMTimeValue、CMTimeScale是CMTime 元素的分数形式
     CMTimeFlags 是一个位掩码，用于表示时间的指定状态，如判定数据是否有效
     如创建一个代表3秒的 CMTime：
     CMTimeMake(3, 1) // 3/1=3
     CMTimeMake(1800, 600) // 1800/6=3
     */
    
    /**
     CMTimeRange:
        * CMTime            start; // 时间范围的起点
        * CMTime            duration; // 时间范围的持续时间
     如定义一个从时间轴5秒位置开始，持续时长5秒的CMTimeRange
     CMTimeRangeMake(CMTimeMake(5, 1), CMTimeRangeMake(5, 1))
     CMTimeRangeFromTimeToTime(CMTimeMake(5, 1), CMTimeMake(10, 1))
     上面两方法创建出来的`CMTimeRange`是完全等价的
    */
    
    CMTimeRange range1 = CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1));
    CMTimeRange range2 = CMTimeRangeMake(CMTimeMake(2, 1), CMTimeMake(5, 1));

    // 两时间范围的交叉时间范围
    CMTimeRange intersectionRange = CMTimeRangeGetIntersection(range1, range2);
    CMTimeRangeShow(intersectionRange); // {{2/1 = 2.000}, {3/1 = 3.000}}
    
    // 两时间范围的总和
    CMTimeRange unionRange = CMTimeRangeGetUnion(range1, range2);
    CMTimeRangeShow(unionRange); // {{0/1 = 0.000}, {7/1 = 7.000}}
    
    // 插入时间起点
    CMTime cursorTime = kCMTimeZero;
    // 捕捉视频的时长，加上面零为起点，就等0秒位置起，持续5秒的位置
    CMTime videoDuration = CMTimeMake(5, 1);
    CMTimeRange videoTimeRange = CMTimeRangeMake(cursorTime, videoDuration);
    
    AVAssetTrack *assetTrack;
    AVAsset *goldenGateAsset = [AVAsset assetWithURL:_mp4FileURL];
    AVAsset *teaCardenAsset = [AVAsset assetWithURL:_mp4FileURL2];
    AVAsset *soundtrackAsset = [AVAsset assetWithURL:_mp3FileURL];
    
    // 创建轨道对象，并指定它所支持的媒体类型：AVMediaTypeVideo、AVMediaTypeAudio
    // preferredTrackID: 这是一个32位整数，虽然我们可以传递任意标识作为参数
    // 但这个标识我们之后需要返回轨道时会用到，一般来说都是赋给它一个kCMPersistentTrackID_Invalidi常量
    // 我们将这个常量的意思：我们需要创建一个合适的轨道ID的任务委托给框架，标识符会以1...n排列，
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 提取媒体的视频数据，因为这个媒体只包含一个单独的视频轨道，所以直接取第一个，实际开发中，请跟据媒体来确定是否需要做其它判定
    assetTrack = [goldenGateAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    // 插入视频
    [videoTrack insertTimeRange:videoTimeRange ofTrack:assetTrack atTime:cursorTime error:nil];
    
    // 使用 CMTimeAdd 来移动光标的插入时间，将 videoDuration 和当前 cursorTime 值相加，这会向前移动光标
    cursorTime = CMTimeAdd(cursorTime, videoDuration);
    assetTrack = [teaCardenAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    [videoTrack insertTimeRange:videoTimeRange ofTrack:assetTrack atTime:cursorTime error:nil];
    
    // 我们希望音频轨道覆盖整个视频剪辑，所以重新设 cursorTime
    // audioDuration为整个组合的时长
    cursorTime = kCMTimeZero;
    CMTime audioDuration = composition.duration;
    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioDuration);
     
    assetTrack = [soundtrackAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    [audioTrack insertTimeRange:audioTimeRange ofTrack:assetTrack atTime:cursorTime error:nil];
    
    UIActivityIndicatorView *_loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingView.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 25, self.view.bounds.size.height * 0.5 - 25, 50, 50);
    [self.view addSubview:_loadingView];
    [_loadingView startAnimating];
    CGFloat offset = self.view.bounds.size.height * 0.5 - 70;
    UILabel *load = [[UILabel alloc] initWithFrame:CGRectMake(50, offset, 200, 30)];
    load.backgroundColor = [UIColor blackColor];
    load.textColor = UIColor.whiteColor;
    [self.view addSubview:load];
    
    if (_type == DetailType9) {
        load.text = @"正在组合媒体...";
        NHBasicComposition *bComposition = [NHBasicComposition compositionWithComposition:composition];
        _exporter = [[NHCompositionExporter alloc] initWithComposition:bComposition];
        [_exporter beginExport];
        [_exporter exportCompletionHandler:^{
            [_loadingView stopAnimating];
            [load setHidden:YES];
        }];
        
    } else if (_type == DetailType10) {
        load.text = @"混合音频...";
        AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        [parameters setVolume:0.1 atTime:kCMTimeZero];
        CMTime twoSeconds = CMTimeMake(2, 1);
        CMTime fourSeconds = CMTimeMake(10, 1);
        
        CMTimeRange range = CMTimeRangeFromTimeToTime(twoSeconds, fourSeconds);
        /**
         * setVolume: atTime:
            在指定时间点立即调节音量，音量在音频轨道持续时间内保持不变，直到有另一个音量调节出现

         * setVolumeRampFromStartVolume: toEndVolume: timeRange:
            允许在一个给定时间范围内平滑地将音量从一个值调节到另一个值，当需要在一个时间范围内调整音量时，
            音量会立即变为指定值的初始音量并在持续时间之内逐渐调整为指定的结束值
         */
        [parameters setVolumeRampFromStartVolume:1.0 toEndVolume:0.1 timeRange:range];
        [parameters setVolume:0.3f atTime:CMTimeMake(7, 1)];
        
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = @[ parameters ];
        
        _audioMixConposition = [NHAudioMixComposition compositionWithComposition:composition audioMix:audioMix];
        [_audioMixConposition makeExportable];
        _exporter = [[NHCompositionExporter alloc] initWithComposition:_audioMixConposition];
        [_exporter beginExport];
        [_exporter exportCompletionHandler:^{
            [_loadingView stopAnimating];
            [load setHidden:YES];
        }];

    }

}

#pragma mark - 第十一章 创建视频过渡效果
- (void)buildVideoInstruction {
    /**
     * AVVideoCompositionLayerInstruction
        用于定义对给定视频轨道应用的模糊、变形、裁剪效果，它提供了一些方法用于在特定的时间点或者一个时间范围内对这些值进行修改
     * AVVideoCompositionInstruction
        
     */
    
    
    NSError *error;
    // 获取 AVAsset 资源
    AVAsset *goldenGateAsset = [AVAsset assetWithURL:_mp4FileURL];
    AVAsset *teaCardenAsset = [AVAsset assetWithURL:_mp4FileURL2];
    AVAssetTrack *assetTrack = [goldenGateAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVAssetTrack *assetTrack2 = [teaCardenAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;

    // 创建一个视频组合层
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 添加视频轨道
    AVMutableCompositionTrack *mCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    // 把视频资料插入到视频轨道
    CMTime beginTime = kCMTimeZero;
    [mCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(2, 1)) ofTrack:assetTrack atTime:beginTime error:&error];
    
    CMTime time2 = CMTimeAdd(beginTime, CMTimeMake(2, 1));
    [mCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(3, 1)) ofTrack:assetTrack2 atTime:time2 error:&error];
    
    NSArray *tracks = [composition tracksWithMediaType:AVMediaTypeVideo];
    // 创建视频指令层
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    // 设置时间范围
    instruction.timeRange = CMTimeRangeMake(CMTimeMake(4, 1), CMTimeMake(6, 1));
    // AVVideoCompositionLayerInstruction的可变子类，用于修改变换，裁剪和不透明度渐变以应用于合成中的给定轨道
    AVMutableVideoCompositionLayerInstruction *layerIntruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:tracks.lastObject];
    
    CMTimeRange timeRange = instruction.timeRange;
//    [layerIntruction setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:timeRange];
    
    // AVVideoCompositionLayerInstruction的可变子类，用于修改变换，裁剪和不透明度渐变以应用于合成中的给定轨道
    AVMutableVideoCompositionLayerInstruction *layerIntruction2 = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:tracks.lastObject];
    
    CGFloat videoWidth = composition.naturalSize.width;
    CGAffineTransform fromDestTransform = CGAffineTransformMakeTranslation(-videoWidth, 0.0);
    CGAffineTransform toStartTransform = CGAffineTransformMakeTranslation(videoWidth, 0.0);
    // 设置 fromLayer 的渐变效果，终点变换设置为 fromDestTransform
    // 这样就会在 timeRange时间内实现fromLayer向左侧退出的动画效果
    [layerIntruction2 setTransformRampFromStartTransform:fromDestTransform toEndTransform:toStartTransform timeRange:timeRange];
    // toLayer 上设置一个渐变效果，初始变换设置为 toStartTransform，终点变换设置为 identityTransform
    // 这样就在 timeRange 时间内实现 toLayer 从右侧进入的动画效果
    [layerIntruction setTransformRampFromStartTransform:toStartTransform toEndTransform:fromDestTransform timeRange:timeRange];
    
    
    instruction.layerInstructions = @[ layerIntruction, layerIntruction2 ];
    
    /**
     * 视频组合类的便捷的初始化方法
     [AVVideoComposition videoCompositionWithPropertiesOfAsset:goldenGateAsset];
     */
    AVMutableVideoComposition *videoCompostion = [AVMutableVideoComposition videoComposition];
    // 包含一组完整的基于组合视频轨道（以及其中包含的片段空间布局）的组合和层指令
    videoCompostion.instructions = @[ instruction ];
    // 定义该组合应该被渲染的尺寸，这个值应该对应于组中的视频原始大小
    videoCompostion.renderSize = composition.naturalSize;
    /**
     * 设置有效的帧率：
        * 帧时长就是帧率的倒数，若设置30FPS的帧率，则定义的帧时长应该是1/30秒
        * 设置为组合视频轨道中最大 nominalFrameRate ，如果所有轨道的 nominalFrameRate 值都为火0，则 frameDuration 设置成默认值1/30秒(30FPS), (mCompositionTrack.nominalFrameRate)
     */
    videoCompostion.frameDuration = CMTimeMake(1, 30);
    // 定义视频组合应用的缩放，大部分情况下设置为1.0
    videoCompostion.renderScale = 1.0f;

    
    NHBasicComposition *bComposition = [NHBasicComposition compositionWithComposition:composition];
    NHCompositionExporter *exporter = [[NHCompositionExporter alloc] initWithComposition:bComposition];
    [exporter beginExport];
    [exporter exportCompletionHandler:^{
        NSLog(@"");
    }];
    NSLog(@"");

}

#pragma mark - 第十二章 动画图层内容
- (void)coreAnimation {
    
    /**
     * AVSynchronizedLayer: 是AVFoundation 提供了一个专门的calayer子类，用于给指定的AVPlayerItem 实例同步时间，这个图层本身不展示任何内容，仅用来图层子树协同时间
       AVSynchronizedLayer *syncLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:playerItem];
       [syncLayer addSublayer:animationLayer];
       [self.layer addSublayer:syncLayer];


     * AVVideoCompositionCoreAnimationTool: 要将core animation图层和动画整合到导出视频中，需要使用：core animationTool类

     * CALayer *layer;
        设置为yes，这样当图片动态显示时边缘就会应用一个土抗锯齿效果
        layer.allowsEdgeAntialiasing = YES;
     
     * CAKeyframeAnimation *animation;
        设置为no，这样动画不会在执行之后被移除，如果没有明确设置这个属性，则意味着动画只能出现一次
        animation.removedOnCompletion = NO;
     */
     
    
    CALayer *parentLayer = self.view.layer;
    UIImage *image = [UIImage imageNamed:@"IMG_4006.png"];
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contents = (__bridge id _Nullable)(image.CGImage);
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    
    CGFloat midX = CGRectGetMidX(parentLayer.bounds);
    CGFloat midY = CGRectGetMidY(parentLayer.bounds);
    
    imageLayer.bounds = CGRectMake(0, 0, image.size.width/ UIScreen.mainScreen.scale, image.size.height / UIScreen.mainScreen.scale);
    imageLayer.position = CGPointMake(midX, midY);
    
    [parentLayer addSublayer:imageLayer];
    
    [imageLayer addAnimation:[self rotationAnimation] forKey:@"rotateAnimation"];

    [imageLayer addAnimation:[self make3DSpinAnimation] forKey:@"3DSpinAnimation"];

    [imageLayer addAnimation:[self makePopAnimation] forKey:@"PopAnimation"];
    
    CALayer *animationLayer = [CALayer layer];
//    animationLayer.frame =
    
    CALayer *videoLayer = [CALayer layer];
//    videoLayer.frame =
    // 视频层
    [animationLayer addSublayer:videoLayer];
    // 动画层
    [animationLayer addSublayer:imageLayer];
    // 设置动画图层的 geometryFlipped 为yes，来确保标题被正确渲染田；如果没有设置这个值将导致图片和文本的位置发生颠倒
    animationLayer.geometryFlipped = YES;
    
    AVVideoCompositionCoreAnimationTool *animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:animationLayer];
    
    AVMutableVideoComposition *videoComposition;
    // 把 animationTool 赋给视频命令层
    videoComposition.animationTool = animationTool;
    
    // 导出
    AVAssetExportSession *exportSession;
    exportSession.videoComposition = videoComposition;

}

- (CABasicAnimation *)rotationAnimation {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotationAnimation.toValue = @(2 * M_PI);
    rotationAnimation.duration = 3.0f;
    rotationAnimation.repeatCount = 2;
    return rotationAnimation;
}

- (CABasicAnimation *)make3DSpinAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    // 逆时针方向绕Y轴旋转两圈，一圈360度即2PI，所以我们设置 4 * M_PI
    animation.toValue = @((4 * M_PI) * -1);
    animation.beginTime = 3.0;
    animation.duration = 1.2;
//    animation.timeOffset = 3.0;
    animation.removedOnCompletion = NO;
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

- (CABasicAnimation *)makePopAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.toValue = @1.3f;
    animation.duration = 0.5;
    // 动画对象具有自动回溯功能，可以反言向运行动画，使它返回到初始状态
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

#pragma mark - MovieWriterDelegate
- (void)didWriterMovieAtURL:(NSURL *)outputURL {
    NSLog(@"didWriterMovieAtURL:%@",outputURL);
}

#pragma mark - CameraControllerDelegate
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
    if (error) {
        NSLog(@"视频录制错误：%@",error.localizedDescription);
    } else {
        NSLog(@"视频录制成功：%@",outputFileURL.absoluteString);
        ALAssetsLibrary *library = ALAssetsLibrary.alloc.init;
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]) {
            ALAssetsLibraryWriteVideoCompletionBlock completionBlock;
            completionBlock = ^(NSURL *assetURL, NSError *error2) {
                if (error2) {
                    NSLog(@"视频保存错误：%@",error2.localizedDescription);
                } else {
                  	  NSLog(@"视频保存成功：%@",outputFileURL.absoluteString);
                    AVAsset *asset = [AVAsset assetWithURL:outputFileURL];
                    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                    // 设置width，heigt为0，这样可以确保生成的图片都遵循了一定的y宽度，并且会根据视频的宽度比自动设置高度
                    imageGenerator.maximumSize = CGSizeMake(100.0f, 0.0f);
                    // 这样当捕捉缩略图时会考虑视频的变化，如视频方向变化，不这样设置，则会出现错误的缩略图方向
                    imageGenerator.appliesPreferredTrackTransform = YES;
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
                    // 缩略图
                    UIImage *thumbanilImage = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                }
            };
            
            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:completionBlock];
        }
    }
}

- (void)didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects {
    // 人脸识别
    if (0) {
        [self.videoPreview setFaces:metadataObjects];
    } else {
        // 条形码识别
        [self.videoPreview didDetectCodes:metadataObjects];
    }
}

- (void)didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    NSLog(@"视频数据被丢弃");

}

- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // buffer 的描述信息
//    CFDictionaryRef exifAttachments = (CFDictionaryRef)CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, NULL);
//    NSLog(@"buffer output...%@", exifAttachments);
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDescription);
    if (mediaType == kCMMediaType_Video) {
//        [self.openGLView updateBuffer:sampleBuffer];
        
    } else {
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    }
    
    [self.movieWriter processSampleBuffer:sampleBuffer];
}

#pragma mark - 公共方法
- (IBAction)beginRecoder:(UIButton *)sender {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [_recorder record];
    [self startTimer];
    [self startMeterTimer];
}

- (IBAction)stopRecoder:(UIButton *)sender {
    [_recorder stop];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_timer invalidate];
    _timer = nil;
    [self stoptMeterTimer];
}

- (IBAction)playOrStop:(UIButton *)sender {
    sender.selected = !sender.selected;
    switch (_type) {
        case DetailType1:
            break;
        case DetailType2:{
            if (_audioPlayer1.playing) {
                [_audioPlayer1 pause];
                [_audioPlayer2 pause];
                [_audioPlayer3 pause];
            } else {
                [_audioPlayer1 play];
                [_audioPlayer2 play];
                [_audioPlayer3 play];
            }
        }
            break;
        case DetailType3:
            
            break;
        case DetailType4:
            if (sender.selected) {
                [_player play];
            } else {
                [_player pause];
            }
            break;
        case DetailType5:
            
            break;
        case DetailType6:
            if ([self.cameraController.session isRunning]) {
                [self.cameraController stopRunning];
            } else {
                [self.cameraController startRunning];
            }
            break;
        case DetailType7:
            
            break;
        case DetailType8:
            if (self.movieWriter.isWriting) {
                [self.movieWriter stopWriting];
            } else {
                [self.movieWriter startWriting];
            }
            break;
        case DetailType9:
            
            break;
        case DetailType10:
            
            break;
        case DetailType11:
            
            break;
        case DetailType12:
            
            break;
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == &playerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playItem removeObserver:self forKeyPath:@"status" context:&playerItemStatusContext];
            NSLog(@"_player.status:%ld",self->_player.status);
            if (self.playItem.status == AVPlayerItemStatusReadyToPlay) {
                NSString *title = self.playItem.asset.title;
                self.navigationController.title = title;
                dispatch_queue_t queue = dispatch_get_main_queue();
                CMTime intercal = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
                void (^callBlock)(CMTime time) = ^(CMTime time) {
                    NSLog(@"playerTime:%f",CMTimeGetSeconds(time));
                };
                // 播放时间监听
                /// intercal：间隔多久j监听一次
                /// 发送通知的回调队列
                /// usingBlock：回调的block
                [self->_player addPeriodicTimeObserverForInterval:intercal queue:queue usingBlock:callBlock];
                [self addItemEndObserverForPlayerItem];
                [self getAssetImages];
            }
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playItem];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assetIamges.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AssetImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetImageCell" forIndexPath:indexPath];
    
    [cell setImage:_assetIamges[indexPath.row]];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(AssetImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell setImage:_assetIamges[indexPath.row]];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
return CGSizeMake((collectionView.bounds.size.height *9) / 16, collectionView.bounds.size.height);
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.videoPreview.frame = self.view.bounds;

}
@end
