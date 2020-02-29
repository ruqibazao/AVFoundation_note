//
//  NHContextManager.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/15.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <CoreImage/CoreImage.h>


NS_ASSUME_NONNULL_BEGIN

@interface NHContextManager : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, readonly) EAGLContext *eaglContext;
@property (strong, nonatomic, readonly) CIContext *ciContext;

@end

NS_ASSUME_NONNULL_END
