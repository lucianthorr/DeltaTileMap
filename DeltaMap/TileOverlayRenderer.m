//
//  TileOverlayView.m
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import "TileOverlayRenderer.h"
#import "TileOverlay.h"

@implementation TileOverlayRenderer
@synthesize tileAlpha;
-(id)initWithTileOverlay:(MKTileOverlay*)overlay{
    if(self = [super initWithTileOverlay:overlay]){
        tileAlpha = 0.5;
    }
    return self;
}
-(id)initWithOverlay:(id<MKOverlay>)overlay AndAlpha:(float)alpha{
    if(self = [super initWithOverlay:overlay]){
        tileAlpha = (CGFloat)alpha;
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
    //synchronized is used to protect the *tiles in tilesInRect from being written to and read at the same time
    @synchronized(self){
        for (ImageTile *tile in tilesInRect) {
            // For each image tile, draw it in its corresponding MKMapRect frame
            CGRect rect = [self rectForMapRect:tile.frame];
            NSString *documentDirectory =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                            NSUserDomainMask, YES) objectAtIndex:0];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:tile.imagePath];
            if(image == nil){
                NSString *savedImagePath = [NSString stringWithFormat:@"%@/%@", documentDirectory, tile.imagePath];
                image = [[UIImage alloc] initWithContentsOfFile:savedImagePath];
            }
            if(image == nil){
                NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wrong-question.com/plates/%@", tile.imagePath]];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                image = [[UIImage alloc] initWithData:imageData];
                [self writeToFile:imageData atPath:tile.imagePath];
            }
            /*Mask White to Transparent */
            image = [self replaceColor: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] inImage:image withTolerance:1.0];
            
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
}
-(void)writeToFile:(NSData*)data atPath:(NSString*)filePath{
    NSError *error;
    //NSData *data = [args objectAtIndex:0];
    //NSString *filePath = [args objectAtIndex:1];
    NSArray *folders = [[filePath stringByDeletingPathExtension] pathComponents];
    NSString *documentDirectory =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plateFolder = [documentDirectory stringByAppendingString:
                            [NSString stringWithFormat:@"/%@", [folders objectAtIndex:0]]];
    NSString *xFolder = [plateFolder stringByAppendingString:
                         [NSString stringWithFormat:@"/%@", [folders objectAtIndex:1]]];
    NSString *yFolder = [xFolder stringByAppendingString:
                         [NSString stringWithFormat:@"/%@",[folders objectAtIndex:2]]];
    NSString *zFile = [yFolder stringByAppendingString:
                       [NSString stringWithFormat:@"/%@.png",[folders objectAtIndex:3]]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:plateFolder]){
        if([[NSFileManager defaultManager] createDirectoryAtPath:plateFolder withIntermediateDirectories:NO attributes:nil error:&error]){
            NSLog(@"Success writing plateFolder\nplateFolder = %@", plateFolder);
        }else{
            NSLog(@"Problem writing plateFolder");
        }
    }else{
        NSLog(@"plateFolder Exists");
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:xFolder]){
        if([[NSFileManager defaultManager] createDirectoryAtPath:xFolder withIntermediateDirectories:NO attributes:nil error:&error]){
            NSLog(@"Success writing xFolder\nxFolder = %@", xFolder);
        }else{
            NSLog(@"Problem writing xFolder");
        }
    }else{
        NSLog(@"xFolder Exists");
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:yFolder]){
        if([[NSFileManager defaultManager] createDirectoryAtPath:yFolder withIntermediateDirectories:NO attributes:nil error:&error]){
            NSLog(@"Success writing yFolder\nyFolder = %@", yFolder);
        }else{
            NSLog(@"Problem writing yFolder");
        }
    }else{
        NSLog(@"yFolder Exists");
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:zFile]){
        if([[NSFileManager defaultManager] createFileAtPath:zFile contents:data attributes:nil]){
            NSLog(@"Write file\nFile = %@", zFile);
        }else{
            NSLog(@"Problem writing file");
        }
    }else{
        NSLog(@"File Exists");
    }
    
    
}

-(void)redrawWithAlpha:(float)alpha{
    tileAlpha = alpha;
}

#pragma mark - CGMasking Methods
//Thanks to PKCLsoft at http://stackoverflow.com/questions/633722/how-to-make-one-color-transparent-on-a-uiimage
//Definitely causes significant memory leaks however
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
    CGImageRef bitmapImage = CGBitmapContextCreateImage(context);  //Fixed memory leak - create bitmapImage
    UIImage *result = [UIImage imageWithCGImage:bitmapImage];       //Use As Argument
    CGContextRelease(context);
    CGImageRelease(bitmapImage);                                    //Release memory when finished
    free(rawData);

    return result;
}

@end
