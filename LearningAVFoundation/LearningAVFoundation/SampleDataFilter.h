//
//  SampleDataFilter.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/9.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SampleDataFilter : NSObject
- (instancetype)initWithData:(NSData *)data;
- (NSArray *)filteredSamplesForSize:(CGSize)size;


@end

NS_ASSUME_NONNULL_END
