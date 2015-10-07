//
//  CoreImageMotionBlurTransitionView.m
//  TTMAnimatedTransitionGallery
//
//  Created by Shuichi Tsutsumi on 10/7/15.
//  Copyright © 2015 Shuichi Tsutsumi. All rights reserved.
//

#import "CoreImageMotionBlurTransitionView.h"


static CGFloat positionDelta(CGPoint previousPosition, CGPoint currentPosition)
{
    const CGFloat dx = fabs(currentPosition.x - previousPosition.x);
    const CGFloat dy = fabs(currentPosition.y - previousPosition.y);
    return sqrt(pow(dx, 2) + pow(dy, 2));
}

static CGFloat opacityFromPositionDelta(CGFloat delta, CFTimeInterval tickDuration)
{
    const NSInteger expectedFPS = 60;
    const CFTimeInterval expectedDuration = 1.0 / expectedFPS;
    const CGFloat normalizedDelta = delta * expectedDuration / tickDuration;
    
    // A rough approximation of an opacity for a good looking blur. The larger the delta (movement velocity), the larger opacity of the blur layer.
    const CGFloat unboundedOpacity = log2(normalizedDelta) / 5.0f;
    return (CGFloat)fmax(fmin(unboundedOpacity, 1.0), 0.0);
}


@interface CoreImageMotionBlurTransitionView ()
{
    CGPoint prevPos;
}
@end


@implementation CoreImageMotionBlurTransitionView

- (void)start {
    prevPos = ((CALayer *)self.layer.presentationLayer).position;
    
    [super start];
}

- (CIImage *)imageForTransitionAtTime:(float)time
{
    [self.transition setValue:self.inputImage forKey:kCIInputImageKey];

    CGPoint currentPos = ((CALayer *)self.layer.presentationLayer).position;
    CGFloat delta = positionDelta(prevPos, currentPos);
    prevPos = currentPos;

    CGFloat radius = delta;
    if (radius < 1.0) {
        radius = 1.0;
    }
    else if (radius > 70) {
        radius = 70.0;
    }
//    NSLog(@"delta:%f, radius:%f", delta, radius);

    [self.transition setValue:@(radius) forKey:kCIInputRadiusKey];
    
//    if (currentPos.x - prevPos.x > 0) {
//        [self.transition setValue:@(0.0) forKey:kCIInputAngleKey];
//    }
//    else {
//        [self.transition setValue:@(M_PI) forKey:kCIInputAngleKey];
//    }

    CIImage *transitionImage = [self.transition valueForKey:kCIOutputImageKey];
    
    
    return transitionImage;
}

@end
