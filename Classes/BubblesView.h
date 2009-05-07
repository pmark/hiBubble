//
//  BubblesView.h
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneBubbleView.h"
#import "BubblesViewController.h"

@interface BubblesView : UIView {
  BubblesViewController *controller;
}

-(void)launchBubble:(CGPoint)touchPoint;

@property (nonatomic, retain) BubblesViewController *controller;

@end
