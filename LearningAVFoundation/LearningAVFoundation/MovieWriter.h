//
//  MovieWriter.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MovieWriterDelegate <NSObject>

- (void)didWriterMovieAtURL:(NSURL *)outputURL;

@end

@interface MovieWriter : NSObject
@property (nonatomic, weak) id<MovieWriterDelegate> delegate;
@property (nonatomic, copy) NSURL *outputURL;
@property (nonatomic, assign, readonly) BOOL isWriting;

- (instancetype)initWithVideoSetting:(NSDictionary *)videoSetting
                        audioSetting:(NSDictionary *)audioSetting
                       dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)startWriting;
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)stopWriting;



@end

NS_ASSUME_NONNULL_END
