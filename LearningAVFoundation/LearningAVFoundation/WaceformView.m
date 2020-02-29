//
//  WaceformView.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/9.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "WaceformView.h"
#import "SampleDataProvider.h"
#import "SampleDataFilter.h"

static const CGFloat WidthScaling = 0.95;
static const CGFloat HeightScaling = 0.85;

@interface WaceformView ()
@property (nonatomic, strong) SampleDataFilter *filter;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end

@implementation WaceformView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingView.frame = CGRectMake(self.bounds.size.width * 0.5 - 25, self.bounds.size.height * 0.5 - 25, 50, 50);
        [self addSubview:_loadingView];
        self.layer.cornerRadius = 2.0f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setAsset:(AVAsset *)asset {
    if (_asset != asset) {
        _asset = asset;
        [_loadingView startAnimating];
        [SampleDataProvider loadAudioSamplesFromAsset:asset completionBlock:^(NSData * _Nonnull sampleData) {
            self.filter = [[SampleDataFilter alloc] initWithData:sampleData];
            [self setNeedsDisplay];
            [self.loadingView stopAnimating];
        }];
    }
}

- (void)setWaveColor:(UIColor *)waveColor {
    _waveColor = waveColor;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = waveColor.CGColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, WidthScaling, HeightScaling);
    
    CGFloat xOffset = self.bounds.size.width - (self.bounds.size.width * WidthScaling);
    CGFloat yOffset = self.bounds.size.height - (self.bounds.size.height * HeightScaling);
    
    CGContextTranslateCTM(context, xOffset / 2, yOffset  / 2);
    NSArray *filteredSamples = [self.filter filteredSamplesForSize:self.bounds.size];
    
    CGFloat midY = CGRectGetMidY(rect);
    CGMutablePathRef halfPath = CGPathCreateMutable();
    CGPathMoveToPoint(halfPath, NULL, 0.0f, midY);
    
    for (NSUInteger i = 0; i < filteredSamples.count; i++) {
        float sample = [filteredSamples[i] floatValue];
        CGPathAddLineToPoint(halfPath, NULL, i, midY - sample);
    }
    
    CGPathAddLineToPoint(halfPath, NULL, filteredSamples.count, midY);
    
    CGMutablePathRef fullPath = CGPathCreateMutable();
    CGPathAddPath(fullPath, NULL, halfPath);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(rect));
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGPathAddPath(fullPath, &transform, halfPath);
    
    CGContextAddPath(context, fullPath);
    CGContextSetFillColorWithColor(context, self.waveColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
    CGPathRelease(halfPath);
    CGPathRelease(fullPath);
}


@end
