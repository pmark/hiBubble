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


@implementation BubblesView

@synthesize wandImage, bubbleStack;

CGPoint randomPointBetween(NSInteger x, NSInteger y) {
  return CGPointMake(random() % x, random() % y);
}
CGPoint randomPoint() {return randomPointBetween(256, 396);}

-(void)initBubbleStack {
	bubbleStack = [[NSMutableArray alloc] init];
}

- (CGPoint)wandCenterPoint {
  // 316 = 480 * 0.66
  return CGPointMake(160.0f, 316.0f);
}

- (void)launchBubble {
  CGRect bubbleFrame = CGRectMake(10.0f, 0.0f,
                                  155.0f, 155.0f);

  OneBubbleView *oneBubble = [[OneBubbleView alloc] initWithFrame:bubbleFrame];
  oneBubble.velocity = [[Session sharedSession] getVelocity];
  [self addSubview:oneBubble];
  [oneBubble animateBirthAtPoint:[self wandCenterPoint]];
	
	// push bubble onto stack
	[bubbleStack addObject:oneBubble];
}

-(void)popBubble:(OneBubbleView*)bubbleView {
	[bubbleView retain];
	
	// this calls release
	[bubbleStack removeObject:bubbleView];

	// this calls release
  [bubbleView removeFromSuperview];  
	[(BubblesAppDelegate*)[[UIApplication sharedApplication] delegate] playSoundFile:@"pop1" ofType:@"wav"];
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
  if ([touch tapCount] == 2) {
    // double tap, anyone?
  }
	
	// pop the bubble!
	CGPoint touchPoint = [touch locationInView:self];
	for (OneBubbleView *bubbleView in bubbleStack) {
		if ([bubbleView containsPoint:touchPoint]) {
			[self popBubble:bubbleView];
			break;
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {	
  // probably don't care about this event
	//UITouch *touch = [touches anyObject];	
  //CGPoint location = [touch locationInView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {	
	//UITouch *touch = [touches anyObject];
  // Disable user interaction so subsequent touches don't interfere with animation
  //self.userInteractionEnabled = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  // not sure why/when this happens
}


- (void)drawRect:(CGRect)rect {
  // TODO: render the wand (above the bubbles)
  //[self.wandImage drawInRect:wandFrame];
}

- (void)dealloc {
	[bubbleStack release];
  [super dealloc];
}


@end
