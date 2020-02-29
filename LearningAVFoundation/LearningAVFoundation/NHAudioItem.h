//
//  NHAudioItem.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHMediaItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHAudioItem : NHMediaItem

@property (strong, nonatomic) NSArray *volumeAutomation;

+ (id)audioItemWithURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
