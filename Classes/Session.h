//
//  Session.h
//  Bubbles
//
//  Created by Mark Anderson on 5/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface Session : NSObject {
	NSInteger velocity;
}

@property (assign) NSInteger velocity;

-(void)setNewVelocity:(NSInteger)newVelocity;
-(NSInteger)getVelocity;

@end
