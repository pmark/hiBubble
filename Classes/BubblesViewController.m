//
//  BubblesViewController.m
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright Bordertown Labs 2009. All rights reserved.
//

#import "BubblesAppDelegate.h"
#import "BubblesViewController.h"
#import "OneBubbleView.h"
#import "BubblesView.h"
#import "Session.h"
#import "BtlUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "SCListener.h"


// horizontal swipe
#define HORIZ_SWIPE_DRAG_MIN 240
#define VERT_SWIPE_DRAG_MAX 150

// vertical swipe
#define HORIZ_SWIPE_DRAG_MAX 200
#define VERT_SWIPE_DRAG_MIN 200

#define BUBBLE_COUNT 6
#define STYLE_DURATION 5.0
#define BUBBLE_MACHINE_SPACER 1
#define BLOW_TIMER_INTERVAL 0.16

@implementation BubblesViewController

@synthesize styleTimer;
@synthesize blowTimer;
@synthesize startTouchPosition;
@synthesize spinner;
@synthesize camera;
@synthesize containerView, bubblesView, statusLabel;


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void) loadView {
  BubblesView *tmpBubbleView = [[BubblesView alloc] init];
  self.bubblesView = tmpBubbleView;
  self.bubblesView.opaque = NO;
  self.view = self.bubblesView;
  [tmpBubbleView release];

  UIImageView *underlay = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay2.png"]] autorelease];
  underlay.alpha = 0.75f;
  self.bubblesView.underlay = underlay;
  [self.bubblesView addSubview:underlay];	
	
	[[Session sharedSession] setMinSoundLevel:0.9f];
	[[Session sharedSession] setMaxSoundLevel:1.0f];
	
	machineCounter = 0;
}

- (void) viewDidAppear:(BOOL)animated { 
	[self askForRating];
  
	[self.bubblesView becomeFirstResponder];
	self.bubblesView.shakeDelegate = self;
  
	[Session sharedSession].cameraMode = NO;
  [self.bubblesView launchBubble:1];
  [self.bubblesView launchBubble:50];
  [self.bubblesView launchBubble:80];
	[self setRandomBackgroundColor];
	
	[self initStatusMessage];
}

- (void) initCamera {  
  if ([BTLFullScreenCameraController isAvailable] && self.camera == nil) {  
    BTLFullScreenCameraController *tmpCamera = [[BTLFullScreenCameraController alloc] init];
    self.camera = tmpCamera;
    self.camera.view.backgroundColor = [UIColor blackColor];
    [self.camera setCameraOverlayView:self.bubblesView];
    [tmpCamera release];
  }
}

- (void)initTimers {
	self.blowTimer = [NSTimer scheduledTimerWithTimeInterval: BLOW_TIMER_INTERVAL
                                target:	self
                              selector:	@selector(blow:)
                              userInfo:	nil		// extra info
                               repeats:	YES];	

  [[NSRunLoop currentRunLoop] addTimer: self.blowTimer
                               forMode: NSDefaultRunLoopMode];

	self.styleTimer = [NSTimer scheduledTimerWithTimeInterval: STYLE_DURATION
                                target:	self
                              selector:	@selector(changeBubbleStyle:)
                              userInfo:	nil		// extra info
                               repeats:	YES];	

  [[NSRunLoop currentRunLoop] addTimer: self.styleTimer
                               forMode: NSDefaultRunLoopMode];

}

- (void)blow:(NSTimer *)timer {
  // set the velocity
  if ([SCListener sharedListener] != nil) {
    Float32 volume = [[SCListener sharedListener] averagePower];
    [self setNormalizedVelocity:volume];
  }  

	if ([[Session sharedSession] appIsActive]) {	
		if ([[Session sharedSession] breathDetected]) {
			[Session sharedSession].machineOn = NO;
			[self.bubblesView launchBubble:0];
			[self hideStatusMessage];
			
		} else if ([Session sharedSession].machineOn) {
			machineCounter++;
			if (machineCounter > BUBBLE_MACHINE_SPACER) {
				machineCounter = 0;
				[self.bubblesView launchBubble:[BtlUtilities randomNumberInRange:25 maximum:100]];
			}
		}
	}
}

- (void)changeBubbleStyle:(NSTimer *)timer {
	int max = [BtlUtilities randomNumberInRange:1 maximum:BUBBLE_COUNT];
	[[Session sharedSession] setBubbleCount:max];
	int bs = [BtlUtilities randomNumber:max];
	[[Session sharedSession] setBubbleStyle:bs];
	//NSLog(@"new style/count: %i/%i", max, bs);
	[BtlUtilities seedRandomNumberGenerator];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self initTimers];
	[self.bubblesView initBubbleCounter];
  //[Session sharedSession].crazyMode = YES;
	self.view.clipsToBounds = YES;
  self.view.opaque = NO;
  self.view.alpha = 1.0f;
	[self setRandomBackgroundColor];
	
	// 316 = 480 * 0.66
	[self.bubblesView setWandCenterPoint:CGPointMake(160.0f, 316.0f)];
}

-(void)askForRating {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (! [defaults objectForKey:@"firstRun"]) {
		[defaults setObject:[NSDate date] forKey:@"firstRun"];
	}

	NSInteger daysSinceInstall = [[NSDate date] timeIntervalSinceDate:[defaults objectForKey:@"firstRun"]] / 86400;
	if (daysSinceInstall > 9 && [defaults boolForKey:@"askedForRating"] == NO) {
		[[[UIAlertView alloc] initWithTitle:@"How do you like this app?" message:@"Your rating is extremely valuable!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Rate it now", nil] show];
		[defaults setBool:YES forKey:@"askedForRating"];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=316682771&mt=8"];
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)setNormalizedVelocity:(CGFloat)level {
  CGFloat max = [[Session sharedSession] maxSoundLevel];	
	if (level > max) {
		max = level;
		[[Session sharedSession] setMaxSoundLevel:max];
	}

  CGFloat min = [[Session sharedSession] minSoundLevel];
	if (level > 0.0 && level < min) {
		// gradually decrease the minimum level
		min = level * 0.05f;
		[[Session sharedSession] setMinSoundLevel:min];
	}

  CGFloat range = max - min;	
  NSInteger newVelocity = ((level - min) / range) * 100.0f;
  [[Session sharedSession] setNewVelocity:newVelocity];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  [[SCListener sharedListener] stop];
}

- (void)dealloc {
  [[SCListener sharedListener] stop];
	[self.view resignFirstResponder];
	[blowTimer release];
	[styleTimer release];
  [spinner release];
  [camera release];
  [containerView release];
  [bubblesView release];
  [super dealloc];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark 
#pragma mark Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self.bubblesView];
	self.startTouchPosition = point;
  [Session sharedSession].machineOn = NO;
	[self hideStatusMessage];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self.bubblesView];
  
  [Session sharedSession].machineOn = NO;    

  if ([touch tapCount] == 1) { 

    for (UIView *subview in [self.bubblesView.subviews reverseObjectEnumerator]) {
      if ([[[subview class] description] isEqualToString:@"OneBubbleView"]) {
        if (CGRectContainsPoint([[subview.layer presentationLayer] frame], point) == 1) {
          [self.bubblesView popBubble:(OneBubbleView*)subview];	
          return;
        }
      }
    }

    self.bubblesView.wandCenterPoint = point;  

	} else if ([touch tapCount] == 2) {
    self.bubblesView.wandCenterPoint = point;
    [Session sharedSession].machineOn = YES;    
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.bubblesView];
  
  self.bubblesView.wandCenterPoint = currentTouchPosition;
  
  [Session sharedSession].machineOn = YES;
	
	// If the swipe tracks correctly.
	if (fabsf(startTouchPosition.x - currentTouchPosition.x) >= HORIZ_SWIPE_DRAG_MIN &&
			fabsf(startTouchPosition.y - currentTouchPosition.y) <= VERT_SWIPE_DRAG_MAX)
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		if (startTouchPosition.x < currentTouchPosition.x) {
			[self swipeRight:touches withEvent:event];
		} else {
			[self swipeLeft:touches withEvent:event];
		}
		self.startTouchPosition = currentTouchPosition;
    
	} else if (fabsf(startTouchPosition.y - currentTouchPosition.y) >= VERT_SWIPE_DRAG_MIN &&
             fabsf(startTouchPosition.x - currentTouchPosition.x) <= HORIZ_SWIPE_DRAG_MAX)
  {
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		if (startTouchPosition.y < currentTouchPosition.y) {
			[self swipeDown:touches withEvent:event];
		} else {
			[self swipeUp:touches withEvent:event];
		}
		self.startTouchPosition = currentTouchPosition;  

  } else {
		// Process a non-swipe event.
	}
}

-(void)swipeRight:(NSSet*)touches withEvent:(UIEvent *)event {
	if ([Session sharedSession].cameraMode) {
		[self.camera takePicture];
	} else {
		[self saveScreenshot];
	}

}

-(void)swipeLeft:(NSSet*)touches withEvent:(UIEvent *)event {
	self.bubblesView.backgroundColor = [UIColor blackColor];
	[self toggleAugmentedReality];
}

-(void)swipeUp:(NSSet*)touches withEvent:(UIEvent *)event {
	if (![Session sharedSession].cameraMode) {
		[self setRandomBackgroundColor];
	}
}

-(void)swipeDown:(NSSet*)touches withEvent:(UIEvent *)event {
	[self clearBackgroundColor];
}




#pragma mark
#pragma mark Motion
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  switch (interfaceOrientation) {
  case UIInterfaceOrientationLandscapeLeft: 
		[self clearBackgroundColor];
    break;
  case UIInterfaceOrientationLandscapeRight: 
		if (![Session sharedSession].cameraMode) {
			[self setRandomBackgroundColor];
		}
    break;
  }
  
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)toggleAugmentedReality {
	[self hideStatusMessage];
  if ([BTLFullScreenCameraController isAvailable]) {
		[(BubblesAppDelegate*)[[UIApplication sharedApplication] delegate] playSoundFile:@"bark"];
    [Session sharedSession].cameraMode = ![Session sharedSession].cameraMode;
    if ([Session sharedSession].cameraMode == YES) {
      if (!self.camera) { [self initCamera]; }
      self.bubblesView.backgroundColor = [UIColor clearColor];
      //self.bubblesView.alpha = 0.74f;
      self.bubblesView.backgroundColor = nil;      
      self.view = self.camera.view;      
      [self.camera.view becomeFirstResponder];
    } else {
      self.view = self.bubblesView;
      //self.bubblesView.alpha = 0.95f;
			[self setRandomBackgroundColor];
      //[self.bubblesView becomeFirstResponder];
      self.camera = nil;
    }    
  }
}

-(void)shakeMotionBegan:(UIEvent *)event {
	//NSLog(@"shake!");
//	if (![Session sharedSession].appIsActive) { return; }
//	[self toggleAugmentedReality];
} 

-(void)setRandomBackgroundColor {
	self.bubblesView.backgroundColor = [BtlUtilities randomVgaColor];
}

-(void)clearBackgroundColor {
	if ([Session sharedSession].cameraMode) {
		self.bubblesView.backgroundColor = [UIColor clearColor];
	} else {
		self.bubblesView.backgroundColor = [UIColor blackColor];
	}
	
}

- (void)saveScreenshot {
	UIGraphicsBeginImageContext(self.bubblesView.bounds.size);
	[self.bubblesView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	UIImageWriteToSavedPhotosAlbum(viewImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	[self showStatusMessage:@"Taking photo..."];
	[self performSelector:@selector(hideStatusMessage) withObject:nil afterDelay:2.0];
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary*)info {
	[self hideStatusMessage];
}

- (void)initStatusMessage {
	self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, self.bubblesView.bounds.size.height)];
	self.statusLabel.textAlignment = UITextAlignmentCenter;
	self.statusLabel.adjustsFontSizeToFitWidth = YES;
	self.statusLabel.backgroundColor = [UIColor clearColor];
	self.statusLabel.textColor = [UIColor whiteColor];
	self.statusLabel.shadowOffset = CGSizeMake(0, -1);  
	self.statusLabel.shadowColor = [UIColor blackColor];  
	self.statusLabel.hidden = NO;
	self.statusLabel.numberOfLines = 0;
	self.statusLabel.text = @"Swipe right: take photo\nSwipe left: toggle camera\nTilt left or swipe up: change color\nTilt right or swipe down: reset color\nDouble tap: bubble machine on/off";
	[self.bubblesView addSubview:self.statusLabel];	
	[self performSelector:@selector(hideStatusMessage) withObject:nil afterDelay:15.0];
}

- (void)showStatusMessage:(NSString*)message {
  self.statusLabel.text = message;
	self.statusLabel.hidden = NO;
	[self.bubblesView bringSubviewToFront:self.statusLabel];	
}

- (void)hideStatusMessage {
	self.statusLabel.hidden = YES;
}


@end
