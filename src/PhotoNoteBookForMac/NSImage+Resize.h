//
//  NSImage+Resize.h
//  PhotoNoteBook
//
//  Created by 안 진섭 on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSImage(ResizeImage)

- (NSImage*)imageByBestFitForSize:(CGSize)targetSize;
- (NSImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (NSData*) PNGData;

@end
