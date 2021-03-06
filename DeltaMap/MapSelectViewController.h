//
//  MapSelectViewController.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/15/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapAppDelegate.h"


@interface MapSelectViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong)   NSArray                 *jSONDirectory;
@property (nonatomic, strong)   IBOutlet UITableView    *tableView;
@property (nonatomic, strong)   IBOutlet UIButton       *emptyCacheButton;

-(IBAction)backPressed:(id)sender;
-(IBAction)emptyCache:(id)sender;

@end
