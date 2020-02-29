//
//  NHTransitionInstructions.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/27.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NHVideoTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHTransitionInstructions : NSObject

@property (strong, nonatomic) AVMutableVideoCompositionInstruction *compositionInstruction;
@property (strong, nonatomic) AVMutableVideoCompositionLayerInstruction *fromLayerInstruction;
@property (strong, nonatomic) AVMutableVideoCompositionLayerInstruction *toLayerInstruction;
@property (strong, nonatomic) NHVideoTransition *transition;

@end

NS_ASSUME_NONNULL_END
