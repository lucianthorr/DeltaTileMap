//
//  TileMapViewController.m
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import "TileMapViewController.h"
#import "TileOverlay.h"
#import "TileOverlayRenderer.h"



@implementation TileMapViewController
@synthesize map;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.selectedPlates = [[NSArray alloc] initWithArray:[appDelegate selectedDirectories]];
    if([appDelegate firstView]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"This app requires significant downloads.\nBe sure to connect to WIFI."
                                                            delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
        [alertView show];
        [appDelegate setFirstView:FALSE];
    }

    // Initialize the TileOverlay with tiles in the application's bundle's resource directory.
    // Any valid tiled image directory structure in there will do.
    if([self.selectedPlates count] == 0){
        TileOverlay *overlay = [[TileOverlay alloc] initWithTilePath:@"Plate22.01"];
        if(overlay != nil){
            [map addOverlay:overlay];
        }
    }else{
        for(int i = 0; i< [self.selectedPlates count]; i++){
            TileOverlay *overlay = [[TileOverlay alloc] initWithTilePath:[self.selectedPlates objectAtIndex:i]];
            if(overlay != nil){
                [map addOverlay:overlay];
            }
        }
    }
    // zoom in by a factor of two from the rect that contains the bounds
    // because MapKit always backs up to get to an integral zoom level so
    // we need to go in one so that we don't end up backed out beyond the
    // range of the TileOverlay.
    if([[map overlays] count] > 0){
        TileOverlay *firstOverlay = [[map overlays] objectAtIndex:0];
        MKMapRect visibleRect = [map mapRectThatFits:firstOverlay.boundingMapRect];
        visibleRect.size.width /= 2;
        visibleRect.size.height /= 2;
        visibleRect.origin.x += visibleRect.size.width / 2;
        visibleRect.origin.y += visibleRect.size.height / 2;
        //center the map taking the bottom bar's height into consideration if visible.
        if(!self.bottomLabel.hidden){
            //NSLog(@"Visible Origin X = %f, Y = %f", visibleRect.origin.x, visibleRect.origin.y);
            visibleRect.origin.y += 100000.0;
        }
        map.visibleMapRect = visibleRect;
    }
    //Set General View Settings
    self.view.backgroundColor = [UIColor whiteColor];
    //Start the Map in Hybrid Mode
    [self.mapStyleControl setSelectedSegmentIndex:2];
    map.mapType = MKMapTypeHybrid;
    
}
-(void)orientationChanged:(NSNotification*)notification{
    
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait){
        self.bottomLabel.hidden = NO;
        self.topLabel.hidden = NO;
        self.headlineLabel.hidden = NO;
        self.mapStyleControl.hidden = NO;
        self.mapSelectButton.hidden = NO;

    }else if(([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
             ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)){
        self.bottomLabel.hidden = YES;
        self.topLabel.hidden = YES;
        self.headlineLabel.hidden = YES;
        self.mapStyleControl.hidden = YES;
        self.mapSelectButton.hidden = YES;
    }
}

#pragma mark - MKMapView Delegate
//This is only called once each time the mapView is loaded.
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    self.tileRenderer = [[TileOverlayRenderer alloc] initWithTileOverlay:overlay];
    self.tileRenderer.viewController = self; 
    return self.tileRenderer;
}
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //NSLog(@"Region Did Change");
    CGPoint viewCenter = [self.view center];
    //NSLog(@"View Center: x = %f, y = %f", viewCenter.x, viewCenter.y);
    NSArray *overlays = [mapView overlays];
    float shortestDistance = 9999999.0;
    int closestTile = 0;
    for(int i = 0; i<[overlays count]; i++){
        TileOverlay *overlay = [overlays objectAtIndex:i];
        MKCoordinateRegion cr = MKCoordinateRegionForMapRect([overlay boundingMapRect]);
        CGRect tileRect = [mapView convertRegion:cr toRectToView:self.map];
        float tileCenterX = tileRect.origin.x + (tileRect.size.width/2.0);
        float tileCenterY = tileRect.origin.y + (tileRect.size.height/2.0);
        CGFloat distance = hypot(viewCenter.x - tileCenterX, viewCenter.y - tileCenterY);
        //NSLog(@"Distance from Tile %i = %f", i+1, distance);
        if(distance < shortestDistance){
            shortestDistance = distance;
            closestTile = i;
        }
    }
    self.headlineLabel.text = [NSString stringWithFormat:@"%@",[[overlays objectAtIndex:closestTile] tileName]];
}
#pragma mark - UISlider


-(IBAction)sliderChanged:(UISlider*)sender{
    for(int i = 0; i< [[map overlays] count]; i++){
        //[tileViews count] earlier
        TileOverlay *overlay = [[map overlays] objectAtIndex:i];
        TileOverlayRenderer *renderer = (TileOverlayRenderer*)[map rendererForOverlay:overlay];
        [renderer redrawWithAlpha:sender.value];
        [renderer setNeedsDisplay];
    }
    //[self.bottomLabel setAlpha:sender.value];
    //[self.bottomLabel setNeedsDisplay];
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
