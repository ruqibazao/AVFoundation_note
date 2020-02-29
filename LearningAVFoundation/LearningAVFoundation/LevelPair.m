//
//  LevelPair.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "LevelPair.h"

@implementation LevelPair

+ (instancetype)levelsWithLevel:(float)level peakLevel:(float)peakLevel {
    return [[self alloc] initWithLevel:level peakLevel:peakLevel];
}

- (instancetype)initWithLevel:(float)level peakLevel:(float)peakLevel {
    self = [super init];
    if (self) {
        _level = level;
        _peakLevel = peakLevel;
    }
    return self;
}

@end
