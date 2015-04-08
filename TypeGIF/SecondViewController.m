//
//  SecondViewController.m
//  TypeGIF
//
//  Created by Natasja Nielsen on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController () <UITableViewDataSource, UITableViewDelegate>

@end


@implementation SecondViewController
@synthesize collectionsTableView, tableData;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionsTableView registerNib:[UINib nibWithNibName:@"GIFCollectionCell" bundle:nil] forCellReuseIdentifier:@"CollectionCell"];
    
    self.collectionsTableView.delegate = self;
    self.collectionsTableView.dataSource = self;
    //formatting of the view
    [self.collectionsTableView setBackgroundColor:[UIColor blackColor]];
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CollectionCell";
    
    GIFCollectionCell *cell = (GIFCollectionCell *)[collectionsTableView dequeueReusableCellWithIdentifier:cellIdentifier];

    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath()");
    [self performSegueWithIdentifier:@"CollectionSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
