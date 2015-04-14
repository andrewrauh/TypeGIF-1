//
//  ChangeCollectionViewController.m
//  TypeGIF
//
//  Created by Andrew Rauh on 4/13/15.
//  Copyright (c) 2015 EECS493. All rights reserved.

//http://stackoverflow.com/questions/6168919/how-do-i-set-up-a-simple-delegate-to-communicate-between-two-view-controllers

#import "ChangeCollectionViewController.h"
#import "DatabaseManager.h"

@interface ChangeCollectionViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) DatabaseManager *db;
@property int selectedRow;
@end

@implementation ChangeCollectionViewController


-(void)viewWillAppear:(BOOL)animated {
    self.collections = [NSMutableArray arrayWithArray:[self.db getAllCollections]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionsTableView.delegate = self;
    self.collectionsTableView.dataSource = self;
    self.db = [DatabaseManager createDatabaseInstance];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressClose:(id)sender {
    id<ChangeDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(childViewController:didChooseCollection:)]) {
        [strongDelegate childViewController:self didChooseCollection:[self.collections objectAtIndex:self.selectedRow]];
    }

}

#pragma mark - UITableView Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.collections count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.selectedRow) {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        [selectedCell setAccessoryType:UITableViewCellAccessoryNone];

    }
    else {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
