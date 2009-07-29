//
//  BubblesViewController.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BubblesAppDelegate.h"
#import "BubblesViewController.h"
#import "OneBubbleView.h"
#import "BubblesView.h"
#import "Session.h"
#import "BtlUtilities.h"
#import "CameraViewController.h"
#import <QuartzCore/QuartzCore.h>

// horizontal swipe
#define HORIZ_SWIPE_DRAG_MIN 180
#define VERT_SWIPE_DRAG_MAX 100

// vertical swipe
#define HORIZ_SWIPE_DRAG_MAX 100
#define VERT_SWIPE_DRAG_MIN 250

void interruptionListenerCallback (void	*inUserData, UInt32	interruptionState) {
	// This callback, being outside the implementation block, needs a reference 
	// to the BubblesViewController object
	BubblesViewController *controller = (BubblesViewController *) inUserData;
	
	if (interruptionState == kAudioSessionBeginInterruption) {
		if (controller.audioRecorder) {
			[controller stopRecording];
		}		
	}
}



@implementation BubblesViewController

@synthesize monitorTimer;
@synthesize blowTimer;
@synthesize audioRecorder;
@synthesize audioLevels; // an array of two floating point values that represents the current recording or playback audio level
@synthesize peakLevels;
@synthesize cameraController;
@synthesize startTouchPosition;


- (void)initTimers {
	self.blowTimer = [NSTimer scheduledTimerWithTimeInterval: 0.075 // 0.08 seconds is nice
                                target:	self
                              selector:	@selector(blow:)
                              userInfo:	nil		// extra info
                               repeats:	YES];	
}

- (void)blow:(NSTimer *)timer {
  if ([[Session sharedSession] bubblesShouldAppear]) {
    NSInteger velocity = 0;
    if ([Session sharedSession].machineOn) {
      velocity = [BtlUtilities randomNumberInRange:1 maximum:100];
    }
    [(BubblesView*)self.view launchBubble:velocity];
  }
}


- (void)viewDidLoad {
  [super viewDidLoad];

  [self initTimers];
	[(BubblesView*)self.view initBubbleCounter];
  //[Session sharedSession].crazyMode = YES;
	self.view.clipsToBounds = YES;
  self.view.backgroundColor = [UIColor blackColor];
	
	// 316 = 480 * 0.66
	[(BubblesView*)self.view setWandCenterPoint:CGPointMake(160.0f, 316.0f)];

  /*
  // TODO: wait for OS 3.1
  // fire up the camera
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) { 
    self.cameraController = [[CameraViewController alloc] init];
    self.cameraController.allowsImageEditing = NO;
    self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera; 
    //self.cameraController.delegate = self;
  } else { 
    NSLog(@"Camera not available");
  } 
  NSLog(@"Starting camera...");
  [self presentModalViewController:self.cameraController animated:NO];
  */
	
  // allocate memory to hold audio level values
  audioLevels = calloc (2, sizeof (AudioQueueLevelMeterState));
  peakLevels = calloc (2, sizeof (AudioQueueLevelMeterState));
  
  // initialize the audio session object for this application,
  //		registering the callback that Audio Session Services will invoke 
  //		when there's an interruption
  AudioSessionInitialize (
                          NULL,
                          NULL,
                          interruptionListenerCallback,
                          self
                          );
  
  [self startRecording];  
}

- (void) viewDidAppear:(BOOL)animated { 
	[self.view becomeFirstResponder];
	((BubblesView*)self.view).shakeDelegate = self;
  
	[self askForRating];
  	
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

- (void)stopRecording {	
	if (self.audioRecorder) {		
		[self.audioRecorder setStopping: YES];
		[self.audioRecorder stop];
		AudioSessionSetActive (false);
	}
}

- (void)startRecording {
	if (self.audioRecorder == nil) {
		UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
		AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
		
		AudioRecorder *theRecorder = [[AudioRecorder alloc] init];
		if (theRecorder) {			
			self.audioRecorder = theRecorder;
			[theRecorder release];			
			[self.audioRecorder setNotificationDelegate: self];	
			AudioSessionSetActive (true);
			[self.audioRecorder record];
		}	
	}
}

- (void)setNormalizedVelocity:(float)level {
  // the min and max levels come directly from the mic
  float max = 0.85f;
  float min = 0.1f;
  float range = max - min;
  if (level < min) level = min;
  if (level > max) level = max;
  NSInteger newVelocity = ((level - min) / range) * 100;
  [[Session sharedSession] setNewVelocity:newVelocity];
}

- (void)analyzeSound:(NSTimer *)timer {
	AudioQueueObject *activeQueue = (AudioQueueObject *) [timer userInfo];
	
	if (activeQueue) {		
		[activeQueue getAudioLevels: self.audioLevels peakLevels: self.peakLevels];
    [self setNormalizedVelocity:audioLevels[0]];
	}  
}

- (void) updateUserInterfaceOnAudioQueueStateChange: (AudioQueueObject *) inQueue {
	NSAutoreleasePool *uiUpdatePool = [[NSAutoreleasePool alloc] init];
	if ([inQueue isRunning]) {
		self.monitorTimer = [NSTimer scheduledTimerWithTimeInterval:	0.12
                                                         target:	self
                                                       selector:	@selector (analyzeSound:)
                                                       userInfo:	inQueue
                                                        repeats:	YES];
		
		if (inQueue == self.audioRecorder) {			
		}		
	} else {
		// playback just stopped
		if (inQueue == self.audioRecorder) {
			[audioRecorder release];
			audioRecorder = nil;
		}				
		
		if (self.monitorTimer) {			
			[self.monitorTimer invalidate];
			[self.monitorTimer release];
			monitorTimer = nil;
		}		
	}
  	
	[uiUpdatePool drain];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  
	if (self.audioRecorder) {
		//[self stopRecording];
	}
}

- (void)dealloc {
	[self.view resignFirstResponder];
	[blowTimer dealloc];
	[monitorTimer dealloc];
  [audioRecorder dealloc];
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
	CGPoint point = [touch locationInView:self.view];
	self.startTouchPosition = point;
  [Session sharedSession].machineOn = NO;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self.view];
  
  [Session sharedSession].machineOn = NO;    

  if ([touch tapCount] == 1) { 

    for (OneBubbleView *bubble in [self.view.subviews reverseObjectEnumerator]) {
      if (CGRectContainsPoint([[bubble.layer presentationLayer] frame], point) == 1) {
        [(BubblesView*)self.view popBubble:bubble];	
        return;
      }
    }

    ((BubblesView*)self.view).wandCenterPoint = point;  

	} else if ([touch tapCount] == 2) {
    ((BubblesView*)self.view).wandCenterPoint = point;
    [Session sharedSession].machineOn = YES;    
  }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.view];
  
  ((BubblesView*)self.view).wandCenterPoint = currentTouchPosition;
  
  //[(BubblesView*)self.view launchBubble:[BtlUtilities randomNumberInRange:1 maximum:100]];
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


/*******
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
	UITouch *touch = [touches anyObject]; 
	CGPoint point = [touch locationInView:nil];
	self.startTouchPosition = point;
	
	NSLog(@"Begin Point: %f, %f", point.x, point.y);

	if (touch.tapCount == 2) { 
		[[self class] cancelPreviousPerformRequestsWithTarget:self];
	} else if (touch.tapCount == 3) { 
		[[self class] cancelPreviousPerformRequestsWithTarget:self];
	} 
} 

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { 
	UITouch *touch = [touches anyObject]; 
	CGPoint point = [touch locationInView:nil];
	NSLog(@"End Point: %f, %f", point.x, point.y);

	if (touch.tapCount == 1) { 
		[self performSelector:@selector(singleTap:) withObject:touches afterDelay:0.15f]; 
		
	} else if (touch.tapCount == 2) { 
		[self performSelector:@selector(doubleTap:) withObject:touches afterDelay:0.15f]; 
	} else if (touch.tapCount == 3) { 
		[self tripleTap:touches];
	} 
}
************/

/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	startTouchPosition = [touch locationInView:self.view];
	
	switch (tapCount) {
		case 1:
			[self performSelector:@selector(singleTap:) withObject:touches afterDelay:.4];
			break;
		case 2:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap:) object:touches];
			[self performSelector:@selector(doubleTap:) withObject:touches afterDelay:.4];
			break;
		case 3:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doubleTap:) object:touches];
			[self performSelector:@selector(tripleTap:) withObject:touches afterDelay:.4];
			break;
		case 4:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tripleTap:) object:touches];
			[self quadrupleTap:touches];
			break;
		default:
			break;
	}
}
*/

-(void)singleTap:(NSSet*)touches {
}

-(void)doubleTap:(NSSet*)touches {
}

-(void)tripleTap:(NSSet*)touches {
}

-(void)swipeRight:(NSSet*)touches withEvent:(UIEvent *)event {
	self.view.backgroundColor = [BtlUtilities randomVgaColor];
}

-(void)swipeLeft:(NSSet*)touches withEvent:(UIEvent *)event {
	self.view.backgroundColor = [UIColor blackColor];
}

-(void)swipeUp:(NSSet*)touches withEvent:(UIEvent *)event {
	self.view.backgroundColor = [BtlUtilities randomVgaColor];
}

-(void)swipeDown:(NSSet*)touches withEvent:(UIEvent *)event {
	self.view.backgroundColor = [BtlUtilities randomVgaColor];
}




#pragma mark
#pragma mark Motion
-(void)shakeMotionBegan:(UIEvent *)event {
	if (![Session sharedSession].appIsActive) { return; }

	[Session sharedSession].crazyMode = ![Session sharedSession].crazyMode;
	[(BubblesAppDelegate*)[[UIApplication sharedApplication] delegate] playSoundFile:@"bark" ofType:@"aif"];
	if ([Session sharedSession].crazyMode) {
		self.view.backgroundColor = [BtlUtilities randomVgaColor];
		[(BubblesView*)self.view popAllBubbles];
		[(BubblesView*)self.view launchBubble:100];

	} else {
		self.view.backgroundColor = [UIColor blackColor];
	}
} 


@end
