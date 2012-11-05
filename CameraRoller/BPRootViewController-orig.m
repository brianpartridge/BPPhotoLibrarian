//
//  BPRootViewController.m
//  CameraRoller
//
//  Created by Brian Partridge on 11/3/12.
//  Copyright (c) 2012 Brian Partridge. All rights reserved.
//

#import "BPRootViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSDictionary+Safe.h"

@interface BPRootViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImagePickerControllerSourceType _sourceType;
}

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

    _sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
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
    self.cameraRollButton.enabled = [self canShowImagePicker];
    self.lastPhotoButton.enabled =  [self canAccessAssetLibrary];
}

- (IBAction)cameraRollTapped:(id)sender {
    NSLog(@"cr tapped");
    if (![self canShowImagePicker]) {
        NSLog(@"unable to show picker");
    } else {
        UIImagePickerController *picker = [self imagePicker];
        picker.delegate = self;

        [self presentViewController:picker animated:YES completion:^{
            NSLog(@"presented");
        }];
    }
}

- (IBAction)lastPhotoTapped:(id)sender {
    NSLog(@"lp tapped");

    if (![self canAccessAssetLibrary]) {
        NSLog(@"unable to access library");
    } else {
        [self setLastPhotoTaken];
    }
}

- (BOOL)canAccessAssetLibrary {
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    return (authStatus == ALAuthorizationStatusNotDetermined ||
            authStatus == ALAuthorizationStatusAuthorized);
}

- (void)setLastPhotoTaken {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *groupEnumerationShouldStop) {
                               [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                               [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                      usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *assetEnumerationShouldStop) {
                                                          if (asset == nil) {
                                                              // On iOS 6 I'm seeing this block called once with a nil asset after setting assetEnumerationShouldStop, this is to mitigate that.
                                                              return;
                                                          }

                                                          NSDictionary *mediaInfo = [self mediaInfoForAsset:asset];

                                                          if (mediaInfo != nil) {
                                                              [self setDisplayImageWithMediaInfo:mediaInfo];
                                                              *assetEnumerationShouldStop = YES;
                                                              *groupEnumerationShouldStop = YES;
                                                          }
                                                      }];
                           } failureBlock:^(NSError *error) {
                               NSLog(@"error: %@", error);
                           }];
}

- (UIImage *)imageForAssetRepresenation:(ALAssetRepresentation *)assetRepresenation {
    CGImageRef cgimage = assetRepresenation.fullResolutionImage;
    UIImage *image = [UIImage imageWithCGImage:cgimage
                                         scale:assetRepresenation.scale
                                   orientation:assetRepresenation.orientation];
    return image;
}

- (NSDictionary *)mediaInfoForAsset:(ALAsset *)asset {
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];

    UIImage *originalImage = nil;
    UIImage *editedImage = nil;

    ALAssetRepresentation *assetRep = asset.defaultRepresentation;
    UIImage *assetImage = [self imageForAssetRepresenation:assetRep];
    if (assetImage == nil) {
        return nil;
    }

    if (asset.originalAsset != nil) {
        ALAssetRepresentation *originalRep = asset.originalAsset.defaultRepresentation;
        originalImage = [self imageForAssetRepresenation:originalRep];
        editedImage = assetImage;
    } else {
        originalImage = assetImage;
    }

    [mediaInfo bp_safeSetObject:originalImage forKey:UIImagePickerControllerOriginalImage];
    [mediaInfo bp_safeSetObject:editedImage forKey:UIImagePickerControllerEditedImage];
    [mediaInfo bp_safeSetObject:assetRep.UTI forKey:UIImagePickerControllerMediaType];
    [mediaInfo bp_safeSetObject:assetRep.url forKey:UIImagePickerControllerMediaURL];

    return [mediaInfo copy];
}

- (BOOL)canShowImagePicker {
    if ([UIImagePickerController isSourceTypeAvailable:_sourceType]) {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:_sourceType];
        return ([mediaTypes containsObject:(id)kUTTypeImage]);
    }
    return NO;
}

- (UIImagePickerController *)imagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = _sourceType;
    picker.mediaTypes = @[(id)kUTTypeImage];
    picker.allowsEditing = NO;
    return picker;
}

- (void)setDisplayImageWithMediaInfo:(NSDictionary *)mediaInfo {
    UIImage *image = [mediaInfo objectForKey:UIImagePickerControllerOriginalImage];
    self.displayedImageView.image = image;
}

#pragma mark - UIImagePickerControlelrDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self setDisplayImageWithMediaInfo:info];

    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed");
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"cancelled");
    
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed");
    }];
}

@end
