//
//  UIView+JM360Rotate.m
//  JuMei
//
//  Created by chengbin on 16/5/5.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "UIView+JM360Rotate.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (JM360Rotate)

- (void)jm_360RotateWithDuration:(CGFloat)aDuration repeatCount:(CGFloat)aRepeatCount timingMode:(JM360RotateTimingMode)aMode {
    
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animation];
    rotationAnimation.values = [NSArray arrayWithObjects:
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,0,1)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0,0,1)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(6.26, 0,0,1)],
                           nil];
    rotationAnimation.cumulative = YES;
    rotationAnimation.duration = aDuration;
    rotationAnimation.repeatCount = aRepeatCount;
    rotationAnimation.removedOnCompletion = YES;
    rotationAnimation.fillMode = kCAFillModeForwards;
    
    if(aMode == JM360RotateTimingModeEaseInEaseOut) {
        rotationAnimation.timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                        nil
                                        ];
    }else {
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    [self.layer addAnimation:rotationAnimation forKey:@"transform"];
}



- (void)jm_360RotateWithDuration:(CGFloat)aDuration timingMode:(JM360RotateTimingMode)aMode {
    [self jm_360RotateWithDuration:aDuration repeatCount:1 timingMode:aMode];
}

- (void)jm_360RotateWithDuration:(CGFloat)aDuration {
    [self jm_360RotateWithDuration:aDuration repeatCount:1 timingMode:JM360RotateTimingModeEaseInEaseOut];
}

- (void)jm_360RotateWithDuration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(CGFloat)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * rotations];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    rotationAnimation.removedOnCompletion = YES;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)jm_360RotateWithDuration:(CGFloat)duration repeat:(CGFloat)repeat {
    [self jm_360RotateWithDuration:duration rotations:1 repeat:repeat];
}


@end
