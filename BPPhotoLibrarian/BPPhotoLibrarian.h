//
//  BPPhotoLibrarian.h
//
//  Created by Brian Partridge on 11/3/12.
//  Copyright (c) 2012 Brian Partridge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BPPhotoLibrarian;

@protocol BPPLPickerDelegate <NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

typedef void(^BPPLImageBlock)(UIImage *image);
typedef void(^BPPLErrorBlock)(NSError *error);

@interface BPPhotoLibrarian : NSObject

+ (BOOL)canShowSavedPhotoPicker;
+ (UIImagePickerController *)savedPhotoPickerWithDelegate:(id<BPPLPickerDelegate>)delegate;

+ (BOOL)canRetrieveLastPhoto;
+ (void)retrieveLastPhoto:(BPPLImageBlock)completionBlock error:(BPPLErrorBlock)errorBlock;

@end
