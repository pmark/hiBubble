//
//  CameraViewController.m
//  Bubble
//
//  Created by P. Mark Anderson on 7/28/09.
//  Copyright 2009 ProxyObjects. All rights reserved.
//

#import "CameraViewController.h"

#define kPreviewTimerInterval 0.2	// once every five seconds

@implementation CameraViewController

@synthesize previewTimer;

-(void)setPreviewTimer:(NSTimer *)timer {
	if (previewTimer != timer) {
		[previewTimer invalidate];
		[previewTimer release];
		previewTimer = [timer retain];
	}
}

-(void) dealloc {
	[previewTimer release];
	[super dealloc];
}

// in the default camera interface the preview is presented at a slightly different 
// scale than the camera view- this method applies a transformation to the view containg
// the preview image to match the size to the camera view
//
// NOTE: tested only for portrait images
//
-(void)previewCheck {
	
	// for debug: print view hierarchy
	//[self inspectView:self.view depth:0 path:@""];
	
#if !TARGET_IPHONE_SIMULATOR
  /*
  // grab the current image
  CGImageRef img = UIGetScreenImage();
  UIImage *grabbedImage = [UIImage imageWithCGImage:img];
  // you can now manipulate the grabbedImage;
  CFRelease(img);
  */

/*
	UIView *preview = [[[[[[[[self.view subviews] objectAtIndex:0]
							subviews] objectAtIndex: 0]
						  subviews] objectAtIndex: 0]
						subviews] objectAtIndex: 2];
	
	// preview view path is /0/0/0/2, by default without a subview
	// if it has a subview, preview image is showing, so fix transform
	//
	if ([preview.subviews count] != 0) {
		UIView *previewImage = [[[[[[preview subviews] objectAtIndex:0]
											subviews] objectAtIndex: 0]
									subviews] objectAtIndex: 0];
		[previewImage setTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(320.0/1200, 320.0/1200),
															  -12.0*1200/320,-17.0*1200/320)];
		
	}
*/
#endif
	
}

- (void)viewDidDisappear:(BOOL)animated {
	// stop the preview timer
	//
	self.previewTimer = nil;
	
	// make sure to call the same method on the super class!!!
	//
	[super viewDidDisappear:animated];
}

-(void) viewDidAppear: (BOOL)animated {

	// make sure to call the same method on the super class!!!
	//
	[super viewDidAppear:animated];
	
	// this timer will fire previewCheck
	//
	self.previewTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/kPreviewTimerInterval 
														 target:self selector:@selector(previewCheck) userInfo:nil repeats:YES];

#if !TARGET_IPHONE_SIMULATOR
  [super viewDidAppear:animated];
  [self inspectView:self.view depth:0 path:@""];
  
  UIView *plCameraView = [[[[[[self.view subviews] objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:0];
  // [[[plCameraView subviews] objectAtIndex:3] removeFromSuperview];
  [[[plCameraView subviews] objectAtIndex:3] setHidden:YES];
	
	// let's make the camera view half transparent
	// the camera view is at path /0/0/0/0/0
	//
//	UIView *cameraView = [[[[[[[[self.view subviews] objectAtIndex:0]
//										   subviews] objectAtIndex:0]
//										   subviews] objectAtIndex:0]
//							               subviews] objectAtIndex:0];
//	[cameraView setAlpha:0.5];
	
#endif
	
}

-(NSString *)stringPad:(int)numPad {
	NSMutableString *pad = [NSMutableString stringWithCapacity:1024];
	for (int i=0; i<numPad; i++) {
		[pad appendString:@"  "];
	}
	return pad; 
}


-(void)inspectView: (UIView *)theView depth:(int)depth path:(NSString *)path {
	
	if (depth==0) {
		NSLog(@"-------------------- <view hierarchy> -------------------");
	}
	
	NSString *pad = [self stringPad:depth];
	
	// print some information about the current view
	//
	NSLog([NSString stringWithFormat:@"%@.description: %@",pad,[theView description]]);
	if ([theView isKindOfClass:[UIImageView class]]) {
		NSLog([NSString stringWithFormat:@"%@.class: UIImageView",pad]);
	} else if ([theView isKindOfClass:[UILabel class]]) {
		NSLog([NSString stringWithFormat:@"%@.class: UILabel",pad]);
		NSLog([NSString stringWithFormat:@"%@.text: ",pad,[(UILabel *)theView text]]);		
	} else if ([theView isKindOfClass:[UIButton class]]) {
		NSLog([NSString stringWithFormat:@"%@.class: UIButton",pad]);
		NSLog([NSString stringWithFormat:@"%@.title: ",pad,[(UIButton *)theView titleForState:UIControlStateNormal]]);		
	}
	NSLog([NSString stringWithFormat:@"%@.frame: %.0f, %.0f, %.0f, %.0f", pad, theView.frame.origin.x, theView.frame.origin.y,
		   theView.frame.size.width, theView.frame.size.height]);
	NSLog([NSString stringWithFormat:@"%@.subviews: %d",pad, [theView.subviews count]]);
	NSLog(@" ");
	
	// gotta love recursion: call this method for all subviews
	//
	for (int i=0; i<[theView.subviews count]; i++) {
		NSString *subPath = [NSString stringWithFormat:@"%@/%d",path,i];
		NSLog([NSString stringWithFormat:@"%@--subview-- %@",pad,subPath]);		
		[self inspectView:[theView.subviews objectAtIndex:i]  depth:depth+1 path:subPath];
	}
	
	if (depth==0) {
		NSLog(@"-------------------- </view hierarchy> -------------------");
	}
	
}


@end
