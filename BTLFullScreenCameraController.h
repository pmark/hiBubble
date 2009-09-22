//
//  BTLFullScreenCameraController.h
//
//  Created by P. Mark Anderson on 8/6/2009.
//  Copyright 2009 Bordertown Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTLImageShareController.h"


@interface BTLFullScreenCameraController : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	UILabel *statusLabel;
	BTLImageShareController *shareController;
}

@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) BTLImageShareController *shareController;

+ (BOOL)isAvailable;
- (void)displayModalWithController:(UIViewController*)controller animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;
- (void)takePicture;
- (void)writeImageToDocuments:(UIImage*)image;
- (void)initStatusMessage;
- (void)showStatusMessage:(NSString*)message;
- (void)hideStatusMessage;
- (UIImage*)generateThumbnail:(UIImage*)source;

@end
