//
//  OneBubbleView.h
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OneBubbleView : UIView {
  CGFloat startWidth;
  NSInteger velocity;
  UIImage *image; 
}

-(void)setImageByName:(NSString*)name;
-(void)animateBirthAtPoint:(CGPoint)point;
-(void)animateFloatPhase:(OneBubbleView*)oneBubble;

@property (nonatomic) CGFloat startWidth;
@property (nonatomic) NSInteger velocity;
@property (nonatomic,retain) UIImage *image;

@end
