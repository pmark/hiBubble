//
//  BTLImageShareController.m
//  Bubble
//
//  Created by P. Mark Anderson on 9/22/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import "BTLImageShareController.h"


@implementation BTLImageShareController

@synthesize image;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
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
		
	thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	thumbnailButton.frame = CGRectMake(260.0, 395.0, 50.0, 75.0);
	thumbnailButton.backgroundColor = [UIColor blackColor];
	thumbnailButton.imageEdgeInsets = UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f);
	[thumbnailButton addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
	thumbnailButton.hidden = YES;
	[self.view addSubview:thumbnailButton];
	
}

- (void)thumbnailTapped:(id)sender {
	NSLog(@"thumbnail tapped");
}

- (void)showThumbnail:(UIImage *)newImage {
	if (newImage != nil && newImage != self.image) {
		self.image = newImage;
	}

	[thumbnailButton setImage:self.image forState:UIControlStateNormal];
	thumbnailButton.hidden = NO;	
}

- (void)hideThumbnail {
	thumbnailButton.hidden = YES;
}

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
	[thumbnailButton release];
	[image release];
	[super dealloc];
}


@end
