//
//  NSImage+Resize.m
//  PhotoNoteBook
//
//  Created by 안 진섭 on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSImage+Resize.h"

@implementation NSImage(ResizeImage)

- (NSImage*)imageByBestFitForSize:(CGSize)targetSize {

    CGFloat aspectRatio = (float) self.size.width / (float) self.size.height;

    CGFloat targetHeight = targetSize.height;
    CGFloat scaledWidth = targetSize.height * aspectRatio;
    CGFloat targetWidth = (targetSize.width < scaledWidth) ? targetSize.width : scaledWidth;

    return [self imageByScalingAndCroppingForSize:CGSizeMake(targetWidth, targetHeight)];

}

- (NSImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    NSImage *sourceImage = self;
    NSImage *newImage = nil;        
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) 
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = ceil(width * scaleFactor);
        scaledHeight = ceil(height * scaleFactor);
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else 
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    newImage = [[NSImage alloc] initWithSize: NSMakeSize(scaledWidth, scaledHeight)];
    
    [newImage lockFocus];
    [sourceImage drawInRect: NSMakeRect(0, 0, scaledWidth, scaledHeight) fromRect: NSMakeRect(0, 0, width, height) operation: NSCompositeSourceOver fraction: 1.0];
    [newImage unlockFocus];
    
    return newImage;
}

- (NSData*) PNGData
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:[NSDictionary dictionary]];
    
    return [NSData dataWithData:imageData];
}
- (NSData*) JPEGData
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    
    return [NSData dataWithData:imageData];
}

@end
