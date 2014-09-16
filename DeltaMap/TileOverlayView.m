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
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:tile.imagePath];
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

@end
