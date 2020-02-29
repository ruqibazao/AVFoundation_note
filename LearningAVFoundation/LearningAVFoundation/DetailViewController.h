//
//  DetailViewController.h
//  LearningAVFoundation
//
//  Created by nenhall on 2020/1/4.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    DetailType1,
    DetailType2,
    DetailType3,
    DetailType4,
    DetailType5,
    DetailType6,
    DetailType7,
    DetailType8,
    DetailType9,
    DetailType10,
    DetailType11,
    DetailType12
} DetailType;

@interface DetailViewController : UIViewController
@property (assign) DetailType type;

@end

NS_ASSUME_NONNULL_END
