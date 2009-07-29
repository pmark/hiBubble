//
//  BubblesViewController.h
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioQueueObject.h"
#import "AudioRecorder.h"

@interface BubblesViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
  NSTimer *blowTimer;
  NSTimer *monitorTimer;
	Float32 *audioLevels;
	Float32 *peakLevels;
	AudioRecorder *audioRecorder;
	CGPoint startTouchPosition;
  IBOutlet UIImageView *cameraView;
  UIImagePickerController *cameraController;
}

@property (nonatomic,retain) NSTimer *blowTimer;
@property (nonatomic, retain) NSTimer *monitorTimer;
@property (nonatomic, retain) AudioRecorder *audioRecorder;
@property (readwrite) Float32 *audioLevels;
@property (readwrite) Float32 *peakLevels;
@property (nonatomic) CGPoint startTouchPosition;
//@property (nonatomic, retain) IBOutlet UIImageView *cameraView;
@property(nonatomic, retain) UIImagePickerController *cameraController;

- (void)stopRecording;
- (void)startRecording;
- (void)analyzeSound:(NSTimer *)timer;
- (void)updateUserInterfaceOnAudioQueueStateChange: (AudioQueueObject *) inQueue;
- (void)setNormalizedVelocity:(float)level;
- (void)askForRating;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

-(void)singleTap:(NSSet*)touches;
-(void)doubleTap:(NSSet*)touches;
-(void)tripleTap:(NSSet*)touches;
-(void)shakeMotionBegan:(UIEvent *)event;
-(void)swipeRight:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeLeft:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeUp:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeDown:(NSSet *)touches withEvent:(UIEvent *)event;

@end

