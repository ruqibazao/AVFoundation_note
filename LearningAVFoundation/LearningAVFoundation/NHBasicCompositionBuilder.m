//
//  NHBasicCompositionBuilder.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHBasicCompositionBuilder.h"
#import "NHBasicComposition.h"
#import <AVFoundation/AVFoundation.h>
#import "Common.h"
#import "NHMediaItem.h"

@interface NHBasicCompositionBuilder ()
@property (nonatomic, strong) NHTimeline *timeline;
@property (nonatomic, strong) AVMutableComposition *composition;

@end

@implementation NHBasicCompositionBuilder

- (instancetype)initWithTimeline:(NHTimeline *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id<NHComposition>)buildComposition {
    self.composition = [AVMutableComposition composition];
    
    [self addCompositionTrackOfType:AVMediaTypeVideo withMediaItems:self.timeline.videos];
    
    [self addCompositionTrackOfType:AVMediaTypeAudio withMediaItems:self.timeline.voiceOvers];
    
    [self addCompositionTrackOfType:AVMediaTypeAudio withMediaItems:self.timeline.musicItems];
    
    return [NHBasicComposition compositionWithComposition:self.composition];
}


/// 每次调用此方法都会创建一个带有指定类型的媒体类型 AVMutableCompositionTrack 实例
/// @param mediaType mediaType description
/// @param mediaItems mediaItems description
- (void)addCompositionTrackOfType:(NSString *)mediaType withMediaItems:(NSArray *)mediaItems {
    // 先判定数组是否为空
    if (!NHIsEmpty(mediaItems)) {
        
        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
        
        AVMutableCompositionTrack *compositionTrack = [self.composition addMutableTrackWithMediaType:mediaType preferredTrackID:trackID];
        
        CMTime cursorTime = kCMTimeZero;
        
        for (NHMediaItem *item in mediaItems) {
            // 检查时间轴对象的 startTimeInTimeline 是否有效
            if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
                cursorTime = item.startTimeInTimeline;
            }
            // 提取对应轨道
            AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:mediaType].firstObject;
            // 使用条目指定的timerange，在计算的cursorTime值处将媒体剪辑插入到组合轨道中
            [compositionTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];
            // 将当前剪辑的时长数据和cursorTime相加，计算得到一个新的cursorTime值，这样为下一个循环迭代设置正确的时间点
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        }
    }
}


@end
