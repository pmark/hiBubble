//
//  BubblesAppDelegate.h
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BubblesViewController;

@interface BubblesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BubblesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BubblesViewController *viewController;

@end

