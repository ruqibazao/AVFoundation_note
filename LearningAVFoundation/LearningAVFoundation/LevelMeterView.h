//
//  LevelMeterView.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LevelMeterView : UIView
@property (nonatomic) CGFloat level;
@property (nonatomic) CGFloat peakLevel;

- (void)resetLevelMeter;
@end

NS_ASSUME_NONNULL_END
