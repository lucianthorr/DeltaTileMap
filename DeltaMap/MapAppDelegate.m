//
//  MapAppDelegate.m
//  DeltaMap
//
//  Created by Jason Aylward on 9/12/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import "MapAppDelegate.h"

@implementation MapAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Open connection to wrong-question/plates/plateindex.txt
    //Read in available directories
    self.directoryList = [self retrieveAvailablePlates];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(NSArray*)retrieveAvailablePlates{
    NSError *error;
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    //Connect to json list of available plates
    NSString *url =@"http://www.wrong-question.com/plates/plateindex.json";
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSData *webData = [NSData dataWithContentsOfURL:urlRequest];
    //parse json file into NSDictionary
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:webData options:NSJSONReadingMutableLeaves error:&error];
    tempList = [dictionary objectForKey:@"contents"];
    NSArray *finalList = [[NSArray alloc] initWithArray:tempList];
    return finalList;
}

@end
