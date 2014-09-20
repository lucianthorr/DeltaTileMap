//
//  TileOverlayView.m
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import "TileOverlayView.h"
#import "TileOverlay.h"

@implementation TileOverlayView
@synthesize tileAlpha;
-(id)initWithOverlay:(id<MKOverlay>)overlay{
    if(self = [super initWithOverlay:overlay]){
        tileAlpha = 0.5;
    }
    return self;
}


-(BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale{
    TileOverlay *tileOverlay = (TileOverlay *)self.overlay;
    NSArray *tilesInRect = [tileOverlay tilesInMapRect:mapRect zoomScale:zoomScale];
    return [tilesInRect count] > 0;
}
-(void)setNeedsDisplay{
    [super setNeedsDisplay];
}

-(void)drawMapRect:(MKMapRect)mapRect
         zoomScale:(MKZoomScale)zoomScale
         inContext:(CGContextRef)context{
    TileOverlay *tileOverlay = (TileOverlay *)self.overlay;
    // Get the list of tile images from the model object for this mapRect.  The
    // list may be 1 or more images (but not 0 because canDrawMapRect would have
    // returned NO in that case).
    NSArray *tilesInRect = [tileOverlay tilesInMapRect:mapRect zoomScale:zoomScale];
    
    CGContextSetAlpha(context, tileAlpha);
    for (ImageTile *tile in tilesInRect) {
        // For each image tile, draw it in its corresponding MKMapRect frame
        CGRect rect = [self rectForMapRect:tile.frame];
        UIImage *originalImage = [[UIImage alloc] initWithContentsOfFile:tile.imagePath];
        /*Mask White to Transparent */
        UIImage *image = [self replaceColor: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] inImage:originalImage withTolerance:1.0];
        
        /* Resume drawing Rect */
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, 1/zoomScale, 1/zoomScale);
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
        CGContextRestoreGState(context);
    }
}
-(void)redrawWithAlpha:(float)alpha{
    tileAlpha = alpha;
    //[self drawMapRect:mapRect zoomScale:zoomScale inContext:context];
}
#pragma mark - CGMasking Methods
//Thanks to PKCLsoft at http://stackoverflow.com/questions/633722/how-to-make-one-color-transparent-on-a-uiimage
- (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance {
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;
    
    unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    //float a = components[3]; // not needed
    
    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;
    
    const float redRange[2] = {
        MAX(r - (tolerance / 2.0), 0.0),
        MIN(r + (tolerance / 2.0), 255.0)
    };
    
    const float greenRange[2] = {
        MAX(g - (tolerance / 2.0), 0.0),
        MIN(g + (tolerance / 2.0), 255.0)
    };
    
    const float blueRange[2] = {
        MAX(b - (tolerance / 2.0), 0.0),
        MIN(b + (tolerance / 2.0), 255.0)
    };
    
    int byteIndex = 0;
    
    while (byteIndex < bitmapByteCount) {
        unsigned char red   = rawData[byteIndex];
        unsigned char green = rawData[byteIndex + 1];
        unsigned char blue  = rawData[byteIndex + 2];
        
        if (((red >= redRange[0]) && (red <= redRange[1])) &&
            ((green >= greenRange[0]) && (green <= greenRange[1])) &&
            ((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
            // make the pixel transparent
            //
            rawData[byteIndex] = 0;
            rawData[byteIndex + 1] = 0;
            rawData[byteIndex + 2] = 0;
            rawData[byteIndex + 3] = 0;
        }
        
        byteIndex += 4;
    }
    
    UIImage *result = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    
    CGContextRelease(context);
    free(rawData);
    
    return result;
}

@end
