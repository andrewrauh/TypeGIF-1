//
//  ViewSuggestedCollectionVC.h
//  TypeGIF
//
//  Created by Andrew Rauh on 4/15/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "GIFCollectionView.h"
#import "AXCCollectionViewCell.h"
#import <MBProgressHUD.h>
#import <AXCGiphy.h>


@interface ViewSuggestedCollectionVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView* mainCollectionView;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSString* searchTerm;

@end
