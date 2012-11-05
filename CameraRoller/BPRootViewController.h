//
//  BPRootViewController.h
//  CameraRoller
//
//  Created by Brian Partridge on 11/3/12.
//  Copyright (c) 2012 Brian Partridge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BPRootViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIButton *lastPhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *displayedImageView;

- (IBAction)cameraRollTapped:(id)sender;
- (IBAction)lastPhotoTapped:(id)sender;

@end
