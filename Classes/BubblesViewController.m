//
//  BubblesViewController.m
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BubblesViewController.h"
#import "OneBubbleView.h"

@implementation BubblesViewController

@synthesize blowTimer;

- (void)initTimers {
	self.blowTimer = [NSTimer scheduledTimerWithTimeInterval: 0.8 // seconds
                                target:	self
                              selector:	@selector(blow:)
                              userInfo:	nil		// extra info
                               repeats:	YES];	
}

- (void)blow:(NSTimer *)timer {
  NSLog(@"blowing");
  /*  
  // use entire screen to draw bubble view
  CGRect bubbleRect = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
  OneBubbleView *oneBubble = [[OneBubbleView alloc] initWithFrame:bubbleRect];
  [self.view addSubview:oneBubble];
  [oneBubble release];
  */
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

  //[self initTimers];

  self.view.backgroundColor = [UIColor blackColor];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
