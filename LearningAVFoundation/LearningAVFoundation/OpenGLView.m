//
//  OpenGLView.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "OpenGLView.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "ShaderProgram.h"
#import <AVFoundation/AVFoundation.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))


// Uniform index.
enum {
    UNIFORM_MVP_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

@interface OpenGLView ()
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) ShaderProgram *shaderProgram;
@property (nonatomic) CVOpenGLESTextureCacheRef textureCache;
@property (nonatomic) CVOpenGLESTextureRef cameraTexture;
@end

@implementation OpenGLView{
    GLKMatrix4 _mvpMatrix;
    float _rotation;

    GLuint _vertexArray;
    GLuint _vertexBuffer;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.view.frame = UIScreen.mainScreen.bounds;
    if (!self.context) {
        NSLog(@"Failed to create OpenGL ES 2.0 context");
    }

    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableStencilFormat = GLKViewDrawableDepthFormat24;

    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                                NULL,
                                                _context,
                                                NULL,
                                                &_textureCache);
    if (err != kCVReturnSuccess) {
        NSLog(@"Error creating texture cache. %d", err);
    }

}

- (void)setUpGL {
    GLfloat cubeVertices[] = {
    //  Position                 Normal                  Texture
     // x,    y,     z           x,    y,    z           s,    t
        0.5f, -0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      1.0f, 0.0f, 0.0f,       1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,      1.0f, 0.0f, 0.0f,       0.0f, 0.0f,

        0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 0.0f,
       -0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 0.0f,
        0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,
        0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       1.0f, 1.0f,
       -0.5f, 0.5f, -0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 0.0f,
       -0.5f, 0.5f,  0.5f,       0.0f, 1.0f, 0.0f,       0.0f, 1.0f,

       -0.5f,  0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
       -0.5f, -0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
       -0.5f,  0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 0.0f,
       -0.5f,  0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       0.0f, 0.0f,
       -0.5f, -0.5f, -0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
       -0.5f, -0.5f,  0.5f,     -1.0f, 0.0f, 0.0f,       1.0f, 0.0f,

       -0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 0.0f,
        0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 0.0f,
       -0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 1.0f,
       -0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,      0.0f, -1.0f, 0.0f,      0.0f, 1.0f,

        0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 0.0f,
       -0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 1.0f,
        0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 0.0f,
        0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 0.0f,
       -0.5f,  0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       0.0f, 1.0f,
       -0.5f, -0.5f, 0.5f,       0.0f, 0.0f, 1.0f,       1.0f, 1.0f,

        0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 1.0f,
       -0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 0.0f,
        0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      0.0f, 0.0f,
       -0.5f, -0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 1.0f,
       -0.5f,  0.5f, -0.5f,      0.0f, 0.0f, -1.0f,      1.0f, 0.0f
    };
    
    [EAGLContext setCurrentContext:self.context];

    self.shaderProgram = [[ShaderProgram alloc] initWithShaderName:@"Shader"];
    [self.shaderProgram addVertextAttribute:GLKVertexAttribPosition named:@"position"];
    [self.shaderProgram addVertextAttribute:GLKVertexAttribTexCoord0 named:@"videoTextureCoordinate"];
    [self.shaderProgram linkProgram];
    uniforms[UNIFORM_MVP_MATRIX] = [self.shaderProgram uniformIndex:@"mvpMatrix"];
    
    glEnable(GL_DEPTH_TEST);
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(3 * sizeof(GLfloat)));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          3,
                          GL_FLOAT,
                          GL_TRUE,
                          8 * sizeof(GLfloat),
                          BUFFER_OFFSET(6 * sizeof(GLfloat)));
    
}

- (void)tearDownGL {
    
    [EAGLContext  setCurrentContext:self.context];
    glDeleteBuffers(1, &_vertexBuffer);
}

- (CVReturn)updateBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    CVReturn err;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    // 创建一个openGL ES 贴图，宽高都用dimensions.height，创造出一个矩形
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _textureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       dimensions.height,
                                                       dimensions.height,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_cameraTexture);
    if (!err) {
        // 从 openGLESTeureRef获取 target 和 name 的值，用来将贴图对象与旋转的小方的表面进行合适的绑定
        GLenum target = CVOpenGLESTextureGetTarget(_cameraTexture);
        GLuint name = CVOpenGLESTextureGetName(_cameraTexture);
        [self textureCreatedWithTarget:target name:name];
    } else {
        NSLog(@"%d",err);
        
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    // grayPixleBuffer: 灰度处理 buffer
    //        UIImage *image = [UIImage imageFromPixelBuffer:[UIImage grayPixleBuffer:pixelBuffer]];
    [self cleanupTextures];
    
    return err;
}

// 释放贴图并刷新贴图缓存
- (void)cleanupTextures {
    if (!_cameraTexture) {
        CFRelease(_cameraTexture);
        _cameraTexture = NULL;
    }
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
}

#pragma mark - Texture delegate method
- (void)textureCreatedWithTarget:(GLenum)target name:(GLuint)name {
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(target, name);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
}

- (void)update {
    CGRect bounds = self.view.bounds;

    GLfloat aspect = fabs(CGRectGetWidth(bounds) / CGRectGetHeight(bounds));
    GLKMatrix4 projectionMatrix =
    GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f),
                              aspect, 0.1f, 100.0f);

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -3.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.f, 1.f, 1.f);

    _mvpMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    _rotation += self.timeSinceLastUpdate * 0.75;
    
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(_vertexArray);

    [self.shaderProgram useProgram];

    glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, 0, _mvpMatrix.m);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

@end
