//
//  BubblesViewController.h
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright Bordertown Labs 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTLFullScreenCameraController.h"
#import "BubblesView.h"

@interface BubblesViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
  NSTimer *blowTimer;
  NSTimer *styleTimer;
	CGPoint startTouchPosition;
  BTLFullScreenCameraController *camera;
  BubblesView *bubblesView;
  UIView *containerView;
  IBOutlet UIActivityIndicatorView *spinner;
	UILabel *statusLabel;
	NSInteger machineCounter;
}

@property (nonatomic,retain) NSTimer *blowTimer;
@property (nonatomic, retain) NSTimer *styleTimer;
@property (nonatomic) CGPoint startTouchPosition;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) BTLFullScreenCameraController *camera;
@property (nonatomic, retain) BubblesView *bubblesView;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UILabel *statusLabel;

-(void)setNormalizedVelocity:(CGFloat)level;
-(void)askForRating;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)shakeMotionBegan:(UIEvent *)event;
-(void)swipeRight:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeLeft:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeUp:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeDown:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)initCamera;
-(void)toggleAugmentedReality;
-(void)setRandomBackgroundColor;
-(void)clearBackgroundColor;
-(void)saveScreenshot;
-(void)initStatusMessage;
-(void)showStatusMessage:(NSString*)message;
-(void)hideStatusMessage;

@end

