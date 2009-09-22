//
//  OneBubbleView.m
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import "Session.h"
#import "OneBubbleView.h"
#import "BubblesView.h"
#import "BubblesAppDelegate.h"
#import "BtlUtilities.h"
#import <QuartzCore/QuartzCore.h>


#define GROW_ANIMATION_DURATION_SECONDS 0.68
#define FLOAT_ANIMATION_DURATION_SECONDS 11.5
#define MIN_SIZE_SCALAR 0.10
#define FINAL_OPACITY 0.45
#define MIN_HORIZON_RADIUS 100.0
#define MAX_HORIZON_RADIUS 320.0
#define BIRTH_OFFSET_X 40
#define BIRTH_OFFSET_Y 75

@implementation OneBubbleView

@synthesize startWidth;
@synthesize sizeScalar;
@synthesize image;
@synthesize velocity;
@synthesize popTimer;
@synthesize crazyMode;

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
			int count = [[Session sharedSession] bubbleCount];
			int style = [[Session sharedSession] bubbleStyle];
			int offset;
			if (style == 0) {
				// full spectrum
				offset = [BtlUtilities randomNumber:count];
			} else {
				// single color
				offset = count;
			}
			
      int bubbleNum = offset + 4;
			
      [self setImageByName:[NSString stringWithFormat:@"bubble%i.png", bubbleNum]];
      self.opaque = NO;
			self.crazyMode = [BtlUtilities randomChanceOutOf:13];      
    }
    return self;
}

-(void)setup {
  // scale the high res image down
//  [UIView beginAnimations:nil context:nil];
//  [UIView setAnimationDuration:0.1f];
  CGAffineTransform preTransform = CGAffineTransformMakeScale(MIN_SIZE_SCALAR+0.01f, MIN_SIZE_SCALAR+0.01f);
  self.transform = preTransform;
//  [UIView commitAnimations];
}

- (CGFloat)velocityScalar {
  return abs(100 - velocity) / 100.0f;
}

// Each bubble ends at a random point 
// within a circular area with radius determined by velocity
// where higher velocity makes a smaller radius.
- (CGPoint)computeEndPoint:(BOOL)wide {
  if (self.crazyMode) {
    CGPoint p = [BtlUtilities randomPoint];
    return CGPointMake(p.x + (106 * [BtlUtilities randomPolarity]),
                       p.y + (160 * [BtlUtilities randomPolarity]));
  } else {
    int centerX = 160;
    int centerY = 180;
    int minRadius = MIN_HORIZON_RADIUS;
    CGFloat maxRadius = MAX_HORIZON_RADIUS * [self velocityScalar];

		if (wide)
			minRadius += minRadius * 0.75f;
		if (maxRadius < MIN_HORIZON_RADIUS)
			maxRadius = MIN_HORIZON_RADIUS;

    int randomRadius = [BtlUtilities randomNumberInRange:minRadius maximum:maxRadius];
    int phi = [BtlUtilities randomNumber:360];
    int x = cos(phi) * randomRadius + centerX;
    int y = sin(phi) * randomRadius * 0.75f + centerY;
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
  point.x += [BtlUtilities randomNumber:BIRTH_OFFSET_X] * [BtlUtilities randomPolarity];
  point.y += [BtlUtilities randomNumber:BIRTH_OFFSET_Y] * [BtlUtilities randomPolarity];
  self.center = point;
	//NSLog(@"start x: %f, y: %f", point.x, point.y);
  [self setup];
  
  // scale the image back up to size
  // duration is proportional to velocity
  CGFloat duration = [self scaleDownByVelocity:GROW_ANIMATION_DURATION_SECONDS percent:50];

  [UIView beginAnimations:nil context:self];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(bubbleBirthAnimationDidStop:finished:context:)];

  // Higher velocity means smaller bubbles
  self.sizeScalar = [self scaleDownByVelocity:1 percent:95];
  
  if (self.sizeScalar < MIN_SIZE_SCALAR) { self.sizeScalar = MIN_SIZE_SCALAR; }
	//NSLog(@"vel: %i, sizeScalar: %f", self.velocity, self.sizeScalar);
  CGAffineTransform transform = CGAffineTransformMakeScale(self.sizeScalar, self.sizeScalar);
  
  // The varier is used to move the birth end point
  int varier = [self scaleDownByVelocity:30 percent:90];
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
  CGFloat duration = [self scaleDownByVelocity:FLOAT_ANIMATION_DURATION_SECONDS percent:60];
	oneBubble.alpha = 1.0f;
	CGRect imageFrame = [[oneBubble.layer presentationLayer] frame];
	CGPoint viewOrigin = [[oneBubble.layer presentationLayer] position];
	
	// Set up fade out effect
	CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  if (self.crazyMode) {
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:FINAL_OPACITY / 2.0f]];
  } else {
  	[fadeOutAnimation setToValue:[NSNumber numberWithFloat:FINAL_OPACITY]];
  }
	fadeOutAnimation.fillMode = kCAFillModeBackwards;
	fadeOutAnimation.removedOnCompletion = NO;
	
	// Set up rotation
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
	NSNumber *radians = [NSNumber numberWithFloat:(([BtlUtilities randomNumber:70] + 5) * 
											 [BtlUtilities randomPolarity] * M_PI / 180.0f)];
  rotationAnimation.toValue = radians;
	
	// Set up scaling
	CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
	CGFloat endScalar = MIN_SIZE_SCALAR;//oneBubble.sizeScalar * 0.2;
	[resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(
			imageFrame.size.width * endScalar,
			imageFrame.size.height * endScalar)]];
	resizeAnimation.fillMode = kCAFillModeForwards;
	resizeAnimation.removedOnCompletion = NO;
	
	// Set up pulsation
	CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
  CGFloat pulseFactor = self.sizeScalar * 0.94f;
	[pulseAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(
			imageFrame.size.width / pulseFactor,
			imageFrame.size.height / pulseFactor)]];
  pulseAnimation.fillMode = kCAFillModeBackwards; 
  pulseAnimation.autoreverses = YES;
  pulseAnimation.repeatCount = 50;
  pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	pulseAnimation.removedOnCompletion = NO;
	pulseAnimation.duration = [BtlUtilities randomNumberInRange:50 maximum:100] / 100.0f;
  
  
	// Set up path movement
  CAAnimation *pathAnimation;
  if (self.crazyMode) {
    CABasicAnimation *tmpPathAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    tmpPathAnimation.toValue = [NSValue valueWithCGPoint:[self computeEndPoint:NO]];
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
    CGPoint midPoint = [self computeEndPoint:YES];
    CGPoint endPoint = [self computeEndPoint:NO];
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
	group.autoreverses = self.crazyMode;
	group.fillMode = kCAFillModeForwards;
	group.removedOnCompletion = NO;
	[group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, 
			rotationAnimation, pulseAnimation, resizeAnimation, nil]];
	group.duration = duration;
	group.delegate = self;
	[group setValue:oneBubble forKey:@"viewBeingAnimated"];
	
	[oneBubble.layer addAnimation:group forKey:@"floatAnimation"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	OneBubbleView *bubble = (OneBubbleView*)[theAnimation valueForKey:@"viewBeingAnimated"];
	[(BubblesView*)self.superview releaseBubble:bubble withSound:nil];
}

- (void)drawRect:(CGRect)rect {
  CGFloat alpha = 1.0f;

//	CGRect frame = 
//	NSLog(@"bubble view frame: %f", frame.size.width);
//  frame.size.width = frame.size.height = self.image.size.width;
//  frame.origin.x = frame.origin.y = 0.0f;
	
	CGRect frame = [self bounds];
//	NSLog(@"bubble view frame: %f", frame.size.width);
  frame.size.width = frame.size.height = self.image.size.width;
  //frame.origin.x = frame.origin.y = 0.5f;

  [self.image drawInRect:frame blendMode:kCGBlendModeNormal alpha:alpha];
	
	//NSString *str = [NSString stringWithFormat:@"%i", self.tag];
	//[str drawAtPoint:CGPointMake(0,0) withFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
}

- (void)setImageByName:(NSString*)name {
  self.image = [UIImage imageNamed:name];
	//self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
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
