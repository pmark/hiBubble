//
//  BubblesAppDelegate.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BubblesAppDelegate.h"
#import "BubblesViewController.h"

@implementation BubblesAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
