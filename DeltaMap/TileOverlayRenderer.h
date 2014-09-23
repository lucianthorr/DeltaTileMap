//
//  TileOverlayRenderer.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface TileOverlayRenderer : MKTileOverlayRenderer {
}

@property (nonatomic, assign) CGFloat tileAlpha;

-(void)redrawWithAlpha:(float)alpha;


@end