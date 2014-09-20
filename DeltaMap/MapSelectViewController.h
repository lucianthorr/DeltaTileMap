//
//  MapSelectViewController.h
//  DeltaMap
//
//  Created by Jason Aylward on 9/15/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapAppDelegate.h"
#import "NSFileManager+Tar.h"
#import "SSZipArchive.h"

@interface MapSelectViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong)   NSArray                 *directoryList;
//@property (nonatomic, strong)   NSMutableArray          *downloadState; // contains * for not downloaded, "" for downloaded and
                                                                        // " - downloading" if currently downloading
@property (nonatomic, strong)   IBOutlet UITableView    *tableView;

-(IBAction)downloadPressed:(id)sender;
-(IBAction)backPressed:(id)sender;

@end
