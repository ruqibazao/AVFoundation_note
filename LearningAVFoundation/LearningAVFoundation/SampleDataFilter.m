//
//  SampleDataFilter.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/9.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "SampleDataFilter.h"


@interface SampleDataFilter ()
@property (nonatomic, strong) NSData *sampleData;

@end

@implementation SampleDataFilter

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _sampleData = data;
    }
    return self;
}

- (NSArray *)filteredSamplesForSize:(CGSize)size {
    // 用来保存筛选的数据
    NSMutableArray *filteredSamples = [[NSMutableArray alloc] init];
    NSUInteger sampleCount = self.sampleData.length / sizeof(SInt16);
    NSUInteger binSize = sampleCount / size.width;
    
    SInt16 *bytes = (SInt16*)self.sampleData.bytes;
    
    SInt16 maxSample = 0;
    
    for (NSUInteger i = 0; i < sampleCount; i += binSize) {
        
        SInt16 sampleBin[binSize];
        
        // 迭代全部音频样本集合，在每一个迭代中构建一个需要处理的数据箱，当处理音频样本
        // 要时刻记得字节的顺序，所以用到了CFSwapInt16LittleToHost 函数来确保样本是按主机内置的字节顺序处理的
        for (NSUInteger j = 0; j < binSize; j++) {
            sampleBin[j] = CFSwapInt16LittleToHost(bytes[i + j]);
        }
        
        // 对于每个箱，调用 `[self maxValueInArray:bytes ofSize:binSize];` 方法找到最大样本
        SInt16 value = [self maxValueInArray:sampleBin ofSize:binSize];
        [filteredSamples addObject:@(value)];
        
        // 筛选出最大的值
        if (value > maxSample) {
            maxSample = value;
        }
    }
    // 在返回筛选样本前，需要相对于传递给方法的尺寸约束来缩放值，这会得到一个浮点型的数组，这些值可以在屏幕上呈现
    CGFloat scaleFactor = (size.height / 2) / maxSample;
    for (NSUInteger i = 0; i < filteredSamples.count; i ++) {
        filteredSamples[i] = @([filteredSamples[i] integerValue] * scaleFactor);
    }
    return filteredSamples;
}

- (SInt16)maxValueInArray:(SInt16[])values ofSize:(NSUInteger)size {
    SInt16 maxValue = 0;
    for (int i = 0; i < size; i++) {
        if (abs(values[i]) > maxValue) {
            maxValue = abs(values[i]);
        }
    }
    return maxValue;
}


@end
