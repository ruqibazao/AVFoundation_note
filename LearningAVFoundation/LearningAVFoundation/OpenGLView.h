//
//  OpenGLView.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLView : GLKViewController
@property (nonatomic, strong, readonly) EAGLContext *context;

-(CVReturn)updateBuffer:(CMSampleBufferRef)buffer;

//- (void)textureCreatedWithTarget:(GLenum)target name:(GLuint)name;

@end

NS_ASSUME_NONNULL_END
