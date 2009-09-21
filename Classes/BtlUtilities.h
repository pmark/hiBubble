//
//  BtlUtilities.h
//  Bubble
//
//  Created by P. Mark Anderson on 7/20/09.
//  Copyright 2009 ProxyObjects. All rights reserved.
//



@interface BtlUtilities : NSObject {
}

+(void)seedRandomNumberGenerator;
+(int)randomNumber:(int)max;
+(int)randomNumberInRange:(int)min maximum:(int)max;
+(int)randomPolarity;
+(UIColor*)randomVgaColor;
+(UIColor*)randomColor;
+(CGPoint)randomPointBetween:(NSInteger)x y:(NSInteger)y;
+(CGPoint)randomPoint;
+(BOOL)randomChanceOutOf:(int)max;

@end

#define VGA_COLORS [NSArray arrayWithObjects:[UIColor darkGrayColor],[UIColor whiteColor],[UIColor redColor],[UIColor blueColor],[UIColor cyanColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor],nil]