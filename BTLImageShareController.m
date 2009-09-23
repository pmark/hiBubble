//
//  BTLImageShareController.m
//  Bubble
//
//  Created by P. Mark Anderson on 9/22/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import "BTLImageShareController.h"
#import <QuartzCore/QuartzCore.h>

#define THUMBNAIL_FRAME_WIDTH 100
#define THUMBNAIL_FRAME_HEIGHT 133
#define THUMBNAIL_FRAME_OFFSET_X 25
#define THUMBNAIL_FRAME_OFFSET_Y 25
#define THUMBNAIL_WIDTH 50
#define THUMBNAIL_HEIGHT 75

@implementation BTLImageShareController

@synthesize image, delegate;

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
	thumbnailButton.frame = CGRectMake(self.view.frame.size.width - THUMBNAIL_FRAME_WIDTH - 10, 
																		 self.view.frame.size.height - THUMBNAIL_FRAME_HEIGHT - 10, 
																		 THUMBNAIL_FRAME_WIDTH, THUMBNAIL_FRAME_HEIGHT);
	[thumbnailButton addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
	thumbnailButton.hidden = YES;
	[self.view addSubview:thumbnailButton];

	imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	imageButton.frame = CGRectMake(0, 0, 320, 480);
	[imageButton addTarget:self action:@selector(imageTapped:) forControlEvents:UIControlEventTouchUpInside];
	imageButton.hidden = NO;
	imageButton.alpha = 0.0f;
	[self.view addSubview:imageButton];
	
	thumbnailFrame = [UIImage imageNamed:@"thumbnail_frame.png"];
}

- (void)thumbnailTapped:(id)sender {
	if ([self.delegate respondsToSelector:@selector(thumbnailTapped)]) {
		[self.delegate thumbnailTapped];
	}
	
	[self hideThumbnail];

	// fade in full screen image
	[imageButton setImage:self.image forState:UIControlStateNormal];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDuration:0.66f];
  imageButton.alpha = 1.0f;	
  [UIView commitAnimations];	
}

- (void)imageTapped:(id)sender {
	NSLog(@"image tapped!");
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
																													 delegate: self 
																									cancelButtonTitle: @"Cancel" 
																						 destructiveButtonTitle: NULL 
																									otherButtonTitles: @"Email Photo", @"Go Back", NULL];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;																							
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			NSLog(@"email photo");
			break;
		case 1:
			[self hidePreviewImage];
			if ([self.delegate respondsToSelector:@selector(previewClosed)]) {
				[self.delegate previewClosed];
			}
			break;
		default:
			break;
	}
}

- (void)hidePreviewImage {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDuration:0.66f];
  imageButton.alpha = 0.0f;	
  [UIView commitAnimations];	
}

- (UIImage*)generateThumbnail:(UIImage*)source {
	CGRect scaledRect = CGRectZero;
	scaledRect.size.width  = THUMBNAIL_WIDTH;
	scaledRect.size.height = THUMBNAIL_HEIGHT;
	scaledRect.origin = CGPointMake(THUMBNAIL_FRAME_OFFSET_X, THUMBNAIL_FRAME_OFFSET_Y);
	CGSize targetSize = CGSizeMake(THUMBNAIL_FRAME_WIDTH, THUMBNAIL_FRAME_HEIGHT);	
	
	UIGraphicsBeginImageContext(targetSize);
	[source drawInRect:scaledRect];
	[thumbnailFrame drawAtPoint:CGPointMake(0, 0)];
	
	// draw a simple thumbnail border
//	CGContextRef context = UIGraphicsGetCurrentContext();
//  CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.07f); 
//  CGContextStrokeRectWithWidth(context, scaledRect, 5.0f);	
	
	UIImage* thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
	return thumbnailImage;
}

- (void)showThumbnail:(UIImage *)newImage {
	[thumbnailButton setImage:newImage forState:UIControlStateNormal];
	thumbnailButton.alpha = 0.0f;
	thumbnailButton.hidden = NO;	

  CGAffineTransform preTransform = CGAffineTransformMakeScale(0.1f, 0.1f);
  thumbnailButton.transform = preTransform;

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

  [UIView setAnimationDuration:0.3f];
  thumbnailButton.alpha = 1.0f;
	
	CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.0f);
  thumbnailButton.transform = transform;
	
  [UIView commitAnimations];	
}

- (void)generateAndShowThumbnail:(UIImage*)newImage {
	if (newImage != nil && newImage != self.image) {
		self.image = newImage;
	}

	[self showThumbnail:[self generateThumbnail:self.image]];
}

- (void)hideThumbnail {
	if (thumbnailButton.hidden) return;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

  [UIView setAnimationDuration:0.3f];
  thumbnailButton.alpha = 0.0f;
	
	CGAffineTransform transform = CGAffineTransformMakeScale(0.01f, 0.01f);
  thumbnailButton.transform = transform;
	
  [UIView commitAnimations];	
}

- (void)hideThumbnailAfterDelay:(CGFloat)delay {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(hideThumbnail) withObject:self afterDelay:delay];
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
	[image release];
	[imageButton release];
	[thumbnailButton release];
	[thumbnailFrame release];
	[delegate release];
	[super dealloc];
}


@end
