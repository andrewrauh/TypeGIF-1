//
//  ThirdViewController.m
//  TypeGIF
//
//  Created by Carl Lachner on 4/7/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "ThirdViewController.h"

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
    
    ///
    for (NSString* url in self.collectionData) {
        NSLog(@"url is: %@", url);///
        if (url == NULL) {
            
        }
    }///
    
    [self.favoritesCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView delegate Methods

- (AXCCollectionViewCell *) collectionView:(GIFCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AXCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//    AXCGiphy * gif = self.collectionData[indexPath.item];
    
    NSString *url = self.collectionData[indexPath.item];
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.2];

    [cell setBackgroundColor:color];
    [cell.imageView setAnimatedImage:nil];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSData *myGif;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        NSLog(@"paths size: %lu", (unsigned long)[paths count]);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
//        NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
//        NSString *trimmedReplacement = [[str componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
//        NSString* fileName = [NSString stringWithFormat:@"%@.gif", trimmedReplacement];
        NSString *fileName = url;
        
        //NSLog(@"fileName is: %@", fileName);
        
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        NSError* error = nil;///
        myGif = [NSData dataWithContentsOfFile:dataPath  options: 0 error: &error];
//        if (myGif == nil) {
//            NSLog(@"Failed to read file, error %@", error);
//        }///
//        else {
//            // parse the JSON etc
//        
        
            if (myGif.length == 0) {
                
            NSLog(@"here 2");///
    //            
    //            NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
    //            NSURLResponse *response;
    //            NSError *Jerror = nil;
    //            myGif = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&Jerror];

    //            NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
    //            [self writeGifToDisk:myGif withName:str];
            }
            else {
                
                        NSLog(@"here 2.5");///
                NSLog(@"cache hit");
            }
//        };
        
        
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:myGif];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.imageView.animatedImage = image;
//            [cell setImageURL:str];
            cell.imageView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
        });
    });
    return cell;
}

- (NSInteger)collectionView:(GIFCollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.collectionData count];
}

- (NSInteger)numberOfSectionsInCollectionView: (GIFCollectionView *)collectionView {
    return 1;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(GIFCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //You may want to create a divider to scale the size by the way..
    return CGSizeMake(100,100);
}

- (CGFloat)collectionView:(GIFCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(GIFCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
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
