//
//  OneBubbleView.h
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OneBubbleView : UIView {
  CGFloat startWidth;
  CGFloat sizeScalar;
  NSInteger velocity;
  UIImage *image; 
  NSTimer *popTimer;
}

@property (nonatomic) CGFloat startWidth;
@property (nonatomic) CGFloat sizeScalar;
@property (assign) NSInteger velocity;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic,retain) NSTimer *popTimer;

+ (NSString*)defaultImageName;
-(void)setImageByName:(NSString*)name;
-(void)animateBirthAtPoint:(CGPoint)point;
-(void)animateFloatPhase:(OneBubbleView*)oneBubble;
- (CGPoint)computeEndPoint;
-(CGFloat)scaleDownByVelocity:(CGFloat)original percent:(NSInteger)percent;

@end
