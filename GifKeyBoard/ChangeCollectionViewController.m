//
//  ChangeCollectionViewController.m
//  TypeGIF
//
//  Created by Andrew Rauh on 4/13/15.
//  Copyright (c) 2015 EECS493. All rights reserved.

//http://stackoverflow.com/questions/6168919/how-do-i-set-up-a-simple-delegate-to-communicate-between-two-view-controllers

#import "ChangeCollectionViewController.h"
#import "DatabaseManager.h"

@interface ChangeCollectionViewController () <UITableViewDataSource, UITableViewDelegate, ChangeDelegate>
@property (nonatomic, strong) DatabaseManager *db;
@property int selectedRow;
@end

@implementation ChangeCollectionViewController

-(void)viewWillAppear:(BOOL)animated {
    self.collections = [NSMutableArray arrayWithArray:[self.db getAllCollections]];
    [self.collectionsTableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionsTableView.delegate = self;
    self.collectionsTableView.dataSource = self;
    self.collections = [NSMutableArray new];
    self.db = [DatabaseManager createDatabaseInstance];
    self.selectedRow = 0;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressClose:(id)sender {
    id<ChangeDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(childViewController:didChooseCollection:)] && [self.collections count] > self.selectedRow) {
        [strongDelegate childViewController:self didChooseCollection:[self.collections objectAtIndex:self.selectedRow]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Generate a Pastel Background
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.2];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.textLabel setText:[self.collections objectAtIndex:indexPath.row]];
    [cell setBackgroundColor:color];
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
        UITableViewCell *prevCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectedRow inSection:0] ];
        [prevCell setAccessoryType:UITableViewCellAccessoryNone];
        NSLog(@"cell checkmark");
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        self.selectedRow = (int)indexPath.row;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        id<ChangeDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(childViewController:didChooseCollection:)]) {
            [strongDelegate childViewController:self didChooseCollection:(NSString*)[self.collections objectAtIndex:self.selectedRow]];
        }
    }];
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
