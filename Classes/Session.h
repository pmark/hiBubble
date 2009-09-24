//
//  Session.h
//  Bubbles
//
//  Created by P. Mark Anderson on 5/7/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//


@interface Session : NSObject {
	NSInteger velocity;
	BOOL crazyMode;
  BOOL cameraMode;
	BOOL appIsActive;
  BOOL machineOn;
	CGFloat minSoundLevel;
	CGFloat maxSoundLevel;
	NSInteger bubbleCount;
	NSInteger bubbleStyle;
	UIInterfaceOrientation uiOrientation;
}

@property (assign) NSInteger velocity;
@property (assign) NSInteger bubbleCount;
@property (assign) NSInteger bubbleStyle;
@property (assign) BOOL crazyMode;
@property (assign) BOOL cameraMode;
@property (assign) BOOL appIsActive;
@property (assign) BOOL machineOn;
@property (assign) CGFloat minSoundLevel;
@property (assign) CGFloat maxSoundLevel;
@property (assign) UIInterfaceOrientation uiOrientation;

-(void)setNewVelocity:(NSInteger)newVelocity;
-(NSInteger)getVelocity;
-(bool)breathDetected;
-(bool)bubblesShouldAppear;
+(Session*)sharedSession;

@end
