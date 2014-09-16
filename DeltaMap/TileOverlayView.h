//
//  TileOverlayView.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface TileOverlayView : MKOverlayRenderer {
}

@property (nonatomic, assign) CGFloat tileAlpha;

-(void)redrawWithAlpha:(float)alpha;

@end