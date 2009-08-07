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
}

@property (assign) NSInteger velocity;
@property (assign) BOOL crazyMode;
@property (assign) BOOL cameraMode;
@property (assign) BOOL appIsActive;
@property (assign) BOOL machineOn;

-(void)setNewVelocity:(NSInteger)newVelocity;
-(NSInteger)getVelocity;
-(bool)bubblesShouldAppear;
+(Session*)sharedSession;

@end
