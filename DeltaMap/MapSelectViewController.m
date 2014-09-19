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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

-(void)downloadPressed:(id)sender{
    NSArray *selections = [self.tableView indexPathsForSelectedRows];
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDirectoryEnumerator *e = [fileman enumeratorAtPath:paths[0]];
    NSArray *alreadyDownloaded = [e allObjects];
    for(int i = 0; i<[selections count]; i++){
        UITableViewCell *plateSelected = [self.tableView cellForRowAtIndexPath:[selections objectAtIndex:i] ];
        NSString *plateText = [plateSelected.textLabel.text stringByReplacingOccurrencesOfString:@"*" withString:@""];
        if(![alreadyDownloaded containsObject:plateText]){
            //Replacing the * with / turns it into the directory string
            [self downloadSelection:plateText];
        }
    }

    [self.tableView reloadData];
}
             
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
        NSLog(@"File Saved.");
    }else{
        NSLog(@"Problem Saving.");
    }
    NSString *tarFilename =[zipFilename stringByReplacingOccurrencesOfString:@".zip" withString:@""];
    NSLog(@"Unzip as %@", tarFilename);
    if([SSZipArchive unzipFileAtPath:zipFilename toDestination:documentDirectory]){
        NSLog(@"Unzipped.");
    }else{
        NSLog(@"Problem Unzipping.");
    }
    NSData *tarData = [NSData dataWithContentsOfFile:tarFilename];
    [[NSFileManager defaultManager] createFilesAndDirectoriesAtPath:documentDirectory withTarData:tarData error:&error];
    [self updateList];
}

#pragma mark - UITableview

-(void)updateList{
    // Get the list of downloadable plates and compare with resources to see what is already downloaded
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.directoryList = appDelegate.directoryList;
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDirectoryEnumerator *e = [fileman enumeratorAtPath:paths[0]];
    self.toBeDownloaded = [[NSMutableArray alloc] init];
    NSArray *alreadyDownloaded = [e allObjects];
    NSLog(@"Update List");
    for(int i = 0; i<[alreadyDownloaded count]; i++){
        NSLog(@"Already Downloaded = %@", [alreadyDownloaded objectAtIndex:i]);
    }
    for(int i = 0; i<[self.directoryList count]; i++){
        [self.toBeDownloaded addObject:@"*"];
        NSLog(@"In Directory List: %@", [self.directoryList objectAtIndex:i]);
        if([alreadyDownloaded containsObject:[self.directoryList objectAtIndex:i]]){
            [self.toBeDownloaded replaceObjectAtIndex:i withObject:@""];
        }
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.directoryList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",[self.directoryList objectAtIndex:indexPath.row],[self.toBeDownloaded objectAtIndex:indexPath.row]];
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
