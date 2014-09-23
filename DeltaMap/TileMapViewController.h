//
//  TileMapViewController.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAppDelegate.h"

@class TileOverlayRenderer, TileOverlay;
@interface TileMapViewController : UIViewController <MKMapViewDelegate>{


}
@property (nonatomic, strong) IBOutlet MKMapView *map;
@property (nonatomic, strong) TileOverlayRenderer *tileRenderer;
@property (nonatomic, strong) NSArray           *selectedPlates;

@property IBOutlet UISegmentedControl   *mapStyleControl;
@property IBOutlet UISlider             *opacitySlider;
@property IBOutlet UILabel              *backgroundLabel;


-(IBAction)sliderChanged:(id)sender;

@end
