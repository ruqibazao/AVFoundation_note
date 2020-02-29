//
//  NHComposition.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NHComposition <NSObject>

- (AVPlayerItem *)makePlayable;
- (AVAssetExportSession *)makeExportable;

@end

NS_ASSUME_NONNULL_END
