//
//  NHBasicComposition.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NHComposition.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHBasicComposition : NSObject<NHComposition>
@property (nonatomic, strong, readonly) AVComposition *composition;

+(instancetype)compositionWithComposition:(AVComposition *)composition;
-(instancetype)initWithComposition:(AVComposition *)composition;



@end

NS_ASSUME_NONNULL_END
