//
//  BPRootViewController.m
//  CameraRoller
//
//  Created by Brian Partridge on 11/3/12.
//  Copyright (c) 2012 Brian Partridge. All rights reserved.
//

#import "BPRootViewController.h"
#import "BPPhotoLibrarian.h"

@interface BPRootViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation BPRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIButton *proxy = (UIButton *)[UIButton appearance];
    [proxy setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    self.cameraRollButton.enabled = [BPPhotoLibrarian canShowSavedPhotoPicker];
    self.lastPhotoButton.enabled =  [BPPhotoLibrarian canRetrieveLastPhoto];
}

- (IBAction)cameraRollTapped:(id)sender {
    UIImagePickerController *picker = [BPPhotoLibrarian savedPhotoPicker];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)lastPhotoTapped:(id)sender {
    [BPPhotoLibrarian retrieveLastPhoto:^(UIImage *lastPhoto, NSError *error) {
        if (lastPhoto == nil) {
            NSLog(@"error = %@", error);
        } else {
            self.displayedImageView.image = lastPhoto;
        }
        [self updateUI];
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.displayedImageView.image = image;

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
