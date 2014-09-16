//
//  TileMapViewController.m
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import "TileMapViewController.h"
#import "TileOverlay.h"
#import "TileOverlayView.h"



@implementation TileMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Initialize the TileOverlay with tiles in the application's bundle's resource directory.
    // Any valid tiled image directory structure in there will do.
    NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"plate22_1"];
    NSLog(@"Tile Directory = %@\n\n", tileDirectory);
    self.overlay = [[TileOverlay alloc] initWithTileDirectory:tileDirectory];
    [map addOverlay:self.overlay];
    
    // zoom in by a factor of two from the rect that contains the bounds
    // because MapKit always backs up to get to an integral zoom level so
    // we need to go in one so that we don't end up backed out beyond the
    // range of the TileOverlay.
    MKMapRect visibleRect = [map mapRectThatFits:self.overlay.boundingMapRect];
    visibleRect.size.width /= 2;
    visibleRect.size.height /= 2;
    visibleRect.origin.x += visibleRect.size.width / 2;
    visibleRect.origin.y += visibleRect.size.height / 2;
    map.visibleMapRect = visibleRect;
    
    //Set General View Settings
    self.view.backgroundColor = [UIColor whiteColor];
    //Start the Map in Hybrid Mode
    [self.mapStyleControl setSelectedSegmentIndex:2];
    map.mapType = MKMapTypeHybrid;
    
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    self.tileView = [[TileOverlayView alloc] initWithOverlay:overlay];
    return self.tileView;
}
#pragma mark - UISlider

-(void)sliderChanged:(UISlider*)sender{
    [self.tileView setTileAlpha:sender.value];
    [self.tileView setNeedsDisplay];
    [self.backgroundLabel setAlpha:sender.value];
    [self.backgroundLabel setNeedsDisplay];
}

#pragma mark - UISegmentedController
- (IBAction)setMapType:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            map.mapType = MKMapTypeStandard;
            break;
        case 1:
            map.mapType = MKMapTypeSatellite;
            break;
        case 2:
            map.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
