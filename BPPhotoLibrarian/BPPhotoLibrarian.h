//
//  BPPhotoLibrarian.h
//
//  Created by Brian Partridge on 11/3/12.
//  Copyright (c) 2012 Brian Partridge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BPPhotoLibrarian;

typedef void(^BPILCompletionBlock)(UIImage *lastPhoto, NSError *error);

@interface BPPhotoLibrarian : NSObject

+ (BOOL)canShowSavedPhotoPicker;
+ (UIImagePickerController *)savedPhotoPicker;

+ (BOOL)canRetrieveLastPhoto;
+ (void)retrieveLastPhoto:(BPILCompletionBlock)completionBlock;

@end
