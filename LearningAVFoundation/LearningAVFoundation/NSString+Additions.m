//
//  NSString+Additions.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NSString+Additions.h"

#if TARGET_OS_MACCATALYST
#import <AppKit/AppKit.h>
#endif


@implementation NSString (Additions)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    NSTextCheckingResult *result = [expression firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    if (capture < [result numberOfRanges]) {
        NSRange range = [result rangeAtIndex:capture];
        return [self substringWithRange:range];
    }
    return nil;
}

- (BOOL)containsString:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location != NSNotFound;
}

@end
