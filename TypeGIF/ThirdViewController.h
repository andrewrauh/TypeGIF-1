//
//  ThirdViewController.h
//  TypeGIF
//
//  Created by Carl Lachner on 4/7/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AXCGiphy.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "GIFCollectionView.h"
#import "AXCCollectionViewCell.h"
#import "DatabaseManager.h"

@interface ThirdViewController : UIViewController

@property (nonatomic, strong) IBOutlet GIFCollectionView *favoritesCollectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editCollectionButton;
@property (nonatomic, strong) NSMutableArray *collectionData;
@property (nonatomic, strong) NSString *collectionName;

@end
