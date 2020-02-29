//
//  NHTransitionCompositionBuilder.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/24.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHTransitionCompositionBuilder.h"
#import "Common.h"
#import "NHVideoTransition.h"
#import "NHTransitionInstructions.h"
#import "NHTransitionComposition.h"
#import "NHTimeline.h"


@interface NHTransitionCompositionBuilder ()
@property (nonatomic, strong) NHTimeline *timeline;
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableCompositionTrack *musicTrack;
@end

@implementation NHTransitionCompositionBuilder


- (id<NHComposition>)buildComposition {
    self.composition = [AVMutableComposition composition];
    
    AVVideoComposition *videoComposition = [self buildVideoComposition];
    AVAudioMix *audioMix = [self buildAudioMix];
    return [[NHTransitionComposition alloc] initWithComposition:self.composition videoComposition:videoComposition audioMix:audioMix];
}

- (void)buildCompositonTracks {
    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;
    
    AVMutableCompositionTrack *compositionTrackA = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:trackID];
    AVMutableCompositionTrack *compositionTrackB = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:trackID];
    
    NSArray *videoTracks = @[ compositionTrackA, compositionTrackB ];
    CMTime cursorTime = kCMTimeZero;
    CMTime transitionDuration = kCMTimeZero;
    
    if (!NHIsEmpty(self.timeline.transitions)) {
        transitionDuration = NHDefaultTransitionDuration;
    }
    
    NSArray *videos = self.timeline.videos;
    for (NSUInteger i = 0; i < videos.count; i++) {
//        NSUInteger trackIndex = i % 2;
        
    }
}

- (AVVideoComposition *)buildVideoComposition {
    
    AVVideoComposition *videoComposition = [AVVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
    
    NSArray *transitionInstructions = [self transitionInstructionsInVideoComposition:videoComposition];
    
    for (NHTransitionInstructions *instructions in transitionInstructions) {
        CMTimeRange timeRange = instructions.compositionInstruction.timeRange;
        AVMutableVideoCompositionLayerInstruction *fromLayer = instructions.fromLayerInstruction;
        AVMutableVideoCompositionLayerInstruction *toLayer = instructions.toLayerInstruction;
        
        NHVideoTransitionType type = instructions.transition.type;
        
        // 视频过渡效果：溶解、推入、或者擦除
        if (type == NHVideoTransitionTypeDissolve) {
            // 对 fromLayer 对象设置一个模糊渐变，在过渡时间内将模糊默认的1.0(完全模糊)到0.0(完全透明)
            // 这样就将视频以溶解的效果切换到0.0 到 1.0
            [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:timeRange];
            
        } else if (type == NHVideoTransitionTypePush) {
            // 定义一个视频层的变换，可以修改层的转化，旋转和缩放，初始化变换设置为identityTransform(未变换状态)
            CGAffineTransform identityTransforms = CGAffineTransformIdentity;
            CGFloat videoWidth = videoComposition.renderSize.width;
            CGAffineTransform fromDestTransform = CGAffineTransformMakeTranslation(-videoWidth, 0.0);
            CGAffineTransform toStartTransform = CGAffineTransformMakeTranslation(videoWidth, 0.0);
            // 设置 fromLayer 的渐变效果，终点变换设置为 fromDestTransform
            // 这样就会在 timeRange时间内实现fromLayer向左侧退出的动画效果
            [fromLayer setTransformRampFromStartTransform:fromDestTransform toEndTransform:toStartTransform timeRange:timeRange];
            // toLayer 上设置一个渐变效果，初始变换设置为 toStartTransform，终点变换设置为 identityTransform
            // 这样就在 timeRange 时间内实现 toLayer 从右侧进入的动画效果
            [toLayer setTransformRampFromStartTransform:toStartTransform toEndTransform:fromDestTransform timeRange:timeRange];
            
        } else if (type == NHVideoTransitionTypeWipe) {
            /**
             获取宽高，这些值用于创建擦除动画效果的开始和结束的CGRect
             初始矩形为最大的宽度和高度，最终矩形在高度上有所削减，在fromLayer上生成一个向上擦除的效果
             */
            CGFloat videoWidth = videoComposition.renderSize.width;
            CGFloat videoHeight = videoComposition.renderSize.height;
            CGRect startRect = CGRectMake(0.0, 0.0, videoWidth, videoHeight);
            CGRect endRect = CGRectMake(0.0, videoHeight, videoWidth, 0.0f);
            
            [fromLayer setCropRectangleRampFromStartCropRectangle:startRect toEndCropRectangle:endRect timeRange:timeRange];
        }
        
        instructions.compositionInstruction.layerInstructions = @[ fromLayer, toLayer ];
    }
    
    return videoComposition;
}


/// 提取相关指令层，这样才可以应用期望的视频过渡效果，这个方法会返回一个 `NHTransition-Instructions` 对象数组
/// @param vc vc description
- (NSArray<NHTransitionInstructions *> *)transitionInstructionsInVideoComposition:(AVVideoComposition *)vc {
    NSMutableArray *transitionInstructions = [NSMutableArray array];
    int layerInstructionIndex = 1;
    NSArray *compositionInstructions = vc.instructions;
    for (AVMutableVideoCompositionInstruction *vci in compositionInstructions) {
        if (vci.layerInstructions.count == 2) {
            NHTransitionInstructions *instructions = [[NHTransitionInstructions alloc] init];
            instructions.compositionInstruction = vci;
            instructions.fromLayerInstruction = vci.layerInstructions[1 - layerInstructionIndex];
            instructions.toLayerInstruction = vci.layerInstructions[layerInstructionIndex];
            
            [transitionInstructions addObject:instructions];
            layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1;
        }
    }
    
    NSArray *transitions = self.timeline.transitions;
    // 如果 transitions 是空的，则返回transitionInstructions，因为这表示用户界面彬了过渡
    if (NHIsEmpty(transitions)) {
        
    }
    
    NSAssert(transitionInstructions.count == transitions.count, @"Instruction count and transition count do not match.");
    // 如果过渡已启用，则遍田历 transitionInstructions ，并将用户选定的NHVideoTransition 对象和它进行关联
    for (NSUInteger i = 0; i < transitionInstructions.count; i++) {
        NHTransitionInstructions *tis = transitionInstructions[i];
        tis.transition = self.timeline.transitions[i];
    }
    
    return transitionInstructions;
}



- (AVAudioMix *)buildAudioMix {
    AVAudioMix *audioMix;
    
    
    return audioMix;
}

@end
