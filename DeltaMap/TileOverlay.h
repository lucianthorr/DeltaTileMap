//
//  TileOverlay.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ImageTile : NSObject {
    NSString *imagePath;
    MKMapRect frame;
}
@property (nonatomic, readonly) MKMapRect frame;
@property (nonatomic, readonly) NSString  *imagePath;

@end


@interface TileOverlay : NSObject <MKOverlay>{
    NSString *tileBase;
    MKMapRect boundingMapRect;
    NSSet *tilePaths;
}

-(id)initWithTileDirectory:(NSString*)tileDirectory;

-(NSArray*)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale;

@end
