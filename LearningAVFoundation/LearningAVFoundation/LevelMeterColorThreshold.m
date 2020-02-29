//
//  LevelMeterColorThreshold.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "LevelMeterColorThreshold.h"

@implementation LevelMeterColorThreshold

+ (instancetype)colorThresholdWithMaxValue:(CGFloat)maxValue color:(UIColor *)color name:(NSString *)name {
    return [[self alloc] initWithMaxValue:maxValue color:color name:name];
}

- (instancetype)initWithMaxValue:(CGFloat)maxValue color:(UIColor *)color name:(NSString *)name {
    self = [super init];
    if (self) {
        _maxValue = maxValue;
        _color = color;
        _name = [name copy];
    }
    return self;
}

- (NSString *)description {
    return self.name;
}

@end
