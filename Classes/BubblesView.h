//
//  BubblesView.h
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneBubbleView.h"

@interface BubblesView : UIView {
  UIImage *wandImage; 
	NSInteger bubbleCounter;
	CGPoint wandCenterPoint;
	id shakeDelegate;
}

@property (nonatomic,retain) UIImage *wandImage;
@property (nonatomic,assign) NSInteger bubbleCounter;
@property (nonatomic,assign) CGPoint wandCenterPoint;
@property (nonatomic, retain) id shakeDelegate; 

-(void)launchBubble:(NSInteger)velocity;
-(void)initBubbleCounter;
-(void)popBubble:(OneBubbleView*)bubbleView;
-(void)releaseBubble:(OneBubbleView*)bubbleView withSound:(NSString*)soundName;
-(NSInteger)nextBubbleTag;
-(void)popAllBubbles;

@end
