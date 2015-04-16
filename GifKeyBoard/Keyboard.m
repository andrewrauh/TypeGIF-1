//
//  Keyboard.m
//  TypeGIF
//
//  Created by Carl Lachner on 4/13/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "Keyboard.h"
#import "AXCGiphy.h"
#import "AXCCollectionViewCell.h"
@import QuartzCore;
#import "DatabaseManager.h"
#import "ChangeCollectionViewController.h"
#import <FLAnimatedImage/FLAnimatedImage.h>

@interface Keyboard () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation Keyboard
@synthesize resultsCollectionView;
@synthesize librarySelector;

-(void)awakeFromNib {
    self.db = [DatabaseManager createDatabaseInstance];
    NSArray *collections = [self.db getAllCollections] ;
    NSUInteger index = 0;

    for (NSString *title  in collections) {
        [self.librarySelector insertSegmentWithTitle:title atIndex:index animated:YES];
        index++;
    }

}

-(void)layoutSubviews {
    [self.librarySelector addTarget:self action:@selector(segmentedControlChange:) forControlEvents:UIControlEventValueChanged];
   
//    self.librarySelector.numberOfSegments
    
    
    
}
- (void)loadGifCollection {
    self.resultsCollectionView.delegate = self;
    self.resultsCollectionView.dataSource = self;
    
    [self.resultsCollectionView registerClass:[AXCCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    
    [self.resultsCollectionView setBackgroundColor:[UIColor clearColor]];
        
    [AXCGiphy trendingGIFsWithlimit:10 offset:0 completion:^(NSArray *results, NSError *error) {
        self.trendingArray = [NSMutableArray arrayWithArray:results];
        self.favoritesArray = [NSMutableArray new];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.resultsCollectionView reloadData];
        }];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (self.librarySelector.selectedSegmentIndex == 0) {
        return [self.trendingArray count];
    }
    else {
        return [self.favoritesArray count];
    }
}

#pragma mark - UICollectionView delegate Methods

- (AXCCollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AXCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    AXCGiphy *gif;
    if (librarySelector.selectedSegmentIndex == 0) {
        gif = self.trendingArray[indexPath.item];
    }
    else {
        gif = self.favoritesArray[indexPath.item];
    }
    
    [cell setBackgroundColor:[UIColor grayColor]];
    [cell setImageView:nil];
    
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
            //NSLog(@"cache hit");
        }
        
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:myGif];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.imageView.animatedImage = image;
            [cell setImageURL:str];
            cell.imageView.frame = CGRectMake(0.0, 0.0, 70.0, 70.0);
        });
    });
    return cell;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize mElementSize = CGSizeMake(70, 70);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}


-(IBAction)segmentedControlChange:(id)sender {
    [self.resultsCollectionView reloadData];
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AXCCollectionViewCell *curcell = (AXCCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    [pasteBoard setData:curcell.imageView.animatedImage.data
      forPasteboardType:@"com.compuserve.gif"];

}


@end

