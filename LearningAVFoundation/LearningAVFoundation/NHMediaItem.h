//
//  NHMediaItem.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NHPreparationCompletionBlock)(BOOL complete);


@interface NHMediaItem : NSObject
@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) CMTime startTimeInTimeline;
@property (strong, nonatomic) AVAsset *asset;
@property (nonatomic, readonly) BOOL prepared;
@property (nonatomic, readonly) NSString *mediaType;
@property (nonatomic, copy, readonly) NSString *title;

- (id)initWithURL:(NSURL *)url;

- (void)prepareWithCompletionBlock:(NHPreparationCompletionBlock)completionBlock;

- (void)performPostPrepareActionsWithCompletionBlock:(NHPreparationCompletionBlock)completionBlock;

- (BOOL)isTrimmed;

- (AVPlayerItem *)makePlayable;

@end

NS_ASSUME_NONNULL_END
