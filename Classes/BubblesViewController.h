//
//  BubblesViewController.h
//  Bubbles
//
//  Created by Mark Anderson on 5/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BubblesViewController : UIViewController {
  NSTimer *blowTimer;
}

@property (nonatomic,retain) NSTimer *blowTimer;
@end

