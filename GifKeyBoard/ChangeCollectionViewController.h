//
//  ChangeCollectionViewController.h
//  TypeGIF
//
//  Created by Andrew Rauh on 4/13/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeCollectionViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView* collectionsTableView;
@property (nonatomic, strong) NSMutableArray *collections;

@end
