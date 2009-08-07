//
//  FullScreenCameraController.m
//  ViewThing1
//
//  Created by P. Mark Anderson on 8/6/2009.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import "FullScreenCameraController.h"


@implementation FullScreenCameraController

- (id)init {
  if (self = [super init]) {
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.showsCameraControls = NO;
    self.navigationBarHidden = YES;
    self.toolbarHidden = YES;
    self.wantsFullScreenLayout = YES;
    self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, 1.0, 1.13f);    
  }
  return self;
}

/*
- (void)viewDidLoad {
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

// Also see UIImagePickerController's presentModalViewController:animated
- (void)displayWithController:(UIViewController*)controller {
  [controller.view addSubview:self.view];
}

// Also see UIImagePickerController's dismissModalViewControllerAnimated
- (void)dismiss {
  [self.view removeFromSuperview];
}

@end
