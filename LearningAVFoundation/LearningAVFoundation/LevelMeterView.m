//
//  LevelMeterView.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/6.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "LevelMeterView.h"
#import "LevelMeterColorThreshold.h"

@interface LevelMeterView ()

@property (nonatomic) NSUInteger ledCount;
@property (strong, nonatomic) UIColor *ledBackgroundColor;
@property (strong, nonatomic) UIColor *ledBorderColor;
@property (nonatomic, strong) NSArray <LevelMeterColorThreshold *>*colorThresholds;

@end

@implementation LevelMeterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    
    _ledCount = 20;
    
    _ledBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.35f];
    _ledBorderColor = [UIColor blackColor];
    
    UIColor *greenColor = [UIColor colorWithRed:0.458 green:1.000 blue:0.396 alpha:1.000];
    UIColor *yellowColor = [UIColor colorWithRed:1.000 green:0.930 blue:0.315 alpha:1.000];
    UIColor *redColor = [UIColor colorWithRed:1.000 green:0.325 blue:0.329 alpha:1.000];
    _colorThresholds = @[[LevelMeterColorThreshold colorThresholdWithMaxValue:0.5 color:greenColor name:@"green"],
                         [LevelMeterColorThreshold colorThresholdWithMaxValue:0.8 color:yellowColor name:@"yellow"],
                         [LevelMeterColorThreshold colorThresholdWithMaxValue:1.0 color:redColor name:@"red"]];
}


- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextRotateCTM(context, (CGFloat)-M_PI_2);
    
    CGRect bounds = CGRectMake(0.0, 0.0, self.bounds.size.height, self.bounds.size.width);
    CGFloat lightMinValue = 0.0f;
    NSInteger peakLED = -1;
    
    if (self.peakLevel > 0.0f) {
        peakLED = self.peakLevel * self.ledCount;
        if (peakLED >= self.ledCount) {
            peakLED = self.ledCount - 1;
        }
    }
    
    for (int ledIndex = 0; ledIndex < self.ledCount; ledIndex ++) {
        UIColor *ledColor = [self.colorThresholds[0] color];
        CGFloat ledMaxValue = (CGFloat)(ledIndex + 1) / self.ledCount;
        
        for (int colorIndex = 0; colorIndex < self.colorThresholds.count - 1; colorIndex++) {
            LevelMeterColorThreshold *currThreshold = self.colorThresholds[colorIndex];
            LevelMeterColorThreshold *nextThreshold = self.colorThresholds[colorIndex + 1];
            if (currThreshold.maxValue <= ledMaxValue) {
                ledColor = nextThreshold.color;
            }
        }
        
        CGFloat height = CGRectGetHeight(bounds);
        CGFloat width = CGRectGetWidth(bounds);
        CGRect ledRect = CGRectMake(0.f, height * ((CGFloat) ledIndex / self.ledCount), width, height);
        CGContextSetFillColorWithColor(context, self.ledBackgroundColor.CGColor);
        CGContextFillRect(context, ledRect);
        
        CGFloat lightIntensity;
        if (ledIndex  == peakLED) {
            lightIntensity = 1.0f;
        } else {
            lightIntensity = clamp(self.level - lightMinValue) / (ledMaxValue - lightMinValue);
        }
        
        UIColor *fillColor = nil;
        if (lightIntensity == 1.0f) {
            fillColor = ledColor;
        } else if (lightIntensity > 0.0f) {
            CGColorRef color = CGColorCreateCopyWithAlpha(ledColor.CGColor, lightIntensity);
            fillColor = [UIColor colorWithCGColor:color];
            CGColorRelease(color);
        }
        
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:ledRect cornerRadius:2.0f];
        CGContextAddPath(context, fillPath.CGPath);
        
        CGContextSetStrokeColorWithColor(context, self.ledBorderColor.CGColor);
        UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(ledRect, 0.5, 0.5) cornerRadius:2.0f];
        CGContextAddPath(context, strokePath.CGPath);
        
        CGContextDrawPath(context, kCGPathFillStroke);
        
        lightMinValue = ledMaxValue;
    }
}


CGFloat clamp(CGFloat intensity) {
    if (intensity < 0.0f) {
        return 0.0f;
    } else if (intensity >= 1.0) {
        return 1.0f;
    } else {
        return intensity;
    }
}

- (void)resetLevelMeter {
    self.level = 0.0f;
    self.peakLevel = 0.0f;
    [self setNeedsDisplay];
}

@end
