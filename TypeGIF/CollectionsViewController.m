//
//  CollectionsViewController.m
//  TypeGIF
//
//  Created by Andrew Rauh on 4/15/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "CollectionsViewController.h"
#import "GIFCollectionCell.h"

@implementation CollectionsViewController 
@synthesize collectionsTableView;


-(void)viewDidLoad {
    [self.collectionsTableView registerNib:[UINib nibWithNibName:@"GIFCollectionCell" bundle:nil] forCellReuseIdentifier:@"CollectionCell"];
    self.collectionsTableView.delegate = self;
    self.collectionsTableView.dataSource = self;
    self.tableData = @[@"happy", @"sad", @"mad", @"confused", @"rage", @"meme", @"celebrate", @"party"];
    
    
}

-(GIFCollectionCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.5];
    
    static NSString *cellIdentifier = @"CollectionCell";
    GIFCollectionCell *cell = (GIFCollectionCell *)[collectionsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.nameLabel.text = self.tableData[indexPath.row];
    
    [cell setBackgroundColor:color];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self performSegueWithIdentifier:@"CollectionSegue" sender:indexPath];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CollectionSegue"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
//        ThirdViewController *vc = [segue destinationViewController];
//        vc.collectionName = tableData[indexPath.row];
    }
}

@end
