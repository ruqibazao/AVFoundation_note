//
//  NHCompositionBuilder.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NHComposition.h"

NS_ASSUME_NONNULL_BEGIN
// 这个协议的具体实例负责提供 buildComposition 方法的实现
@protocol NHCompositionBuilder <NSObject>

- (id<NHComposition>)buildComposition;

@end

NS_ASSUME_NONNULL_END
