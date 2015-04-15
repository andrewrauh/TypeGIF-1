//
//  ThirdViewController.m
//  TypeGIF
//
//  Created by Carl Lachner on 4/7/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "ThirdViewController.h"
#import <MBProgressHUD.h>

@interface ThirdViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) DatabaseManager *db;
@end

@implementation ThirdViewController
@synthesize favoritesCollectionView, collectionData;

- (IBAction)editCollectionAction:(id)sender {
    BOOL editing = !self.favoritesCollectionView.editing;
//    self.navigationItem.leftBarButtonItem.enabled = !editing;

    if (editing) {
        [self.editCollectionButton setTitle:@"Done"];
        [self.editCollectionButton setStyle:UIBarButtonItemStyleDone];
    }
    else {
        [self.editCollectionButton setTitle:@"Edit"];
        [self.editCollectionButton setStyle:UIBarButtonItemStylePlain];
    }

    for (AXCCollectionViewCell *cell in [self.favoritesCollectionView visibleCells]) {
        [cell shake:editing];
    }
    [self.favoritesCollectionView setEditing:editing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.favoritesCollectionView registerClass:[AXCCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    self.favoritesCollectionView.delegate = self;
    self.favoritesCollectionView.dataSource = self;

    self.db   = [DatabaseManager createDatabaseInstance];
    self.collectionData = [NSMutableArray arrayWithArray:[self.db photoUrlsForCollection:self.collectionName]];
    [self.favoritesCollectionView reloadData];
    [self.favoritesCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setTitle:self.collectionName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cell animation


#pragma mark - UICollectionView delegate Methods

- (AXCCollectionViewCell *) collectionView:(GIFCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AXCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//    [cell addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.2];

    [cell setBackgroundColor:color];
    [cell.imageView setAnimatedImage:nil];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSData *gif;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fileName = self.collectionData[indexPath.item];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        gif = [NSData dataWithContentsOfFile:dataPath];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:gif];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.imageView.animatedImage = image;
        });
    });
    [cell shake:self.favoritesCollectionView.editing];
    return cell;
}

- (NSInteger)collectionView:(GIFCollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.collectionData count];
}

- (NSInteger)numberOfSectionsInCollectionView: (GIFCollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(GIFCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.favoritesCollectionView.editing) {
        [self.db removeGifFromCollection:self.collectionName and:collectionData[indexPath.item]];
        [self.collectionData removeObjectAtIndex:indexPath.item];
        [self.favoritesCollectionView reloadData];
    }
    else {
        AXCCollectionViewCell *curcell = (AXCCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
        [pasteBoard setData:curcell.imageView.animatedImage.data
          forPasteboardType:@"com.compuserve.gif"];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"Copied to Clipboard!";
        [hud hide:YES afterDelay:1.0f];
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(GIFCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //You may want to create a divider to scale the size by the way..
    return CGSizeMake(123, 100);
}

- (CGFloat)collectionView:(GIFCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(GIFCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (UIEdgeInsets)collectionView:(GIFCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
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
