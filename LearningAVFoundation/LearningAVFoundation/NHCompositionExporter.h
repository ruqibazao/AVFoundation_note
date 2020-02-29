//
//  NHCompositionExporter.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/18.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NHComposition.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHCompositionExporter : NSObject
@property (nonatomic, assign) BOOL exporting;
@property (nonatomic, assign) CGFloat progress;

- (instancetype)initWithComposition:(id<NHComposition>)composition;
- (void)beginExport;

- (void)exportCompletionHandler:(void (^)(void))handler;


@end

NS_ASSUME_NONNULL_END
