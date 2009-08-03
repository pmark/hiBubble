//
//  OneBubbleView.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import "Session.h"
#import "OneBubbleView.h"
#import "BubblesView.h"
#import "BubblesAppDelegate.h"
#import "BtlUtilities.h"
#import <QuartzCore/QuartzCore.h>


#define GROW_ANIMATION_DURATION_SECONDS 0.78
#define FLOAT_ANIMATION_DURATION_SECONDS 11.5
#define MIN_SIZE_SCALAR 0.52
#define FINAL_OPACITY 0.6
#define MIN_HORIZON_RADIUS 220.0
#define MAX_HORIZON_RADIUS 270.0

@implementation OneBubbleView

@synthesize startWidth;
@synthesize sizeScalar;
@synthesize image;
@synthesize velocity;
@synthesize popTimer;

+ (NSString*)defaultImageName {
  return @"bubble1.png";
}

- (void)createPopTimer {
  CGFloat lifespan = [BtlUtilities randomNumber:FLOAT_ANIMATION_DURATION_SECONDS / 2.0f] + 1.0;
	self.popTimer = [NSTimer scheduledTimerWithTimeInterval: lifespan
                                                    target:	self
                                                  selector:	@selector(popBubble:)
                                                  userInfo:	nil	
                                                   repeats:	NO];
}

- (void)popBubble:(NSTimer *)timer {
	[(BubblesView*)self.superview popBubble:self];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
      // only select bubble 2, 3, or 4
      int bubbleNum = [BtlUtilities randomNumber:3] + 1;
      [self setImageByName:[NSString stringWithFormat:@"bubble%i.png", bubbleNum]];
      self.opaque = NO;
      
			// randomly pop some bubbles
//      if ([BtlUtilities randomNumber:6] == 0) {
//        [self createPopTimer];        
//      }
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

// Each bubble ends at a random point 
// within a circular area with radius determined by velocity
// where higher velocity makes a smaller radius.
- (CGPoint)computeEndPoint {
  if ([[Session sharedSession] crazyMode]) {
    CGPoint p = [BtlUtilities randomPoint];
    return CGPointMake(p.x + (106 * [BtlUtilities randomPolarity]),
                       p.y + (160 * [BtlUtilities randomPolarity]));
    
  } else {
    int centerX = 160;
    int centerY = 180;
    int minRadius = MIN_HORIZON_RADIUS;
    CGFloat maxRadius = MAX_HORIZON_RADIUS;
    CGFloat scaledRadius = maxRadius * [self velocityScalar];
    int radius = scaledRadius + minRadius;
    int randomRadius = [BtlUtilities randomNumber:radius];
    int phi = [BtlUtilities randomNumber:360];
    int x = cos(phi) * randomRadius + centerX;
    int y = sin(phi) * randomRadius * 0.33f + centerY;
    return CGPointMake(x, y);
  }
}

- (void)setCenterToEndPoint {
  int centerX = 160;
  int centerY = 180;
  int minRadius = 65;  
  CGFloat maxRadius = 190.0f;  
  CGFloat scaledRadius = maxRadius * [self velocityScalar];
  int radius = scaledRadius + minRadius;
  int randomRadius = [BtlUtilities randomNumber:radius];
  int phi = [BtlUtilities randomNumber:360];
  int x = cos(phi) * randomRadius + centerX;
  int y = sin(phi) * randomRadius * 0.33f + centerY;
  self.center = CGPointMake(x, y);
}

// percent: 0 - 100: factor of velocity to use
-(CGFloat)scaleDownByVelocity:(CGFloat)original percent:(NSInteger)percent {
  CGFloat factor = percent / 100.0;
  return original - (original * ((1.0 - [self velocityScalar]) * factor));
}

-(void)animateBirthAtPoint:(CGPoint)point {
  point.x += [BtlUtilities randomNumber:16] * [BtlUtilities randomPolarity];
  point.y += [BtlUtilities randomNumber:14] * [BtlUtilities randomPolarity];
  self.center = point;
  [self setup];
  
  // scale the image back up to size
  // duration is proportional to velocity
  CGFloat duration = [self scaleDownByVelocity:GROW_ANIMATION_DURATION_SECONDS percent:45];

  [UIView beginAnimations:nil context:self];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(bubbleBirthAnimationDidStop:finished:context:)];

  // Higher velocity means smaller bubbles
  self.sizeScalar = 0.999 - [self scaleDownByVelocity:1 percent:90];
  
  if (self.sizeScalar < MIN_SIZE_SCALAR) { self.sizeScalar = MIN_SIZE_SCALAR; }
  CGAffineTransform transform = CGAffineTransformMakeScale(self.sizeScalar, self.sizeScalar);
  
  // The varier is used to move the birth end point
  int varier = [BtlUtilities randomNumber:20] * [self velocityScalar];
  self.center = CGPointMake(self.center.x + (varier * [BtlUtilities randomPolarity]), 
                            self.center.y - varier);
  self.transform = transform;
  [UIView commitAnimations];
  // the oneBubble instance will be released when animation ends  
}

- (void)bubbleBirthAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
  OneBubbleView *oneBubble = (OneBubbleView*)context;
  [self animateFloatPhase:oneBubble];
}

-(void)animateFloatPhase:(OneBubbleView*)oneBubble {
  //CGFloat duration = FLOAT_ANIMATION_DURATION_SECONDS + ([self velocityScalar] * 5);
  CGFloat duration = [self scaleDownByVelocity:FLOAT_ANIMATION_DURATION_SECONDS percent:65];
	oneBubble.alpha = 1.0f;
	CGRect imageFrame = [[oneBubble.layer presentationLayer] frame];
	CGPoint viewOrigin = [[oneBubble.layer presentationLayer] position];
	//CGRect imageFrame = oneBubble.layer.frame;
	//CGPoint viewOrigin = oneBubble.layer.position;
	
	// Set up fade out effect
	CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  if ([[Session sharedSession] crazyMode]) {
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:FINAL_OPACITY / 2.0f]];
  } else {
  	[fadeOutAnimation setToValue:[NSNumber numberWithFloat:FINAL_OPACITY]];
  }
	fadeOutAnimation.fillMode = kCAFillModeBackwards;
	fadeOutAnimation.removedOnCompletion = NO;
	
	// Set up rotation
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
	NSNumber *radians = [NSNumber numberWithFloat:(([BtlUtilities randomNumber:360] + 33) * 
											 [BtlUtilities randomPolarity] * M_PI / 180.0f)];
  rotationAnimation.toValue = radians;
			
	// Set up scaling
	CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
	CGFloat endScalar = 0.70f; //oneBubble.sizeScalar * 0.2;

	[resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(
			imageFrame.size.width * endScalar,
			imageFrame.size.height * endScalar)]];
	resizeAnimation.fillMode = kCAFillModeForwards;
	resizeAnimation.removedOnCompletion = NO;
	
	// Set up pulsation
	CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
  CGFloat pulseFactor = self.sizeScalar * 0.91f;
	[pulseAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(
			imageFrame.size.width / pulseFactor,
			imageFrame.size.height / pulseFactor)]];
  pulseAnimation.fillMode = kCAFillModeBackwards; 
  pulseAnimation.autoreverses = YES;
  pulseAnimation.repeatCount = 50;
  pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	pulseAnimation.removedOnCompletion = NO;
	pulseAnimation.duration = [BtlUtilities randomNumberInRange:30 maximum:100] / 100.0f;
  
  
	// Set up path movement
  CAAnimation *pathAnimation;
  if ([[Session sharedSession] crazyMode]) {
    CABasicAnimation *tmpPathAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    tmpPathAnimation.toValue = [NSValue valueWithCGPoint:[self computeEndPoint]];
    pathAnimation = tmpPathAnimation;
  } else {
    CAKeyframeAnimation *tmpPathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    tmpPathAnimation.calculationMode = kCAAnimationPaced;
    tmpPathAnimation.fillMode = kCAFillModeForwards;
    tmpPathAnimation.removedOnCompletion = NO;
    [tmpPathAnimation setTimingFunctions:[NSArray arrayWithObjects:
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil]];
    
    CGPoint startPoint = CGPointMake(
        oneBubble.layer.position.x + [BtlUtilities randomNumberInRange:30 maximum:70] * 
                                     [BtlUtilities randomPolarity], 
        oneBubble.layer.position.y + [BtlUtilities randomNumberInRange:80 maximum:200] * 
                                     [BtlUtilities randomPolarity]);
    CGPoint midPoint = [self computeEndPoint];
    CGPoint endPoint = [self computeEndPoint];
    CGMutablePathRef curvedPath = CGPathCreateMutable();
        
    CGPathMoveToPoint(curvedPath, 
        NULL,
        viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, startPoint.x, startPoint.y, midPoint.x, midPoint.y, endPoint.x, endPoint.y);
    tmpPathAnimation.path = curvedPath;
    pathAnimation = tmpPathAnimation;
    CGPathRelease(curvedPath);
  }
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.delegate = self;
	group.autoreverses = [[Session sharedSession] crazyMode];
	group.fillMode = kCAFillModeForwards;
	group.removedOnCompletion = NO;
	[group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, 
			rotationAnimation, pulseAnimation, resizeAnimation, nil]];
	group.duration = duration;
	group.delegate = self;
	[group setValue:oneBubble forKey:@"viewBeingAnimated"];
	
	[oneBubble.layer addAnimation:group forKey:@"savingAnimation"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	OneBubbleView *bubble = (OneBubbleView*)[theAnimation valueForKey:@"viewBeingAnimated"];
	[(BubblesView*)self.superview releaseBubble:bubble withSound:nil];
}

- (void)drawRect:(CGRect)rect {
  //CGFloat alpha = ([BtlUtilities randomNumber:20] / 100.0f) + 0.8f;
  CGFloat alpha = 0.8f;
	CGRect frame = [self bounds];
  frame.size.width = frame.size.height = self.image.size.width;
  frame.origin.x = frame.origin.y = 0.0f;

  [self.image drawInRect:frame blendMode:kCGBlendModeDifference alpha:alpha];
	
	//NSString *str = [NSString stringWithFormat:@"%i", self.tag];
	//[str drawAtPoint:CGPointMake(0,0) withFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
}

- (void)setImageByName:(NSString*)name {
  self.image = [UIImage imageNamed:name];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [Session sharedSession].machineOn = NO;    
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];

  if ([touch tapCount] == 1 &&
      CGRectContainsPoint([[self.layer presentationLayer] frame], point) == 1) {
    [(BubblesView*)self.superview popBubble:self];	
  }
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//}

- (void)dealloc {
  //[self.image dealloc];
  [super dealloc];
}

@end
