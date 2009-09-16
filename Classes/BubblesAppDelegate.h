//
//  BubblesAppDelegate.h
//  Bubbles
//
//  Created by P. Mark Anderson on 5/4/09.
//  Copyright Bordertown Labs 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Finch.h"

@class BubblesViewController;

@interface BubblesAppDelegate : NSObject <UIApplicationDelegate, UIAccelerometerDelegate> {
  UIWindow *window;
  BubblesViewController *viewController;
  NSDictionary *sounds;
	Finch *finch;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BubblesViewController *viewController;
@property (nonatomic, retain) NSDictionary *sounds;

- (void)initSounds;
//- (void)initSystemSounds;
- (void)playSoundFile:(NSString*)soundName;

@end

