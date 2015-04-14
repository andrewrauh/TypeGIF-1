//
//  SecondViewController.m
//  TypeGIF
//
//  Created by Natasja Nielsen on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "SecondViewController.h"
#import "DatabaseManager.h"

@interface SecondViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) DatabaseManager *db;
@end


@implementation SecondViewController
@synthesize collectionsTableView, tableData;


- (IBAction)editCollectionsAction:(id)sender {
    BOOL editing = !self.collectionsTableView.editing;
    self.addCollectionButton.enabled = !editing;

    if (editing) {
        [self.editCollectionsButton setTitle:@"Done"];
        [self.editCollectionsButton setStyle:UIBarButtonItemStyleDone];
    }
    else{
        [self.editCollectionsButton setTitle:@"Edit"];
        [self.editCollectionsButton setStyle:UIBarButtonItemStylePlain];
    }

    [self.collectionsTableView setEditing:editing animated:YES];
}

- (IBAction)addCollectionAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add New Collection"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        [self.db addNewCollectionWithName:name];
        
        // TODO : save new collection name to backend
        [tableData addObject:name];
        [collectionsTableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionsTableView registerNib:[UINib nibWithNibName:@"GIFCollectionCell" bundle:nil] forCellReuseIdentifier:@"CollectionCell"];
    self.collectionsTableView.delegate = self;
    self.collectionsTableView.dataSource = self;

    //formatting of the view
    [self.collectionsTableView setBackgroundColor:[UIColor blackColor]];

    // TODO : populate tableData with user's saved collection names
//    tableData = [NSMutableArray arrayWithObjects:@"Trending",@"test2",@"test3", nil];
    self.db   = [DatabaseManager createDatabaseInstance];
    tableData = [NSMutableArray arrayWithArray:[self.db getAllCollections]];
    [self.collectionsTableView reloadData];
}

#pragma mark - UITableViewCell 

-(GIFCollectionCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CollectionCell";
    GIFCollectionCell *cell = (GIFCollectionCell *)[collectionsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.nameLabel.text = tableData[indexPath.row];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
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
    [self performSegueWithIdentifier:@"CollectionSegue" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare for seque called");
    //need to pass in the array of urls to use
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // TODO : delete GIFs owned by collection being deleted

        [self.tableData removeObjectAtIndex:indexPath.row];
        [self.collectionsTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
