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
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.jSONDirectory = [appDelegate.jSONDictionary allKeys];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Back Button

-(IBAction)backPressed:(id)sender{
    MapAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *selections = [[NSMutableArray alloc] init];
    for(int i = 0; i< [selectedRows count]; i++){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[selectedRows objectAtIndex:i]];
        NSLog(@"Selected = %@", cell.textLabel.text);
        [selections addObject:[self.tableView cellForRowAtIndexPath:[selectedRows objectAtIndex:i]].textLabel.text];
    }
    [appDelegate setSelectedDirectories:selections];
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.jSONDirectory objectAtIndex:indexPath.row]];
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
