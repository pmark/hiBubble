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
#import "SCListener.h"
#import "BtlUtilities.h"

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
  [self initSounds];
	[BtlUtilities seedRandomNumberGenerator];

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
	[[SCListener sharedListener] listen];
}

- (void)dealloc {
  [sounds release];
  [viewController release];
  [window release];
  [super dealloc];
}

#pragma mark
#pragma mark Sounds
- (void)initSounds {
  NSBundle *mainBundle = [NSBundle mainBundle];

  self.sounds = [NSDictionary dictionaryWithObjectsAndKeys:
      [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"pop1" ofType:@"aif"]], @"pop1",
      [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"bark" ofType:@"aif"]], @"bark",
      nil];
  [[SCListener sharedListener] listen];
}

- (void)playSoundFile:(NSString*)soundName {
  [[SCListener sharedListener] pause];
  [(SoundEffect*)[self.sounds objectForKey:soundName] play];
  //[[SCListener sharedListener] listen];
}


@end
