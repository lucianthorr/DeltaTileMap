//
//  MapAppDelegate.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TileMapViewController;

@interface MapAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TileMapViewController *tileMapViewController;
@property (strong, nonatomic) NSMutableArray        *selectedDirectories;
@property (strong, nonatomic) NSDictionary          *jSONDictionary;

@end
