//
//  Keyboard.m
//  TypeGIF
//
//  Created by Carl Lachner on 4/13/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "Keyboard.h"
#import "AXCGiphy.h"
#import <FLAnimatedImage/FLAnimatedImage.h>

@import QuartzCore;

@interface Keyboard () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation Keyboard
@synthesize resultsCollectionView;

- (void)loadGifCollection {
//    self.resultsCollectionView.delegate = self;
//    self.resultsCollectionView.dataSource = self;
//    
//    [self.resultsCollectionView registerClass:[AXCCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
//    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
//    
//    [self.resultsCollectionView setBackgroundColor:[UIColor clearColor]];
//    
//    [AXCGiphy trendingGIFsWithlimit:30 offset:0 completion:^(NSArray *results, NSError *error) {
//        self.trendingArray = [NSMutableArray arrayWithArray:results];
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [hud hide:YES];
//            [self.resultsCollectionView reloadData];
//        }];
//    }];
//}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.trendingArray count];
}

#pragma mark - UICollectionView delegate Methods

//- (AXCCollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
////    AXCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
////    AXCGiphy * gif = self.trendingArray[indexPath.item];
////    
////    [cell setBackgroundColor:[UIColor grayColor]];
////    [cell setImageView:nil];
////    
////    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
////        
////        NSData *myGif;
////        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
////        NSString *documentsDirectory = [paths objectAtIndex:0];
////        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
////        NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
////        NSString *trimmedReplacement = [[str componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
////        NSString* fileName = [NSString stringWithFormat:@"%@.gif", trimmedReplacement];
////        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
////        
////        myGif = [NSData dataWithContentsOfFile:dataPath];
////        
////        if (myGif.length == 0) {
////            NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
////            NSURLResponse *response;
////            NSError *Jerror = nil;
////            myGif = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&Jerror];
////            
////            NSString *str = [NSString stringWithFormat:@"%@", gif.originalImage.url];
////            [self writeGifToDisk:myGif withName:str];
////        }
////        
////        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:myGif];
////        
////        dispatch_async(dispatch_get_main_queue(), ^(void){
////            cell.imageView.animatedImage = image;
////            cell.imageView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
////        });
////    });
////    return cell;
//}


@end
@end

