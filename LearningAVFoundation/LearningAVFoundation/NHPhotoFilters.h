//
//  NHPhotoFilters.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const NHFilterSelectionChangedNotification = @"filter_selection_changed";

@interface NHPhotoFilters : NSObject

+ (NSArray *)filterNames;
+ (NSArray *)filterDisplayNames;
+ (CIFilter *)filterForDisplayName:(NSString *)displayName;
+ (CIFilter *)defaultFilter;

@end

NS_ASSUME_NONNULL_END
