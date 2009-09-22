//
//  BTLFullScreenCameraController.m
//
//  Created by P. Mark Anderson on 8/6/2009.
//  Copyright 2009 Bordertown Labs, LLC. All rights reserved.
//

#import "BTLFullScreenCameraController.h"
#import "Session.h"
#include <QuartzCore/QuartzCore.h>

@implementation BTLFullScreenCameraController

@synthesize statusLabel, shareController;

- (id)init {
  if (self = [super init]) {
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.showsCameraControls = NO;
    self.navigationBarHidden = YES;
    self.toolbarHidden = YES;
    self.wantsFullScreenLayout = YES;
    self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, 1.13f, 1.13f);    		
		
		if ([self.parentViewController respondsToSelector:@selector(initStatusMessage)]) {
			[self.parentViewController initStatusMessage];
		} else {
			[self initStatusMessage];
		}		
  }
  return self;
}

/*
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	
}
*/

+ (BOOL)isAvailable {
  return [self isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)displayModalWithController:(UIViewController*)controller animated:(BOOL)animated {
  [controller presentModalViewController:self animated:YES];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated {
  [[self parentViewController] dismissModalViewControllerAnimated:animated];
}

- (void)takePicture {
	self.delegate = self;
	[self showStatusMessage:@"Taking photo..."];
	[Session sharedSession].appIsActive = NO;
	if (self.shareController) 
		[self.shareController hideThumbnail];
	[super takePicture];
}

- (UIImage*)dumpOverlayViewToImage {
	UIGraphicsBeginImageContext(self.cameraOverlayView.bounds.size);
	[self.cameraOverlayView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return viewImage;
}

- (UIImage*)addOverlayToBaseImage:(UIImage*)baseImage {
	UIImage *overlayImage = [self dumpOverlayViewToImage];	
	CGPoint topCorner = CGPointMake(0, 0);
	CGSize targetSize = CGSizeMake(320, 480);	
	CGRect scaledRect = CGRectZero;
	scaledRect.origin = CGPointMake(0.0,0.0);
	scaledRect.size.width  = 320;
	scaledRect.size.height = 480;
	
	UIGraphicsBeginImageContext(targetSize);	
	[baseImage drawInRect:scaledRect];
	[overlayImage drawAtPoint:topCorner];	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
	
	return result;	
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *baseImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	if (baseImage == nil) return;

	// save composite
	UIImage *compositeImage = [self addOverlayToBaseImage:baseImage];
	[Session sharedSession].appIsActive = YES;
	UIImageWriteToSavedPhotosAlbum(compositeImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

	// thumbnail
	if (self.shareController) {
		[self.shareController generateAndShowThumbnail:compositeImage];
	}
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary*)info {
	//[self writeImageToDocuments:image];
	//[self performSelector:@selector(hideStatusMessage) withObject:nil afterDelay:2.0];
	[self hideStatusMessage];
	
}

- (void)initStatusMessage {
	self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
	self.statusLabel.textAlignment = UITextAlignmentCenter;
	self.statusLabel.adjustsFontSizeToFitWidth = YES;
	self.statusLabel.backgroundColor = [UIColor clearColor];
	self.statusLabel.textColor = [UIColor whiteColor];
	self.statusLabel.shadowOffset = CGSizeMake(0, -1);  
	self.statusLabel.shadowColor = [UIColor blackColor];  
	self.statusLabel.hidden = YES;
	[self.view addSubview:self.statusLabel];	
}

- (void)showStatusMessage:(NSString*)message {
	if ([self.parentViewController respondsToSelector:@selector(showStatusMessage:)]) {
		[self.parentViewController showStatusMessage:message];
	} else {
		self.statusLabel.text = message;
		self.statusLabel.hidden = NO;
	}
}

- (void)hideStatusMessage {
	if ([self.parentViewController respondsToSelector:@selector(hideStatusMessage)]) {
		[self.parentViewController hideStatusMessage];
	} else {
		self.statusLabel.hidden = YES;
	}
}

- (void)writeImageToDocuments:(UIImage*)image {
	NSData *png = UIImagePNGRepresentation(image);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSError *error = nil;
	[png writeToFile:[documentsDirectory stringByAppendingPathComponent:@"image.png"] options:NSAtomicWrite error:&error];
}

- (BOOL)canBecomeFirstResponder { return YES; }

- (void)dealloc {
	[statusLabel release];
	[shareController release];
  [super dealloc];
}


@end
