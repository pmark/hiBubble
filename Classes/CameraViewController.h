//
//  CameraViewController.h
//  Bubble
//
//  Created by P. Mark Anderson on 7/28/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CameraViewController : UIImagePickerController {
	NSTimer *previewTimer;

}

@property (nonatomic, retain) NSTimer *previewTimer;

-(void)inspectView: (UIView *)theView depth:(int)depth path:(NSString *)path;
-(NSString *)stringPad:(int)numPad;

@end
