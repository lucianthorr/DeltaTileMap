//
//  MapSelectViewController.m
//  DeltaMap
//
//  Created by Jason Aylward on 9/15/14.
//  Copyright (c) 2014 Jason Aylward. All rights reserved.
//

#import "MapSelectViewController.h"

@interface MapSelectViewController ()

@end

@implementation MapSelectViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateList];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Download Button

/*! Retrieves tableView selections and runs downloadSelection on all selections not already downloaded 
\n  downloadSelection is run on a separate thread so that the UI is not interupted
*/
-(void)downloadPressed:(id)sender{
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *downloadState = appDelegate.downloadState;
    NSArray *selections = [self.tableView indexPathsForSelectedRows];
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDirectoryEnumerator *e = [fileman enumeratorAtPath:paths[0]];
    NSArray *alreadyDownloaded = [e allObjects];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for(int i = 0; i<[selections count]; i++){
        NSIndexPath *index = [selections objectAtIndex:i];
        UITableViewCell *plateSelected = [self.tableView cellForRowAtIndexPath:index];
        NSString *plateText = [plateSelected.textLabel.text stringByReplacingOccurrencesOfString:@"*" withString:@""];
        if(![alreadyDownloaded containsObject:plateText]){
            //Grey Out the currently downloading TableViewCell
            [downloadState replaceObjectAtIndex:index.row withObject:@" - downloading"];
            plateSelected.textLabel.textColor = [UIColor grayColor];
            plateSelected.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:15];
            [self.tableView reloadData];
            //Replacing the * with / turns it into the directory string
            NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadSelection:) object:plateText];
            [queue addOperation:invocation];
        }
    }

    [self.tableView reloadData];
}
/*! downloadSelection is meant to be run on a separate thread in NSOperationQueue
  \n downloads the file, unzips and untars it and then runs update List to refresh the tableView
*/
-(void)downloadSelection:(NSString*)selectedPlate{
    NSError *error;
    NSString *baseURL = @"http://www.wrong-question.com/plates/";
    NSString *plateURL = [NSString stringWithFormat:@"%@%@.tar.zip",baseURL,selectedPlate];
    NSLog(@"plate URL = %@", plateURL);
    NSURL *urlRequest = [NSURL URLWithString:plateURL];
    NSData *webData = [NSData dataWithContentsOfURL:urlRequest];
    NSString *documentDirectory =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                    NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"Save in %@", documentDirectory);
    NSString *zipFilename = [NSString stringWithFormat:@"%@/%@.tar.zip",documentDirectory,selectedPlate];
    NSLog(@"Save as %@", zipFilename);
    if([webData writeToFile:zipFilename atomically:YES]){
        NSLog(@"Zip Saved.");
    }else{
        NSLog(@"Problem Saving Zip.");
    }
    NSString *tarFilename =[zipFilename stringByReplacingOccurrencesOfString:@".zip" withString:@""];
    NSLog(@"Unzip as %@", tarFilename);
    if([SSZipArchive unzipFileAtPath:zipFilename toDestination:documentDirectory]){
        NSLog(@"Unzipped.");
    }else{
        NSLog(@"Problem Unzipping.");
    }
    NSData *tarData = [NSData dataWithContentsOfFile:tarFilename];
    if([[NSFileManager defaultManager] createFilesAndDirectoriesAtPath:documentDirectory withTarData:tarData error:&error]){
        NSLog(@"Filename = %@", tarFilename);
        NSLog(@"Untarred and Saved");
    }else{
        NSLog(@"Problem untarring.");
    }
    [self updateList];
}
#pragma mark - Back Button

-(IBAction)backPressed:(id)sender{
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *selections = [[NSMutableArray alloc] init];
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDirectoryEnumerator *e = [fileman enumeratorAtPath:paths[0]];
    NSMutableArray *alreadyDownloaded = [[NSMutableArray alloc] initWithArray:@[@"Plate22.01"]];
    [alreadyDownloaded addObjectsFromArray:[e allObjects]];

    for(int i = 0; i< [selectedRows count]; i++){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[selectedRows objectAtIndex:i]];
        NSLog(@"Selected = %@", cell.textLabel.text);
        if ([alreadyDownloaded containsObject:cell.textLabel.text]) {
            [selections addObject:[self.tableView cellForRowAtIndexPath:[selectedRows objectAtIndex:i]].textLabel.text];
        }
        
    }
    [appDelegate setSelectedDirectories:selections];
}
#pragma mark - UITableview
/*! Get the list of downloadable plates and compare with resources to see what is already downloaded
\n  directoryList contains all the plates available at wrong-question.com
\n alreadyDownloaded contains all the plates downloaded into NSDocumentDirectory
\n downloadState is an array of Strings where locations of NON-Downloaded plates contain '*', used for tableView
 */
-(void)updateList{
    NSLog(@"updateList");
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.directoryList = appDelegate.directoryList;
    NSMutableArray *downloadState = appDelegate.downloadState;
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDirectoryEnumerator *e = [fileman enumeratorAtPath:paths[0]];
    NSMutableArray *alreadyDownloaded = [[NSMutableArray alloc] initWithArray:@[@"Plate22.01"]];
    [alreadyDownloaded addObjectsFromArray:[e allObjects]];
    for(int i = 0; i<[self.directoryList count]; i++){
        if([alreadyDownloaded containsObject:[self.directoryList objectAtIndex:i]]){
            if(i >= [downloadState count]){
                [downloadState insertObject:@"" atIndex:i];
            }else{
                [downloadState replaceObjectAtIndex:i withObject:@""];
            }
        }else if(i < [downloadState count]){
            if([[downloadState objectAtIndex:i] isEqualToString:@" - downloading"]){
                
            }else{
                
            }
        }else{
            [downloadState addObject:@"*"];
        }
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.directoryList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *downloadState = appDelegate.downloadState;
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",[self.directoryList objectAtIndex:indexPath.row],[downloadState objectAtIndex:indexPath.row]];
    if([[downloadState objectAtIndex:indexPath.row] isEqualToString:@""]){
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    }
    if([[downloadState objectAtIndex:indexPath.row] isEqualToString:@" - downloading"]){
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:15];
    }
    return cell;
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
