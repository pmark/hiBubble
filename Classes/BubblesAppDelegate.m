//
//  BubblesAppDelegate.m
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright Bordertown Labs 2009. All rights reserved.
//

#import "BubblesAppDelegate.h"
#import "BubblesViewController.h"
#import "Session.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SoundEffect.h"
#import "SCListener.h"
#import "BtlUtilities.h"
//#import "RevolverSound.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation BubblesAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize sounds;


#pragma mark
#pragma mark Application
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
  // Override point for customization after app launch    
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
  [application setStatusBarHidden:YES animated:NO];
	[UIAccelerometer sharedAccelerometer].delegate = self;
	[BtlUtilities seedRandomNumberGenerator];

  [self initSounds];
  [[SCListener sharedListener] listen];

  [window addSubview:viewController.view];
  [window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// turn off the bubble maker
	[Session sharedSession].appIsActive = false;
	[[SCListener sharedListener] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[Session sharedSession].appIsActive = true;
	//[[SCListener sharedListener] listen];
}

#pragma mark
#pragma mark Sounds
/*
- (void)initSystemSounds {
  NSBundle *mainBundle = [NSBundle mainBundle];

  self.sounds = [NSDictionary dictionaryWithObjectsAndKeys:
      [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"pop1" ofType:@"aif"]], @"pop1",
      [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"bark" ofType:@"aif"]], @"bark",
      nil];
}

- (void)playSoundFile:(NSString*)soundName {
  [(SoundEffect*)[self.sounds objectForKey:soundName] play];
}
*/

/*
- (void)initSounds {
	finch = [[Finch alloc] init];
	[finch setListenToo:YES];

  NSBundle *bundle = [NSBundle mainBundle];

	NSArray *names = [NSArray arrayWithObjects:@"pop1", @"bark", nil];
	self.sounds = [NSMutableDictionary dictionaryWithCapacity:[names count]];

	for (NSString *name in names) {
		NSString *fileName = [bundle pathForResource:name ofType:@"wav"];
		RevolverSound *sound = [[RevolverSound alloc] initWithFile:fileName rounds:5];
		[self.sounds setValue:sound forKey:name];
		[sound release];
	}
}

- (void)playSoundFile:(NSString*)soundName {
  [(RevolverSound*)[self.sounds objectForKey:soundName] play];
}
*/

- (void)initSounds {
  NSBundle *bundle = [NSBundle mainBundle];

	NSArray *names = [NSArray arrayWithObjects:@"pop1", @"bark", nil];
	self.sounds = [NSMutableDictionary dictionaryWithCapacity:[names count]];

	for (NSString *name in names) {
		NSURL *url = [NSURL URLWithString:[bundle pathForResource:name ofType:@"aif"]];
		AVAudioPlayer	*sound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
		[sound prepareToPlay];
		sound.numberOfLoops = 0;
		sound.volume = 1.0;
		[self.sounds setValue:sound forKey:name];
		[sound release];
	}
}

- (void)playSoundFile:(NSString*)soundName {
	AVAudioPlayer *sound = (AVAudioPlayer*)[self.sounds objectForKey:soundName];
	if(sound.playing == YES)
		sound.currentTime = 0;
	else
    [sound play];
}

- (void)dealloc {
  [sounds release];
  [viewController release];
  [window release];
  [super dealloc];
}


@end
