//
//  NHBasicCompositionBuilder.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NHTimeline.h"
#import "NHCompositionBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHBasicCompositionBuilder : NSObject<NHCompositionBuilder>
- (instancetype)initWithTimeline:(NHTimeline *)timeline;



@end

NS_ASSUME_NONNULL_END
