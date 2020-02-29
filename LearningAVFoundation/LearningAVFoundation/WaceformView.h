//
//  WaceformView.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/9.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaceformView : UIView
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) UIColor *waveColor;
@end

NS_ASSUME_NONNULL_END
