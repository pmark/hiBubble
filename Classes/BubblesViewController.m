//
//  BubblesViewController.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BubblesViewController.h"
#import "OneBubbleView.h"
#import "BubblesView.h"
#import "Session.h"

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
//@synthesize imagePicker;


- (void)initTimers {
	self.blowTimer = [NSTimer scheduledTimerWithTimeInterval: 0.08 // 0.08 seconds is nice
                                target:	self
                              selector:	@selector(blow:)
                              userInfo:	nil		// extra info
                               repeats:	YES];	
}

- (void)blow:(NSTimer *)timer {
  if ([(Session*)[Session sharedSession] bubblesShouldAppear]) {
    [(BubblesView*)self.view launchBubble];
  }
}


// The designated initializer. Override to perform setup that is required before the view is loaded.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

  [self initTimers];
	[(BubblesView*)self.view initBubbleCounter];

  self.view.backgroundColor = [UIColor blackColor];

  /*
  //
  // TODO: display what the camera sees in the background
  //
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) { 
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera; 
  } else { 
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
  } 
  self.imagePicker.allowsImageEditing = YES; 
  [self presentModalViewController:self.imagePicker animated:YES];
  */
	
	[self askForRating];
  
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

-(void)askForRating {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (! [defaults objectForKey:@"firstRun"]) {
		[defaults setObject:[NSDate date] forKey:@"firstRun"];
	}

	NSInteger daysSinceInstall = [[NSDate date] timeIntervalSinceDate:[defaults objectForKey:@"firstRun"]] / 86400;
	if (daysSinceInstall > 10 && [defaults boolForKey:@"askedForRating"] == NO) {
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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)stopRecording {
	
	if (self.audioRecorder) {
		
		[self.audioRecorder setStopping: YES];				// this flag lets the property listener callback
		//	know that the user has tapped Stop
		[self.audioRecorder stop];							// stops the recording audio queue object. the object 
		//	remains in existence until it actually stops, at
		//	which point the property listener callback calls
		//	this class's updateUserInterfaceOnAudioQueueStateChange:
		//	method, which releases the recording object.
		// now that recording has stopped, deactivate the audio session
		AudioSessionSetActive (false);
	}
}

- (void)startRecording {
	
	// if not recording, start recording
	if (self.audioRecorder == nil) {
		
		// before instantiating the recording audio queue object, 
		//	set the audio session category
		UInt32 sessionCategory = kAudioSessionCategory_RecordAudio;
		AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
		
		// the first step in recording is to instantiate a recording audio queue object
		AudioRecorder *theRecorder = [[AudioRecorder alloc] init];
		
		// if the audio queue was successfully created, initiate recording.
		if (theRecorder) {
			
			self.audioRecorder = theRecorder;
			[theRecorder release];								// decrements the retain count for the theRecorder object
			
      // set up the recorder object to receive property change notifications 
			// from the recording audio queue object
			[self.audioRecorder setNotificationDelegate: self];	
			
			// activate the audio session immediately before recording starts
			AudioSessionSetActive (true);
			[self.audioRecorder record];	// starts the recording audio queue object
		}	
	}
}

- (void)setNormalizedVelocity:(float)level {
  // the min and max levels come directly from the mic
  float max = 0.8f;
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

// this method gets called (by property listener callback functions) when a recording or playback 
// audio queue object starts or stops. 
- (void) updateUserInterfaceOnAudioQueueStateChange: (AudioQueueObject *) inQueue {
	
	NSAutoreleasePool *uiUpdatePool = [[NSAutoreleasePool alloc] init];
	
	// the audio queue (playback or record) just started
	if ([inQueue isRunning]) {
    
		// create a timer for updating the audio level meter
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
	[blowTimer dealloc];
	[monitorTimer dealloc];
  [audioRecorder dealloc];
  [super dealloc];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



@end
