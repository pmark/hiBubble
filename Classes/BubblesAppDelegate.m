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

@implementation BubblesAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize sounds;


#pragma mark
#pragma mark Application
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
  // Override point for customization after app launch    
  [application setStatusBarHidden:YES animated:YES];
	[UIAccelerometer sharedAccelerometer].delegate = self;
  [self initSounds];

  [window addSubview:viewController.view];
  [window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// turn off the bubble maker
	[Session sharedSession].appIsActive = false;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[Session sharedSession].appIsActive = true;
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
}

- (void)playSoundFile:(NSString*)soundName {
  [(SoundEffect*)[self.sounds objectForKey:soundName] play];
}


@end
