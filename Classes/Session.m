//
//  Session.m
//  Bubbles
//
//  Created by P. Mark Anderson on 5/7/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"
#import "SynthesizeSingleton.h"


@implementation Session

SYNTHESIZE_SINGLETON_FOR_CLASS(Session);

@synthesize velocity, crazyMode, cameraMode, appIsActive, machineOn, minSoundLevel, maxSoundLevel;
@synthesize bubbleCount, bubbleStyle;

-(void)setNewVelocity:(NSInteger)newVelocity {
  self.velocity = newVelocity;
}

-(NSInteger)getVelocity {
  return self.velocity;
}

-(bool)breathDetected {
  return self.velocity > 28;
}

-(bool)bubblesShouldAppear {
  return self.appIsActive && ([self breathDetected] || self.machineOn);
}

@end
