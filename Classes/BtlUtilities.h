//
//  BtlUtilities.h
//  Bubble
//
//  Created by P. Mark Anderson on 7/20/09.
//  Copyright 2009 ProxyObjects. All rights reserved.
//



@interface BtlUtilities : NSObject {
}

+(int)randomNumber:(int)max;
+(int)randomNumberInRange:(int)min maximum:(int)max;
+(int)randomPolarity;
+(UIColor*)randomVgaColor;
+(UIColor*)randomColor;
+(CGPoint)randomPointBetween:(NSInteger)x y:(NSInteger)y;
+(CGPoint)randomPoint;

@end

#define VGA_COLORS [NSArray arrayWithObjects:[UIColor blackColor], [UIColor darkGrayColor],[UIColor lightGrayColor],[UIColor whiteColor],[UIColor grayColor],[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor cyanColor],[UIColor yellowColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor],[UIColor brownColor],	nil]