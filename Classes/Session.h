//
//  Session.h
//  Bubbles
//
//  Created by Mark Anderson on 5/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface Session : NSObject {
	NSInteger velocity;
	BOOL crazyMode;
	BOOL appIsActive;
}

@property (assign) NSInteger velocity;
@property (assign) BOOL crazyMode;
@property (assign) BOOL appIsActive;

-(void)setNewVelocity:(NSInteger)newVelocity;
-(NSInteger)getVelocity;
-(bool)bubblesShouldAppear;
+(Session*)sharedSession;

@end
