//
//  AssetImageCell.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/27.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "AssetImageCell.h"

@implementation AssetImageCell{
    UIImageView *imageview;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        imageview = UIImageView.alloc.init;
        imageview.frame = self.frame;
        imageview.contentMode  = UIViewContentModeScaleAspectFit;
        imageview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageview];
        
    }
    return self;
}


- (void)setImage:(UIImage *)image {
    [imageview setImage:image];
}

@end
