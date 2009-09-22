//
//  BtlUtilities.m
//  Bubble
//
//  Created by P. Mark Anderson on 7/20/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import "BtlUtilities.h"


@implementation BtlUtilities

+(void)seedRandomNumberGenerator {
	srandom(time(NULL));
}

+(int)randomNumberInRange:(int)min maximum:(int)max {
  int range = (max - min);
  if (range == 0) {range = 1;}
  return random() % range + min;
}

+(int)randomNumber:(int)max {
  return [self randomNumberInRange:0 maximum:max];
}

+(int)randomPolarity {
  return ([self randomNumber:2] == 0) ? 1 : -1; 
}

+(UIColor*)randomColor {
	return [UIColor colorWithRed:(rand() % 10 / 10.0f) 
												 green:(rand() % 10 / 10.0f) 
													blue:(rand() % 10 / 10.0f) 
												 alpha:0.6f];
}

+(UIColor*)randomVgaColor {
	int i = [BtlUtilities randomNumber:[VGA_COLORS count]];
	return [VGA_COLORS objectAtIndex:i];
}

+(CGPoint)randomPointBetween:(NSInteger)x y:(NSInteger)y {
  return CGPointMake(random() % x, random() % y);
}

+(CGPoint)randomPoint {
	return [BtlUtilities randomPointBetween:240 y:480];
}

+(BOOL)randomChanceOutOf:(int)max {
	return ([BtlUtilities randomNumber:max] == 0);
}


@end
