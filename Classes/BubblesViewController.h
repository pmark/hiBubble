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

@interface BubblesViewController : UIViewController {
  NSTimer *blowTimer;
  NSTimer *monitorTimer;
	Float32 *audioLevels;
	Float32 *peakLevels;
	AudioRecorder *audioRecorder;
  //UIImagePickerController *imagePicker;
}

@property (nonatomic,retain) NSTimer *blowTimer;
@property (nonatomic, retain) NSTimer *monitorTimer;
@property (nonatomic, retain) AudioRecorder *audioRecorder;
@property (readwrite) Float32 *audioLevels;
@property (readwrite) Float32 *peakLevels;
//@property(nonatomic, retain) UIImagePickerController *imagePicker;

- (void)stopRecording;
- (void)startRecording;
- (void)analyzeSound:(NSTimer *)timer;
- (void)updateUserInterfaceOnAudioQueueStateChange: (AudioQueueObject *) inQueue;
- (void)setNormalizedVelocity:(float)level;

@end

