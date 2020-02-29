//
//  LevelMeterColorThreshold.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LevelMeterColorThreshold : NSObject
@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, strong, readonly) UIColor *color;
@property (nonatomic, copy, readonly) NSString *name;

+ (instancetype)colorThresholdWithMaxValue:(CGFloat)maxValue color:(UIColor *)color name:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
