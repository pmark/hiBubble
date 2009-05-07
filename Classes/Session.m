//
//  Session.m
//  Bubbles
//
//  Created by Mark Anderson on 5/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"
#import "SynthesizeSingleton.h"


@implementation Session

SYNTHESIZE_SINGLETON_FOR_CLASS(Session);

@synthesize velocity;

-(void)setNewVelocity:(NSInteger)newVelocity {
  self.velocity = newVelocity;
}

-(NSInteger)getVelocity {
  return self.velocity;
}

@end
