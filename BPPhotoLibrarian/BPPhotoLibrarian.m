//
//  BPPhotoLibrarian.m
//
//  Created by Brian Partridge on 11/3/12.
//  Copyright (c) 2012 Brian Partridge. All rights reserved.
//

#import "BPPhotoLibrarian.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Define default behavior: photo media from the saved photos album
#define SOURCE_TYPE     UIImagePickerControllerSourceTypeSavedPhotosAlbum
#define MEDIA_TYPES     @[(id)kUTTypeImage]
#define ASSET_GROUP     ALAssetsGroupSavedPhotos
#define ASSET_FILTER    [ALAssetsFilter allPhotos]

@implementation BPPhotoLibrarian

#pragma mark - Image Picker

+ (BOOL)canShowSavedPhotoPicker {
    if ([UIImagePickerController isSourceTypeAvailable:SOURCE_TYPE]) {
        NSSet *availableMediaTypes = [NSSet setWithArray:[UIImagePickerController availableMediaTypesForSourceType:SOURCE_TYPE]];
        NSSet *desiredMediaTypes = [NSSet setWithArray:MEDIA_TYPES];
        return [desiredMediaTypes isSubsetOfSet:availableMediaTypes];
    }
    return NO;
}

+ (UIImagePickerController *)savedPhotoPickerWithDelegate:(id<BPPLPickerDelegate>)delegate; {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = SOURCE_TYPE;
    picker.mediaTypes = MEDIA_TYPES;
    picker.delegate = delegate;

    return picker;
}

#pragma mark - Last Image

+ (BOOL)canRetrieveLastPhoto {
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    return (authStatus == ALAuthorizationStatusNotDetermined ||
            authStatus == ALAuthorizationStatusAuthorized);
}

+ (void)retrieveLastPhoto:(BPPLImageBlock)completionBlock error:(BPPLErrorBlock)errorBlock {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ASSET_GROUP
                           usingBlock:^(ALAssetsGroup *group, BOOL *groupEnumerationShouldStop) {
                               [group setAssetsFilter:ASSET_FILTER];
                               // Enumerate the assets in reverse, so that the first asset is the latest photo.
                               [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                      usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *assetEnumerationShouldStop) {
                                                          if (asset == nil) {
                                                              // On iOS 6 I'm seeing this block called once with a nil asset after setting assetEnumerationShouldStop, this is to mitigate that.
                                                              return;
                                                          }

                                                          ALAssetRepresentation *assetRep = asset.defaultRepresentation;
                                                          UIImage *assetImage = [self imageForAssetRepresenation:assetRep];

                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (completionBlock != nil) {
                                                                  completionBlock(assetImage);
                                                              }
                                                          });

                                                          *assetEnumerationShouldStop = YES;
                                                          *groupEnumerationShouldStop = YES;
                                                      }];
                           } failureBlock:^(NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (errorBlock != nil) {
                                       errorBlock(error);
                                   }
                               });
                           }];
}

#pragma mark - Asset Library Utils

+ (UIImage *)imageForAssetRepresenation:(ALAssetRepresentation *)assetRepresenation {
    CGImageRef cgimage = assetRepresenation.fullResolutionImage;
    UIImage *image = [UIImage imageWithCGImage:cgimage
                                         scale:assetRepresenation.scale
                                   orientation:assetRepresenation.orientation];
    return image;
}

@end
