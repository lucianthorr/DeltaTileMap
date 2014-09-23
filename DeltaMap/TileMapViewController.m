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
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.selectedPlates = [[NSArray alloc] initWithArray:[appDelegate selectedDirectories]];

    // Initialize the TileOverlay with tiles in the application's bundle's resource directory.
    // Any valid tiled image directory structure in there will do.
    //self.overlays = [[NSMutableArray alloc] init];
    if([self.selectedPlates count] == 0){
        NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Plate22.01"];
        NSLog(@"Tile Directory = %@\n\n", tileDirectory);
        TileOverlay *overlay = [[TileOverlay alloc] initWithTileDirectory:tileDirectory];
        [map addOverlay:overlay];
    }else{
        for(int i = 0; i< [self.selectedPlates count]; i++){
            if([[self.selectedPlates objectAtIndex:i] isEqualToString:@"Plate22.01"]){
                NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Plate22.01"];
                NSLog(@"Tile Directory = %@\n\n", tileDirectory);
                TileOverlay *overlay = [[TileOverlay alloc] initWithTileDirectory:tileDirectory];
                [map addOverlay:overlay];
            }else{
                NSMutableString *directory = [NSMutableString stringWithFormat:@"%@/",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0]];
                [directory appendString:[self.selectedPlates objectAtIndex:i]];
                TileOverlay *overlay = [[TileOverlay alloc] initWithTileDirectory:directory];
                [map addOverlay:overlay];
            }
        }
    }
    // zoom in by a factor of two from the rect that contains the bounds
    // because MapKit always backs up to get to an integral zoom level so
    // we need to go in one so that we don't end up backed out beyond the
    // range of the TileOverlay.
    //if(self.overlays > 0){
    if([[map overlays] count] > 0){
        TileOverlay *firstOverlay = [[map overlays] objectAtIndex:0];
        MKMapRect visibleRect = [map mapRectThatFits:firstOverlay.boundingMapRect];
        visibleRect.size.width /= 2;
        visibleRect.size.height /= 2;
        visibleRect.origin.x += visibleRect.size.width / 2;
        visibleRect.origin.y += visibleRect.size.height / 2;
        map.visibleMapRect = visibleRect;
    }
    //Set General View Settings
    self.view.backgroundColor = [UIColor whiteColor];
    //Start the Map in Hybrid Mode
    [self.mapStyleControl setSelectedSegmentIndex:2];
    map.mapType = MKMapTypeHybrid;
    
}

//This is only called once each time the mapView is loaded.
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    self.tileRenderer = [[TileOverlayRenderer alloc] initWithTileOverlay:overlay];
    return self.tileRenderer;
}

#pragma mark - UISlider

-(void)sliderChanged:(UISlider*)sender{
    for(int i = 0; i< [[map overlays] count]; i++){
        //[tileViews count] earlier
        TileOverlay *overlay = [[map overlays] objectAtIndex:i];
        TileOverlayRenderer *renderer = (TileOverlayRenderer*)[map rendererForOverlay:overlay];
        [renderer redrawWithAlpha:sender.value];
        [renderer setNeedsDisplay];
    }
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
