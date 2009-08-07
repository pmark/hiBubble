//
//  BubblesViewController.h
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright Bordertown Labs 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullScreenCameraController.h"
#import "BubblesView.h"

@interface BubblesViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
  NSTimer *blowTimer;
  NSTimer *monitorTimer;
	CGPoint startTouchPosition;
  FullScreenCameraController *camera;
  BubblesView *bubblesView;
  UIView *containerView;
  IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic,retain) NSTimer *blowTimer;
@property (nonatomic, retain) NSTimer *monitorTimer;
@property (nonatomic) CGPoint startTouchPosition;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) FullScreenCameraController *camera;
@property (nonatomic, retain) BubblesView *bubblesView;
@property (nonatomic, retain) UIView *containerView;

-(void)setNormalizedVelocity:(float)level;
-(void)askForRating;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)shakeMotionBegan:(UIEvent *)event;
-(void)swipeRight:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeLeft:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeUp:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeDown:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)initCamera;
-(void)toggleAugmentedReality;

@end

