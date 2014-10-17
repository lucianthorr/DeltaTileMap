//
//  TileOverlay.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapAppDelegate.h"

@interface ImageTile : NSObject {
    NSString *imagePath;
    MKMapRect frame;
}
@property (nonatomic, readonly) MKMapRect frame;
@property (nonatomic, readonly) NSString  *imagePath;

@end


@interface TileOverlay : MKTileOverlay {
    NSString *tileBase;
    MKMapRect boundingMapRect;
    NSSet *tilePaths;
}
@property (nonatomic, strong) NSMutableArray    *tiles;
@property int   numberOfVisibleTiles;
@property (nonatomic, strong) NSString          *tileName;

-(id)initWithTilePath:(NSString*)tileAddress;

-(NSArray*)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale;

@end
