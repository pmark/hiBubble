//
//  BTLImageShareController.h
//  Bubble
//
//  Created by P. Mark Anderson on 9/22/09.
//  Copyright 2009 Bordertown Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BTLImageShareController : UIViewController {
	UIImage *image;
	UIButton *thumbnailButton;
}

@property (nonatomic,retain) UIImage *image;

- (void)hideThumbnail;
- (void)hideThumbnailAfterDelay:(CGFloat)delay;
- (void)showThumbnail:(UIImage *)newImage;
- (UIImage*)generateThumbnail:(UIImage*)source;
- (void)generateAndShowThumbnail:(UIImage*)source;

@end
