//
//  AudioRecorder.h
//  omphone
//
//  Created by Mark Anderson on 1/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioRecorder : AudioQueueObject {
	
	BOOL	stopping;
}

@property (readwrite) BOOL	stopping;

- (void) copyEncoderMagicCookieToFile: (AudioFileID) file fromQueue: (AudioQueueRef) queue;
- (void) setupRecording;

- (void) record;
- (void) stop;

@end
