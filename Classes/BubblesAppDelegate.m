//
//  BubblesAppDelegate.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BubblesAppDelegate.h"
#import "BubblesViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation BubblesAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
  // Override point for customization after app launch    
  //[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
  [application setStatusBarHidden:YES animated:YES];

  [window addSubview:viewController.view];
  [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

void SystemSoundsDemoCompletionProc (
		 SystemSoundID  soundID,
		 void           *clientData)
{
	AudioServicesDisposeSystemSoundID(soundID);
	// ((BubblesAppDelegate*)clientData).something
};

- (void)playSoundFile:(NSString*)fileName ofType:(NSString*)fileType {
	SystemSoundID soundID;
	OSStatus err = kAudioServicesNoError;

	// find corresponding audio file
	NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType]; 
	NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath]; 
	err = AudioServicesCreateSystemSoundID((CFURLRef) audioFileURL, &soundID); 
	
	if (err == kAudioServicesNoError) {
		// set up callback for sound completion
		err = AudioServicesAddSystemSoundCompletion 
		(soundID,		// sound to monitor
		 NULL,			// run loop (NULL==main)
		 NULL,			// run loop mode (NULL==default)
		 SystemSoundsDemoCompletionProc, // callback function 
		 self			  // data to provide on callback
		 ); 
		
		AudioServicesPlaySystemSound(soundID); 
	}
	
	if (err != kAudioServicesNoError) { 
		CFErrorRef error = CFErrorCreate(NULL, kCFErrorDomainOSStatus, err, NULL); 
		NSString *errorDesc = (NSString*) CFErrorCopyDescription (error); 
		UIAlertView *cantPlayAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Play:"
																														message: errorDesc
																													 delegate:nil
																									cancelButtonTitle:@"OK"
																									otherButtonTitles:nil];
		[cantPlayAlert show];
		[cantPlayAlert release]; 
		[errorDesc release]; 
		CFRelease (error); 
	}
}


@end
