//
//  NHTimeline.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHTimeline.h"
#import "NHAudioItem.h"

@implementation NHTimeline

- (BOOL)isSimpleTimeline {
    for (NHAudioItem *item in self.musicItems) {
        if (item.volumeAutomation.count > 0) {
            return NO;
        }
    }
    if (self.transitions.count > 0 || self.titles.count > 0) {
        return NO;
    }
    return YES;
}

@end
