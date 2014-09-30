//
//  TileOverlayRenderer.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <MapKit/MapKit.h>

@class TileMapViewController;
@interface TileOverlayRenderer : MKTileOverlayRenderer {
    NSData *downloadedData;
}
@property (nonatomic, strong) TileMapViewController *viewController;
@property (nonatomic, assign) CGFloat   tileAlpha;


-(void)redrawWithAlpha:(float)alpha;


@end