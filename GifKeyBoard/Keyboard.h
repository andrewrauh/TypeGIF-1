//
//  Keyboard.h
//  TypeGIF
//
//  Created by Carl Lachner on 4/13/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseManager.h"


@interface Keyboard : UIView

@property (weak, nonatomic) IBOutlet UIButton *nextKey;
@property (weak, nonatomic) IBOutlet UIButton *deleteKey;
@property (weak, nonatomic) IBOutlet UISegmentedControl *librarySelector;
@property (nonatomic, strong) NSMutableArray *trendingArray;
@property (nonatomic, strong) NSMutableArray *favoritesArray;
@property (weak, nonatomic) IBOutlet UICollectionView *resultsCollectionView;
@property (strong, nonatomic) DatabaseManager *db;
@property (strong, nonatomic) NSMutableArray* curResults;

//methods
-(void)loadGifCollection;
-(IBAction)segmentedControlChange:(id)sender;
-(void) loadGifsSelectedCollection;


@end
