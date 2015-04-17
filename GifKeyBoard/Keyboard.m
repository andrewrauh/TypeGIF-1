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
#import "DatabaseManager.h"
#import <MBProgressHUD.h>

@interface Keyboard () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSString* selectedCollectionName;
@end

@implementation Keyboard
@synthesize resultsCollectionView;
@synthesize librarySelector;

-(void)awakeFromNib {
    self.selectedCollectionName = [NSString new];
    
    self.db = [DatabaseManager createDatabaseInstance];
    //update this to only be the selected one
    self.selectedCollectionName = [self getNameOfSelectedCollection];
    //assuming two collections
    [self.librarySelector setTitle:self.selectedCollectionName forSegmentAtIndex:1];
    [self.resultsCollectionView setPagingEnabled:YES];
    [self.librarySelector addTarget:self action:@selector(segmentedControlChange:) forControlEvents:UIControlEventValueChanged];
    [self.librarySelector setSelectedSegmentIndex:0];
    self.favoritesArray = [NSMutableArray new];
    
    self.favoritesArray = [NSMutableArray arrayWithArray:[self.db getGiphyLocationUrlsForCollectionName:self.selectedCollectionName]];
    
//    self.favoritesArray = [NSMutableArray arrayWithArray:[self.db photoUrlsForCollection:self.selectedCollectionName]];

}

-(NSString *) getNameOfSelectedCollection {
    NSString *strCollection = [NSString new];
    NSUserDefaults *userdefaults =  [[NSUserDefaults alloc] initWithSuiteName:@"group.com.umich.typegif"];
    strCollection = [userdefaults objectForKey:@"selected_collection"];
    
    if (strCollection.length == 0) {
        self.selectedCollectionName = [NSString stringWithFormat:@"Favorites"]; //default value
    }
    return strCollection;
}
-(void)layoutSubviews {
}

- (void)loadGifCollection {
    self.resultsCollectionView.delegate = self;
    self.resultsCollectionView.dataSource = self;
    
    [self.resultsCollectionView registerClass:[AXCCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    
    [self.resultsCollectionView setBackgroundColor:[UIColor clearColor]];
        
    [AXCGiphy trendingGIFsWithlimit:30 offset:0 completion:^(NSArray *results, NSError *error) {
        self.trendingArray = [NSMutableArray arrayWithArray:results];
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

-(void) loadGifsSelectedCollection {
    NSMutableArray *arrayResults = [self.db photoUrlsForCollection:self.selectedCollectionName];
    
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
        
        //Attempt at using app group container for read/write
//        NSURL *groupURL = [[NSFileManager defaultManager]
//                           containerURLForSecurityApplicationGroupIdentifier:
//                           @"group.com.umich.typegif"];
//        NSString *docsDir = [NSString stringWithFormat:@"%@", groupURL];

        
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
            cell.imageView.frame = CGRectMake(0.0, 0.0, 90.0, 70.0);
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
    });
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AXCCollectionViewCell *curcell = (AXCCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.12;
    scaleAnimation.repeatCount = 2;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0 ];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.25];
    [curcell.layer addAnimation:scaleAnimation forKey:@"scale"];
    
//copy to clipboard
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    [pasteBoard setData:curcell.imageView.animatedImage.data
      forPasteboardType:@"com.compuserve.gif"];
}

#pragma mark - UICollectionViewLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize mElementSize = CGSizeMake(90, 70);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

#pragma mark - UI Methods  + IBactions
-(IBAction)segmentedControlChange:(id)sender {
    [self.resultsCollectionView reloadData];
}


@end

