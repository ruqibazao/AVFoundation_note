//
//  AVAsset+Additions.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/27.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "AVAsset+Additions.h"


@implementation AVAsset (Additions)

- (NSString *)title {
    AVKeyValueStatus status = [self statusOfValueForKey:@"commonMetadata" error:nil];
    
    if (status == AVKeyValueStatusLoaded) {
        NSArray *items = [AVMetadataItem metadataItemsFromArray:self.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
        if (items > 0) {
            AVMetadataItem *item = [items firstObject];
            return (NSString *)item.value;
        }
    }
    return nil;
}

@end
