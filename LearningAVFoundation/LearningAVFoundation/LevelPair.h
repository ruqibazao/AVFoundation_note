//
//  LevelPair.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 计算级别的大小
@interface LevelPair : NSObject

@property (nonatomic, readonly) float level;
@property (nonatomic, readonly) float peakLevel;

+ (instancetype)levelsWithLevel:(float)level peakLevel:(float)peakLevel;

- (instancetype)initWithLevel:(float)level peakLevel:(float)peakLevel;

@end

NS_ASSUME_NONNULL_END
