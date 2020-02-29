//
//  SampleDataProvider.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/9.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SampleDataProvider : NSObject

// 读取资源的音频样本
+ (void)loadAudioSamplesFromAsset:(AVAsset *)asset completionBlock:(void(^)(NSData *sampleData))completion;

@end

NS_ASSUME_NONNULL_END
