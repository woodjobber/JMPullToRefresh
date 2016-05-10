//
//  UIView+JM360Rotate.h
//  JuMei
//
//  Created by chengbin on 16/5/5.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JM360RotateTimingMode) {
    
    JM360RotateTimingModeEaseInEaseOut,
    
    JM360RotateTimingModeLinear
    
};

@interface UIView (JM360Rotate)

- (void)jm_360RotateWithDuration:(CGFloat)aDuration repeatCount:(CGFloat)aRepeatCount timingMode:(JM360RotateTimingMode)aMode;

- (void)jm_360RotateWithDuration:(CGFloat)aDuration timingMode:(JM360RotateTimingMode)aMode;

- (void)jm_360RotateWithDuration:(CGFloat)aDuration;

- (void)jm_360RotateWithDuration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(CGFloat)repeat;

- (void)jm_360RotateWithDuration:(CGFloat)duration repeat:(CGFloat)repeat;

@end
