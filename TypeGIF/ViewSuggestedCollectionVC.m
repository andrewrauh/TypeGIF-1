//
//  ViewSuggestedCollectionVC.m
//  TypeGIF
//
//  Created by Andrew Rauh on 4/15/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "ViewSuggestedCollectionVC.h"

@implementation ViewSuggestedCollectionVC

-(void)viewDidLoad {
    self.results = [NSMutableArray new];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Loading";
    [self.mainCollectionView registerClass:[AXCCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];

    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;

    [AXCGiphy searchGiphyWithTerm:self.searchTerm limit:100 offset:0 completion:^(NSArray *results, NSError *error) {
        self.results = [NSMutableArray arrayWithArray:results];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [hud hide:YES];
            [self.mainCollectionView reloadData];
        }];
    }];

    [self.mainCollectionView setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;  // optional
    [self showAlertView];
    
}

- (void)showAlertView {
    UIAlertView *intro = [[UIAlertView alloc]initWithTitle:@"Hello!" message:@"Tap a gif to make pastable, or go home and press the compose button" delegate:self cancelButtonTitle:@"Go away" otherButtonTitles:@"Okay", nil];
    [intro show];
}


-(void) writeGifToDisk:(NSData * )gif withName:(NSString* ) name {
    // Use GCD's background queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *trimmedReplacement = [[name componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        NSString* fileName = [NSString stringWithFormat:@"%@.gif", trimmedReplacement];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        [gif writeToFile:dataPath atomically:YES];
        //        NSLog(@"wrote to %@", dataPath);
        
    });
}

#pragma mark - UI Collection View Methods
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
    AXCGiphy *gif = self.results[indexPath.row];
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        NSData *myGif;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
        NSString *trimmedReplacement = [[str componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        NSString* fileName = [NSString stringWithFormat:@"%@.gif", trimmedReplacement];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        myGif = [NSData dataWithContentsOfFile:dataPath];
        
        if (myGif.length == 0) {
            NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
            NSURLResponse *response;
            NSError *Jerror = nil;
            myGif = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&Jerror];
            NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
            [self writeGifToDisk:myGif withName:str];
        }
        else {
            NSLog(@"cache hit");
        }
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:myGif];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.imageView.animatedImage = image;
            [cell setImageURL:str];
            cell.imageView.frame = CGRectMake(0.0, 0.0, 124.0, 100.0);
        });
    });
    return cell;
}

- (NSInteger)collectionView:(GIFCollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.results count];
}

- (NSInteger)numberOfSectionsInCollectionView: (GIFCollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(GIFCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
        AXCCollectionViewCell *curcell = (AXCCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.12;
    scaleAnimation.repeatCount = 2;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0 ];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.05];
    [curcell.layer addAnimation:scaleAnimation forKey:@"scale"];

        UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
        [pasteBoard setData:curcell.imageView.animatedImage.data
          forPasteboardType:@"com.compuserve.gif"];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"Copied to Clipboard!";
        [hud hide:YES afterDelay:1.0f];
}


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

#pragma mark - other methods

@end
