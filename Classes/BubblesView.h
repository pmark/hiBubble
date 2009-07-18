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
	NSMutableArray *bubbleStack;
	NSInteger bubbleCounter;
}

@property (nonatomic,retain) UIImage *wandImage;
@property (nonatomic,retain) NSMutableArray *bubbleStack;
@property (nonatomic,assign) NSInteger bubbleCounter;

-(void)launchBubble;
-(void)initBubbleStack;
-(void)popBubble:(OneBubbleView*)bubbleView;
-(void)releaseBubble:(OneBubbleView*)bubbleView;
-(NSInteger)nextBubbleTag;
@end
