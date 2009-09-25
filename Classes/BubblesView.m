//
//  BubblesView.m
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import "BubblesView.h"
#import "OneBubbleView.h"
#import "Session.h"
#import "BubblesAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define BUBBLE_IMAGE_WIDTH 280

@implementation BubblesView

@synthesize wandCenterPoint, wandImage, bubbleCounter, shakeDelegate, underlay;

-(void)initBubbleCounter {
	bubbleCounter = 0;
}

- (void)launchBubble:(NSInteger)velocity {
  CGRect bubbleFrame = CGRectMake(0.0f, 0.0f, BUBBLE_IMAGE_WIDTH, BUBBLE_IMAGE_WIDTH);

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
	for (UIView *subview in self.subviews) {
    if ([[[subview class] description] isEqualToString:@"OneBubbleView"]) {
      [self releaseBubble:(OneBubbleView*)subview withSound:nil];
    }
	}
}

-(void)releaseBubbleSilently:(OneBubbleView*)bubbleView {
  [self releaseBubble:bubbleView withSound:nil];
}

-(void)releaseBubble:(OneBubbleView*)bubbleView withSound:(NSString*)soundName {
	// this calls release
  [bubbleView.layer removeAllAnimations];
  [bubbleView removeFromSuperview];

	// TODO: check for memory leak with Instruments
	[bubbleView release];	
  
  if (soundName != nil) {
		[(BubblesAppDelegate*)[[UIApplication sharedApplication] delegate] playSoundFile:soundName];	
	}  
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

/*
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event { 
	//NSLog(@"shake BubblesView!");

	[super motionBegan: motion withEvent: event]; 
//	if ((motion == UIEventSubtypeMotionShake) && 
//				[self.shakeDelegate respondsToSelector:@selector(shakeMotionBegan:)]) { 
//		[self.shakeDelegate shakeMotionBegan:event]; 
//	} 
	
	// TODO: test tilt effect
	// for each bubble, translate Y by some amount
	for (UIView *subview in self.subviews) {
    if ([[[subview class] description] isEqualToString:@"OneBubbleView"]) {
			NSLog(@"set center to %f, %f", subview.center.x, subview.center.y);
			
			[[subview layer] removeAllAnimations];
				
			 [UIView beginAnimations:nil context:subview];
			 [UIView setAnimationDuration:1.5];
			 [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//			 [UIView setAnimationDelegate:self];
//			 [UIView setAnimationDidStopSelector:@selector(bubbleBirthAnimationDidStop:finished:context:)];
			 
			CGPoint viewOrigin = [[subview.layer presentationLayer] position];
			subview.center = CGPointMake(viewOrigin.x, viewOrigin.y + 350);
			[UIView commitAnimations];

    }
	}
} 
*/

- (void)dealloc {
  [super dealloc];
  [underlay release];
  NSLog(@"\n\nBubblesView dealloc\n\n");
}


@end
