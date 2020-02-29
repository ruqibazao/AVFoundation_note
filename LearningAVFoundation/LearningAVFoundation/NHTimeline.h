//
//  NHTimeline.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHTimeline : NSObject
@property (nonatomic, copy, readonly) NSArray *videos;
@property (nonatomic, copy, readonly) NSArray *voiceOvers;
@property (nonatomic, copy, readonly) NSArray *musicItems;
@property (strong, nonatomic) NSArray *transitions;
@property (strong, nonatomic) NSArray *titles;

- (BOOL)isSimpleTimeline;

@end

NS_ASSUME_NONNULL_END
