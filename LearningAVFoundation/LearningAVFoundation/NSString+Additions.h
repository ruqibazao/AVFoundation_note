//
//  NSString+Additions.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

#if TARGET_OS_MACCATALYST
#import <AppKit/AppKit.h>
#endif


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Additions)


- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture;
- (BOOL)containsString:(NSString *)substring;

@end

NS_ASSUME_NONNULL_END
