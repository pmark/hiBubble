//
//  BubblesView.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BubblesView.h"
#import "OneBubbleView.h"
#import "Session.h"
#import "BubblesAppDelegate.h"
#import <QuartzCore/QuartzCore.h>


@implementation BubblesView

@synthesize wandCenterPoint, wandImage, bubbleCounter, shakeDelegate;

-(void)initBubbleCounter {
	bubbleCounter = 0;
}

- (void)launchBubble:(NSInteger)velocity {
  CGRect bubbleFrame = CGRectMake(10.0f, 0.0f, 155.0f, 155.0f);

  OneBubbleView *oneBubble = [[OneBubbleView alloc] initWithFrame:bubbleFrame];
	oneBubble.tag = [self nextBubbleTag];
	if (velocity && velocity > 0) {
		oneBubble.velocity = velocity;
	} else {
		oneBubble.velocity = [[Session sharedSession] getVelocity];
	}
  [self addSubview:oneBubble];
  [oneBubble animateBirthAtPoint:self.wandCenterPoint];
}

-(void)popBubble:(OneBubbleView*)bubbleView {
	[self releaseBubble:bubbleView withSound:@"pop1"];
}

-(void)popAllBubbles {
	for (OneBubbleView *bubble in self.subviews) {
		[self releaseBubble:bubble withSound:nil];
	}
}

-(void)releaseBubbleSilently:(OneBubbleView*)bubbleView {
  [self releaseBubble:bubbleView withSound:nil];
}

-(void)releaseBubble:(OneBubbleView*)bubbleView withSound:(NSString*)soundName {
	// this calls release
  [bubbleView removeFromSuperview];

	if (soundName != nil) {
		[(BubblesAppDelegate*)[[UIApplication sharedApplication] delegate] playSoundFile:soundName ofType:@"aif"];	
	}
	
	// TODO: check for memory leak with Instruments
	[bubbleView release];	
}


/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {	
  // probably don't care about this event
	//UITouch *touch = [touches anyObject];	
  //CGPoint location = [touch locationInView:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  // not sure why/when this happens
}
*/

/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {	

  // Disable user interaction so subsequent touches don't interfere with animation
  //self.userInteractionEnabled = NO;
	if ([touches count] == [[event touchesForView:self] count]) {
			// last finger has lifted....
	}
	
	/////////////
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self]; 
	//NSLog(@"Touch count: %i", [touch tapCount]);

	for (OneBubbleView *oneBubble in [self.subviews reverseObjectEnumerator]) {
		CGPoint bubbleCenter = [[oneBubble.layer presentationLayer] position]; 
	
		if ([touch tapCount] == 1) {
			if (CGRectContainsPoint([[oneBubble.layer presentationLayer] frame], point) == 1) {
			//if (CGRectContainsPoint([oneBubble.layer frame], point) == 1) {
				NSLog(@"Bubble %i touched from parent", oneBubble.tag);
				[self popBubble:oneBubble];	
				break;
			}
		} else {
			// double tap centers all bubbles on finger

			oneBubble.center = point;
			// TODO: probably make a path to the new point.
//			CABasicAnimation *centerAnimation;
//			centerAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//			centerAnimation.toValue	= [NSValue valueWithCGPoint:point];
//			centerAnimation.duration	= 0.8;
//			centerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//			centerAnimation.removedOnCompletion = NO;
//			centerAnimation.fillMode = kCAFillModeBoth;
//			centerAnimation.cumulative = YES;
//			[oneBubble.layer addAnimation:centerAnimation forKey:@"centerOnPoint"];

		}
	}

}
*/

- (void)drawRect:(CGRect)rect {
  // TODO: render the wand (above the bubbles)
  //[self.wandImage drawInRect:wandFrame];
}

-(NSInteger)nextBubbleTag {
	if (self.bubbleCounter == NSIntegerMin) {
		self.bubbleCounter = 0;
	}
	return self.bubbleCounter--;
}

- (BOOL)canBecomeFirstResponder { return YES; }

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event { 
	[super motionBegan: motion withEvent: event]; 
	if ((motion == UIEventSubtypeMotionShake) && 
				[self.shakeDelegate respondsToSelector:@selector(shakeMotionBegan:)]) { 
		[self.shakeDelegate shakeMotionBegan:event]; 
	} 
} 

- (void)dealloc {
  [super dealloc];
}


@end
