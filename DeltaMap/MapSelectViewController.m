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

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.jSONDirectory = [[appDelegate.jSONDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButtons

-(IBAction)backPressed:(id)sender{
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *selections = [[NSMutableArray alloc] init];
    for(int i = 0; i< [selectedRows count]; i++){
        //[selections addObject:[self.tableView cellForRowAtIndexPath:[selectedRows objectAtIndex:i]].textLabel.text];
        NSIndexPath *path = [selectedRows objectAtIndex:i];
        [selections addObject:[self.jSONDirectory objectAtIndex:path.row]];
    }
    [appDelegate setSelectedDirectories:selections];
}
-(void)emptyCache:(id)sender{
    NSError *error;
    NSArray *downloadedTiles = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] error:&error];
    NSString *documentDirectory =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask, YES) objectAtIndex:0];
    for(int i = 0; i < [downloadedTiles count]; i++){
        NSString *tilePath = [NSString stringWithFormat:@"%@/%@",documentDirectory,[downloadedTiles objectAtIndex:i]];
        [[NSFileManager defaultManager] removeItemAtPath:tilePath error:&error];
    }
}

#pragma mark - UITableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.jSONDirectory.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.textLabel.text = [[self.jSONDirectory objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"." withString:@", Sheet "];
    return cell;
}
//Creates a Maximum of 4 maps allowed to be selected at once.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[tableView indexPathsForSelectedRows] count] > 4){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
