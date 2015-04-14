//
//  ThirdViewController.h
//  TypeGIF
//
//  Created by Carl Lachner on 4/7/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThirdViewController : UIViewController

@property (nonatomic, strong) IBOutlet UICollectionView *favoritesCollectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editCollectionButton;
@property (nonatomic, strong) NSMutableArray *collectionData;

@end
