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

@interface BubblesViewController : UIViewController <UIAlertViewDelegate> {
  NSTimer *blowTimer;
  NSTimer *monitorTimer;
	Float32 *audioLevels;
	Float32 *peakLevels;
	AudioRecorder *audioRecorder;
  //UIImagePickerController *imagePicker;
	CGPoint startTouchPosition;
}

@property (nonatomic,retain) NSTimer *blowTimer;
@property (nonatomic, retain) NSTimer *monitorTimer;
@property (nonatomic, retain) AudioRecorder *audioRecorder;
@property (readwrite) Float32 *audioLevels;
@property (readwrite) Float32 *peakLevels;
//@property(nonatomic, retain) UIImagePickerController *imagePicker;
@property (nonatomic) CGPoint startTouchPosition;

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
-(void)swipeRight:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)swipeLeft:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)shakeMotionBegan:(UIEvent *)event;

@end

