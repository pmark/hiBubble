//
//  OneBubbleView.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OneBubbleView.h"
#import "BubblesView.h"
#import "BubblesAppDelegate.h"
#import <QuartzCore/QuartzCore.h>


#define GROW_ANIMATION_DURATION_SECONDS 0.6
#define FLOAT_ANIMATION_DURATION_SECONDS 7.0
#define MIN_BUBBLE_SCALAR 0.8
#define FINAL_OPACITY 0.25
#define MAX_HORIZON_RADIUS 150.0

@implementation OneBubbleView

UIColor * randomColor() {return [UIColor colorWithRed:(rand() % 10 / 10.0f) green:(rand() % 10 / 10.0f) blue:(rand() % 10 / 10.0f) alpha:0.6f];}

int randomNumberInRange(int min, int max) {
  int range = (max - min);
  if (range == 0) {range = 1;}
  return rand() % range + min;
}

int randomNumber(int max) {
  return randomNumberInRange(0, max);
}

int randomPolarity() {
  return (randomNumber(2) == 0) ? 1 : -1; 
}

@synthesize startWidth;
@synthesize sizeScalar;
@synthesize image;
@synthesize velocity;
@synthesize popTimer;

+ (NSString*)defaultImageName {
  return @"bubble1.png";
}

- (void)createPopTimer {
  CGFloat lifespan = randomNumber(FLOAT_ANIMATION_DURATION_SECONDS / 2.0f) + 1.0;
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
      int bubbleNum = randomNumber(3) + 1;
      [self setImageByName:[NSString stringWithFormat:@"bubble%i.png", bubbleNum]];
      self.opaque = NO;
      
			/*
			// randomly pop some bubbles
      if (randomNumber(4) == 0) {
        [self createPopTimer];        
      }
			*/
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
  int centerX = 160;
  int centerY = 180;
  int minRadius = 65;  
  CGFloat maxRadius = MAX_HORIZON_RADIUS;  
  CGFloat scaledRadius = maxRadius * [self velocityScalar];
  int radius = scaledRadius + minRadius;
  int randomRadius = randomNumber(radius);
  int phi = randomNumber(360);
  int x = cos(phi) * randomRadius + centerX;
  int y = sin(phi) * randomRadius * 0.33f + centerY;
  return CGPointMake(x, y);
}

- (void)setCenterToEndPoint {
  int centerX = 160;
  int centerY = 180;
  int minRadius = 65;  
  CGFloat maxRadius = 190.0f;  
  CGFloat scaledRadius = maxRadius * [self velocityScalar];
  int radius = scaledRadius + minRadius;
  int randomRadius = randomNumber(radius);
  int phi = randomNumber(360);
  int x = cos(phi) * randomRadius + centerX;
  int y = sin(phi) * randomRadius * 0.33f + centerY;
  self.center = CGPointMake(x, y);
}

-(void)animateBirthAtPoint:(CGPoint)point {
  point.x += randomNumber(16) * randomPolarity();
  point.y += randomNumber(14) * randomPolarity();
  self.center = point;
  [self setup];
  
  // scale the image back up to size
  // duration is proportional to velocity
  CGFloat duration = GROW_ANIMATION_DURATION_SECONDS * (([self velocityScalar] + 0.2f) / 2.0f);

  [UIView beginAnimations:nil context:self];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(bubbleBirthAnimationDidStop:finished:context:)];

  // Higher velocity means smaller bubbles
  int randomRange = (1.0f - MIN_BUBBLE_SCALAR) * 100 + 1;
  self.sizeScalar = (randomNumber(randomRange) * [self velocityScalar]) / 100.0f + MIN_BUBBLE_SCALAR;
  if (self.sizeScalar < MIN_BUBBLE_SCALAR) { self.sizeScalar = MIN_BUBBLE_SCALAR; }
  CGAffineTransform transform = CGAffineTransformMakeScale(self.sizeScalar, self.sizeScalar);
  
  // The varier is used to move the birth end point
  int varier = randomNumber(20) * [self velocityScalar];
  self.center = CGPointMake(self.center.x + (varier * randomPolarity()), 
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
	oneBubble.alpha = 1.0f;
	CGRect imageFrame = oneBubble.layer.frame;
	CGPoint viewOrigin = oneBubble.layer.position;
	
	// Set up fade out effect
	CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[fadeOutAnimation setToValue:[NSNumber numberWithFloat:FINAL_OPACITY]];
	fadeOutAnimation.fillMode = kCAFillModeForwards;
	fadeOutAnimation.removedOnCompletion = NO;
	
	// Set up rotation
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
	NSNumber *radians = [NSNumber numberWithFloat:((randomNumber(160) + 33) * randomPolarity() * M_PI / 180.0f)];
  rotationAnimation.toValue = radians;
//	NSLog(@"rot to: %@", rotationAnimation.toValue * M_PI / 180);
			
	// Set up scaling
	CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
	CGFloat endScalar = oneBubble.sizeScalar * 0.4f;

	[resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(
			imageFrame.size.width * endScalar,
			imageFrame.size.height * endScalar)]];
	resizeAnimation.fillMode = kCAFillModeForwards;
	resizeAnimation.removedOnCompletion = NO;
	
	// Set up path movement
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	pathAnimation.calculationMode = kCAAnimationPaced;
	pathAnimation.fillMode = kCAFillModeForwards;
	pathAnimation.removedOnCompletion = NO;
	[pathAnimation setTimingFunctions:[NSArray arrayWithObjects:
			[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
			[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil]];
	
	CGPoint startPoint = CGPointMake(
			oneBubble.layer.position.x + randomNumberInRange(30, 70) * randomPolarity(), 
			oneBubble.layer.position.y + randomNumberInRange(80, 200) * randomPolarity());
	CGPoint midPoint = [self computeEndPoint];
	CGPoint endPoint = [self computeEndPoint];
	CGMutablePathRef curvedPath = CGPathCreateMutable();
			
	CGPathMoveToPoint(curvedPath, 
			NULL,
			viewOrigin.x, viewOrigin.y);
	CGPathAddCurveToPoint(curvedPath, NULL, startPoint.x, startPoint.y, midPoint.x, midPoint.y, endPoint.x, endPoint.y);
	pathAnimation.path = curvedPath;
	//pathAnimation.duration = FLOAT_ANIMATION_DURATION_SECONDS / 2.0f;
	CGPathRelease(curvedPath);
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.delegate = self;
	group.autoreverses = NO;
	group.fillMode = kCAFillModeForwards;
	group.removedOnCompletion = NO;
	[group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, 
			resizeAnimation, rotationAnimation, nil]];
	group.duration = FLOAT_ANIMATION_DURATION_SECONDS;
	group.delegate = self;
	[group setValue:oneBubble forKey:@"viewBeingAnimated"];
	
	[oneBubble.layer addAnimation:group forKey:@"savingAnimation"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	OneBubbleView *bubble = (OneBubbleView*)[theAnimation valueForKey:@"viewBeingAnimated"];
	[(BubblesView*)self.superview releaseBubble:bubble];
}

- (void)bubbleFloatPhaseAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[(BubblesView*)self.superview releaseBubble:(OneBubbleView*)context];
}

-(void)animateFloatPhase2:(OneBubbleView*)oneBubble {
  CGFloat duration = FLOAT_ANIMATION_DURATION_SECONDS * ([self velocityScalar] + 0.3f);
	[UIView beginAnimations:nil context:oneBubble];
	[UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDidStopSelector:@selector(bubbleFloatPhaseAnimationDidStop:finished:context:)];
  [UIView setAnimationDelegate:oneBubble];
  
  CGFloat endScalar = oneBubble.sizeScalar * 0.4f;
  CGAffineTransform transform = CGAffineTransformConcat(
      CGAffineTransformMakeScale(endScalar, endScalar),
      CGAffineTransformMakeRotation((randomNumber(120) + 33) * randomPolarity()));

  oneBubble.transform = transform;
  [oneBubble setCenterToEndPoint];
  
  // fade out too
  [CATransaction setValue:[NSNumber numberWithFloat:duration+0.3f] forKey:kCATransactionAnimationDuration];
  CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fadeAnimation.toValue = [NSNumber numberWithFloat:FINAL_OPACITY];
  fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  [[oneBubble layer] addAnimation:fadeAnimation forKey:@"fadeAnimation"];  
  
	[UIView commitAnimations];
}

- (void)drawRect:(CGRect)rect {
  CGFloat alpha = (randomNumber(30) / 100.0f) + 0.5f;
	CGRect frame = [self bounds];
  frame.size.width = frame.size.height = self.image.size.width;
  frame.origin.x = frame.origin.y = 0.0f;

  [self.image drawInRect:frame blendMode:kCGBlendModeDifference alpha:alpha];
	
	NSString *str = [NSString stringWithFormat:@"%i", self.tag];
	[str drawAtPoint:CGPointMake(0,0) withFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
}

- (void)setImageByName:(NSString*)name {
  self.image = [UIImage imageNamed:name];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self]; 
	if (CGRectContainsPoint([[self.layer presentationLayer] frame], point) == 1) {
		NSLog(@"Bubble %i touched", self.tag);	
		[(BubblesView*)self.superview popBubble:self];	
	}
}

- (void)dealloc {
  //[self.image dealloc];
  [super dealloc];
}

@end
