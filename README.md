# BPPhotoLibrarian

## Description

Simple helpers for accessing the iOS photo library.

- Check for photo picker availability.
- Pre-configured photo picker generator.
- Check for asset library availability.
- Simple getter to retrieve the last saved photo.

## Usage

Add the MobileCoreServices and AssetLibrary frameworks to your "Link Binary With Libraries" build phase.

Add the BPPhotoLibrarian directory to your project and import the header.

    #import "BPPhotoLibrarian.h"

Check for available functionality and access photos.

    if ([BPPhotoLibrarian canRetrieveLastPhoto]) {
      [BPPhotoLibrarian retrieveLastPhoto:^(UIImage *lastPhoto, NSError *error) {
          if (lastPhoto == nil) {
              NSLog(@"error = %@", error);
          } else {
              // Show the photo.
          }
      }];
    }

For more, see the CameraRoller demo project.

## License

MIT - See LICENSE.txt

## Contact

Brian Partridge - @brianpartridge on Twitter and alpha.app.net