//
//  NHAudioItem.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHAudioItem.h"

@implementation NHAudioItem

+ (id)audioItemWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

- (NSString *)mediaType {
    return AVMediaTypeAudio;
}

@end
