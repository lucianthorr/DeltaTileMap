//
//  TileMapViewController.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class TileOverlayView, TileOverlay;
@interface TileMapViewController : UIViewController <MKMapViewDelegate>{
    IBOutlet MKMapView *map;

}
@property TileOverlayView   *tileView;
@property TileOverlay       *overlay;
@property IBOutlet UISegmentedControl   *mapStyleControl;
@property IBOutlet UISlider             *opacitySlider;
@property IBOutlet UILabel              *backgroundLabel;

-(IBAction)sliderChanged:(id)sender;

@end