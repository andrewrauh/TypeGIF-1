//
//  FirstViewController.m
//  TypeGIF
//
//  Created by Natasja Nielsen on 3/26/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "FirstViewController.h"
#import "AXCGiphy.h"
//#import "AXCCollectionViewCell.h"


@interface FirstViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) IBOutlet UICollectionView* resultsCollectionView;

@end

@implementation FirstViewController
@synthesize resultsCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.resultsArray = [[NSMutableArray alloc]init];
    self.searchTextField.delegate = self;
    
    self.resultsCollectionView.delegate = self;
    self.resultsCollectionView.dataSource = self;
    
    [self.resultsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];

    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    
    [self.searchTextField setPlaceholder:@"search here"];
    [self.resultsCollectionView setBackgroundColor:[UIColor clearColor]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    [AXCGiphy searchGiphyWithTerm:textField.text limit:20 offset:0 completion:^(NSArray *results, NSError *error) {
        self.resultsArray = [NSMutableArray arrayWithArray:results];
        NSLog(@"results : %@", results);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.resultsCollectionView reloadData];
        }];
    }];

}

#pragma mark - UICollectionView delegate Methods
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    AXCGiphy * gif = self.resultsArray[indexPath.item];
    NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage * image = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            cell.backgroundColor = [UIColor colorWithPatternImage:image];
        }];
    }] resume];
    return cell;
}

// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.resultsArray count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //You may want to create a divider to scale the size by the way..
    return CGSizeMake(100,100);
}

@end
