//
//  BubblesView.h
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneBubbleView.h"

@interface BubblesView : UIView {
  UIImage *wandImage; 
  UIImageView *underlay;
	NSInteger bubbleCounter;
	CGPoint wandCenterPoint;
	id shakeDelegate;
}

@property (nonatomic,retain) UIImage *wandImage;
@property (nonatomic, retain) UIImageView *underlay; 
@property (nonatomic,assign) NSInteger bubbleCounter;
@property (nonatomic,assign) CGPoint wandCenterPoint;
@property (nonatomic, retain) id shakeDelegate; 

-(void)launchBubble:(NSInteger)velocity;
-(void)initBubbleCounter;
-(void)popBubble:(OneBubbleView*)bubbleView;
-(void)releaseBubble:(OneBubbleView*)bubbleView withSound:(NSString*)soundName;
-(void)releaseBubbleSilently:(OneBubbleView*)bubbleView;
-(NSInteger)nextBubbleTag;
-(void)popAllBubbles;

@end
