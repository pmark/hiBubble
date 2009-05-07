//
//  OneBubbleView.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OneBubbleView.h"
#import <QuartzCore/QuartzCore.h>


#define GROW_ANIMATION_DURATION_SECONDS 0.4
#define FLOAT_ANIMATION_DURATION_SECONDS 1.8


@implementation OneBubbleView

UIColor * randomColor() {return [UIColor colorWithRed:(rand() % 10 / 10.0f) green:(rand() % 10 / 10.0f) blue:(rand() % 10 / 10.0f) alpha:0.6f];}

int randomNumberInRange(int min, int max) {
  return rand() % (max - min) + min;
}

int randomNumber(int max) {
  return randomNumberInRange(0, max);
}

int randomPolarity() {
  return (randomNumber(2) == 0) ? 1 : -1; 
}

@synthesize startWidth;
@synthesize image;
@synthesize velocity;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
      NSString *imgName;
      if (randomNumber(2) == 0) {
        imgName = @"bubble1.png";
      } else {
        imgName = @"bubble2.png";
      }
      
      imgName = @"bubble2.png";
      [self setImageByName:imgName];
      //self.backgroundColor = randomColor();
      self.opaque = NO;
    }
    return self;
}

-(void)setup {
  // scale the high res image down
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.1f];
  CGAffineTransform preTransform = CGAffineTransformMakeScale(0.1f, 0.1f);  
  self.transform = preTransform;
  [UIView commitAnimations];
}

- (CGFloat)velocityScalar {
  return abs(100 - velocity) / 100.0f;
}

- (void)setCenterToEndPoint {
  int minRadius = 10;  
  CGFloat maxRadius = 240.0f;  
  CGFloat scaledRadius = maxRadius * [self velocityScalar];
  NSLog(@"scaledRadius: %f", scaledRadius);
  int radius = scaledRadius + minRadius;
  int randomRadius = randomNumber(radius);
  int phi = randomNumber(360);
  int x = cos(phi) * randomRadius + 160;
  int y = sin(phi) * randomRadius * 0.33f + 210;
  self.center = CGPointMake(x, y);
}

-(void)animateBirthAtPoint:(CGPoint)point {
  
  // move bubble to point
  self.center = point;

  [self setup];
  
  // scale the image back up to size
  [UIView beginAnimations:nil context:self];
  [UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(bubbleBirthAnimationDidStop:finished:context:)];
  
  int dir = randomPolarity();
  CGFloat scaleValue = (randomNumber(70) / 100.0f) + 0.1f;
  
  CGAffineTransform transform = CGAffineTransformConcat(
      CGAffineTransformMakeScale(scaleValue, scaleValue),
      CGAffineTransformMakeRotation(randomNumber(85) * dir));
  
  self.transform = transform;
  [UIView commitAnimations];
  // the oneBubble instance will be released when animation ends  
}

- (void)bubbleBirthAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
  OneBubbleView *oneBubble = (OneBubbleView*)context;
  [self animateFloatPhase:oneBubble];
}

-(void)animateFloatPhase:(OneBubbleView*)oneBubble {
  CGFloat duration = FLOAT_ANIMATION_DURATION_SECONDS * ([self velocityScalar] + 0.2f);
	[UIView beginAnimations:nil context:oneBubble];
	[UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDidStopSelector:@selector(bubbleFloatPhaseAnimationDidStop:finished:context:)];
  [UIView setAnimationDelegate:oneBubble];
   
  CGAffineTransform transform = CGAffineTransformConcat(
      CGAffineTransformMakeScale(0.05f, 0.05f),
      CGAffineTransformMakeRotation(randomNumber(180) + 180.0f));

  oneBubble.transform = transform;
  [oneBubble setCenterToEndPoint];
  
  // fade out too
  [CATransaction setValue:[NSNumber numberWithFloat:duration+0.02f] forKey:kCATransactionAnimationDuration];
  CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fadeAnimation.toValue = [NSNumber numberWithFloat:0.05f];
  fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  [[oneBubble layer] addAnimation:fadeAnimation forKey:@"fadeAnimation"];  
  
	[UIView commitAnimations];
}

- (void)bubbleFloatPhaseAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
  OneBubbleView *oneBubble = (OneBubbleView*)context;
  [oneBubble removeFromSuperview];
	[oneBubble release];
}

- (void)drawRect:(CGRect)rect {
  CGFloat alpha = (randomNumber(30) / 100.0f) + 0.40f;
  CGRect frame = [self frame];
  frame.size.width = frame.size.height = self.image.size.width;  
  frame.origin.x = frame.origin.y = 0.0f;
  [self.image drawInRect:frame blendMode:kCGBlendModeDifference alpha:alpha];
}

- (void)dealloc {
    [super dealloc];
}


- (void)setImageByName:(NSString *)name {
  self.image = [UIImage imageNamed:name];
}

@end
